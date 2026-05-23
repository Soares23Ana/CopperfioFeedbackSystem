import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_integrado/data/models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'messages';

  // Buscar mensagens entre dois usuários
  Stream<List<MessageModel>> buscarMensagensEntre(
      String usuarioId1, String usuarioId2) {
    return _firestore
        .collection(collectionName)
        .where('senderId', isEqualTo: usuarioId1)
        .where('recipientId', isEqualTo: usuarioId2)
        .snapshots()
        .asyncMap((snapshot1) async {
      final docs1 = snapshot1.docs;

      final snapshot2 = await _firestore
          .collection(collectionName)
          .where('senderId', isEqualTo: usuarioId2)
          .where('recipientId', isEqualTo: usuarioId1)
          .get();
      final docs2 = snapshot2.docs;

      final allDocs = [...docs1, ...docs2];
      allDocs.sort((a, b) {
        final timeA = a['timestamp'] as int;
        final timeB = b['timestamp'] as int;
        return timeA.compareTo(timeB);
      });

      return allDocs
          .map((doc) => MessageModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Buscar mensagens em tempo real (ambos os sentidos)
  Stream<List<MessageModel>> fetchMessagesRealtime(
      String usuarioId1, String usuarioId2) {
    return _firestore
        .collection(collectionName)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => MessageModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Filtrar apenas mensagens entre os dois usuários
      return messages
          .where((msg) =>
              (msg.senderId == usuarioId1 && msg.recipientId == usuarioId2) ||
              (msg.senderId == usuarioId2 && msg.recipientId == usuarioId1))
          .toList();
    });
  }

  // Buscar conversas do usuário (únicos contatos)
  Stream<List<Map<String, dynamic>>> buscarConversasDoUsuario(
      String usuarioId) {
    return _firestore
        .collection(collectionName)
        .where('senderId', isEqualTo: usuarioId)
        .snapshots()
        .asyncMap((snapshot1) async {
      final outgoing = snapshot1.docs;

      final incoming = await _firestore
          .collection(collectionName)
          .where('recipientId', isEqualTo: usuarioId)
          .get();

      final conversas = <String, Map<String, dynamic>>{};

      // Processar mensagens enviadas
      for (var doc in outgoing) {
        final data = doc.data();
        final recipientId = data['recipientId'] as String;
        if (!conversas.containsKey(recipientId)) {
          conversas[recipientId] = {
            'contactId': recipientId,
            'contactName': data['recipientName'] ?? 'Usuário',
            'lastMessage': data['content'] ?? '',
            'timestamp': data['timestamp'] ?? 0,
          };
        }
      }

      // Processar mensagens recebidas
      for (var doc in incoming.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String;
        conversas[senderId] = {
          'contactId': senderId,
          'contactName': data['senderName'] ?? 'Usuário',
          'lastMessage': data['content'] ?? '',
          'timestamp': data['timestamp'] ?? 0,
        };
      }

      return conversas.values.toList();
    });
  }

  // Enviar mensagem
  Future<String> enviarMensagem(MessageModel message) async {
    try {
      final doc = await _firestore.collection(collectionName).add(
            message.toMap(),
          );
      return doc.id;
    } catch (e) {
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }

  // Deletar mensagem
  Future<void> deletarMensagem(String messageId) async {
    try {
      await _firestore.collection(collectionName).doc(messageId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar mensagem: $e');
    }
  }

  // Marcar mensagens como lidas
  Future<void> marcarComoLida(String messageId) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Erro ao marcar como lida: $e');
    }
  }
}
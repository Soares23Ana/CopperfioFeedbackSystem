import 'package:flutter/foundation.dart';
import 'package:projeto_integrado/data/models/message_model.dart';
import 'package:projeto_integrado/data/repositories/chat_repository.dart';
import 'package:projeto_integrado/services/auth_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final AuthService _authService = AuthService();

  List<MessageModel> _mensagens = [];
  List<Map<String, dynamic>> _conversas = [];
  bool _estaCarregando = false;
  String? _erro;
  String? _contatoSelecionado;

  // Getters
  List<MessageModel> get mensagens => _mensagens;
  List<Map<String, dynamic>> get conversas => _conversas;
  bool get estaCarregando => _estaCarregando;
  String? get erro => _erro;
  String? get contatoSelecionado => _contatoSelecionado;

  // Stream de mensagens entre dois usuários
  Stream<List<MessageModel>> obterMensagensEntre(
      String usuarioId, String contatoId) {
    return _repository.fetchMessagesRealtime(usuarioId, contatoId);
  }

  // Obter stream de conversas do usuário
  Stream<List<Map<String, dynamic>>> obterConversasDoUsuario() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return Stream.error('Usuário não autenticado');
    }
    return _repository.buscarConversasDoUsuario(userId);
  }

  // Enviar mensagem
  Future<void> enviarMensagem({
    required String recipientId,
    required String recipientName,
    required String content,
  }) async {
    try {
      _estaCarregando = true;
      _erro = null;
      notifyListeners();

      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final userData = await _authService.getCurrentUserData();
      final senderName = userData?['nome'] as String? ?? 'Usuário';
      final senderRole =
          userData?['tipo'] as String? ?? userData?['role'] as String? ?? 'cliente';

      final message = MessageModel(
        id: '',
        senderId: userId,
        senderName: senderName,
        senderRole: senderRole,
        recipientId: recipientId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _repository.enviarMensagem(message);
      _estaCarregando = false;
      notifyListeners();
    } catch (e) {
      _erro = "Erro ao enviar mensagem: $e";
      _estaCarregando = false;
      notifyListeners();
      rethrow;
    }
  }

  // Deletar mensagem
  Future<void> deletarMensagem(String messageId) async {
    try {
      await _repository.deletarMensagem(messageId);
      notifyListeners();
    } catch (e) {
      _erro = "Erro ao deletar mensagem: $e";
      notifyListeners();
      rethrow;
    }
  }

  // Marcar mensagem como lida
  Future<void> marcarComoLida(String messageId) async {
    try {
      await _repository.marcarComoLida(messageId);
    } catch (e) {
      _erro = "Erro ao marcar como lida: $e";
      notifyListeners();
    }
  }

  // Selecionar contato
  void selecionarContato(String contatoId) {
    _contatoSelecionado = contatoId;
    notifyListeners();
  }

  // Limpar erro
  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}
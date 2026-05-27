import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_integrado/data/models/chamado_model.dart';

class ChamadosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'chamados';

  // Criar novo chamado
  Future<String> criarChamado(ChamadoModel chamado) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .add(chamado.toMap());
      return doc.id;
    } catch (e) {
      throw Exception('Erro ao criar chamado: $e');
    }
  }

  // Buscar chamados por usuário (cliente)
  Stream<List<ChamadoModel>> buscarChamadosDoUsuario(String usuarioId) {
    return _firestore
        .collection(collectionName)
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snapshot) {
          final chamados = snapshot.docs
              .map((doc) => ChamadoModel.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
          chamados.sort((a, b) => b.dataAbertura.compareTo(a.dataAbertura));
          return chamados;
        });
  }

  // Buscar chamados da empresa (gestor)
  Stream<List<ChamadoModel>> buscarChamadosDaEmpresa(String empresaId) {
    return _firestore
        .collection(collectionName)
        .where('empresaId', isEqualTo: empresaId)
        .snapshots()
        .map((snapshot) {
          final chamados = snapshot.docs
              .map((doc) => ChamadoModel.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
          chamados.sort((a, b) => b.dataAbertura.compareTo(a.dataAbertura));
          return chamados;
        });
  }

  // Buscar chamado específico
  Future<ChamadoModel?> buscarChamado(String chamadoId) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(chamadoId)
          .get();
      if (doc.exists) {
        return ChamadoModel.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar chamado: $e');
    }
  }

  // Atualizar status do chamado
  Future<void> atualizarStatus(String chamadoId, String novoStatus) async {
    try {
      await _firestore.collection(collectionName).doc(chamadoId).update({
        'status': novoStatus,
        'dataFechamento': novoStatus == 'fechado'
            ? DateTime.now().millisecondsSinceEpoch
            : null,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar status: $e');
    }
  }

  // Atualizar prioridade do chamado
  Future<void> atualizarPrioridade(
    String chamadoId,
    String novaPrioridade,
  ) async {
    try {
      await _firestore.collection(collectionName).doc(chamadoId).update({
        'prioridade': novaPrioridade,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar prioridade: $e');
    }
  }

  // Buscar dados completos do chamado, incluindo campos extras como análise IA
  Future<Map<String, dynamic>?> buscarChamadoDados(String chamadoId) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(chamadoId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Erro ao buscar dados do chamado: $e');
    }
  }

  // Salvar análise IA no chamado
  Future<void> salvarAnaliseChamado(
    String chamadoId,
    Map<String, dynamic> analise,
  ) async {
    try {
      await _firestore.collection(collectionName).doc(chamadoId).update({
        'analiseIA': analise,
        'analisadoEm': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao salvar análise IA do chamado: $e');
    }
  }

  // Salvar template de e-mail gerado no chamado
  Future<void> salvarTemplateEmailChamado(
    String chamadoId,
    String emailTemplate,
  ) async {
    try {
      await _firestore.collection(collectionName).doc(chamadoId).update({
        'analiseIA.emailTemplate': emailTemplate,
      });
    } catch (e) {
      throw Exception('Erro ao salvar template de e-mail do chamado: $e');
    }
  }

  // Adicionar mensagem ao chamado
  Future<void> adicionarMensagem(String chamadoId, String mensagemId) async {
    try {
      await _firestore.collection(collectionName).doc(chamadoId).update({
        'mensagens': FieldValue.arrayUnion([mensagemId]),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar mensagem: $e');
    }
  }

  // Deletar chamado
  Future<void> deletarChamado(String chamadoId) async {
    try {
      await _firestore.collection(collectionName).doc(chamadoId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar chamado: $e');
    }
  }
}

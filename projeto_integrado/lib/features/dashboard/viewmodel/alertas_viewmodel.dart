import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_integrado/data/models/chamado_model.dart';
import 'package:projeto_integrado/data/repositories/chamados_repository.dart';
import 'package:projeto_integrado/services/auth_service.dart';
import 'package:projeto_integrado/services/firestore_service.dart';
import 'package:projeto_integrado/services/gemini_service.dart';

class AlertasViewModel extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  final ChamadosRepository _repository = ChamadosRepository();
  final AuthService _authService = AuthService();
  final GeminiService _geminiService = GeminiService();

  Stream<QuerySnapshot<Map<String, dynamic>>> feedbacksStream() async* {
    final userData = await _authService.getCurrentUserData();
    final empresaId = userData?['empresaId'] as String? ?? 'copperfio';
    yield* _service.getFeedbacks(empresaId);
  }

  Stream<List<ChamadoModel>> chamadosStream() async* {
    final userData = await _authService.getCurrentUserData();
    final empresaId = userData?['empresaId'] as String? ?? 'copperfio';
    yield* _repository.buscarChamadosDaEmpresa(empresaId);
  }

  bool isFeedbackAlert(Map<String, dynamic> data) {
    // Considera feedback preocupante quando a média das notas está abaixo ou igual a 6.
    final notaMedia = (data['notaMedia'] as num?)?.toDouble() ?? 0.0;

    // Ignora notas ausentes (0) para não disparar falsos alertas.
    return notaMedia > 0 && notaMedia <= 6.0;
  }

  bool isChamadoAlert(ChamadoModel chamado) {
    final prioridade = chamado.prioridade.toLowerCase();
    final titulo = chamado.titulo.toLowerCase();
    final descricao = chamado.descricao.toLowerCase();

    return prioridade == 'alta' ||
        titulo.contains('urgente') ||
        descricao.contains('urgente') ||
        titulo.contains('falha') ||
        descricao.contains('falha') ||
        titulo.contains('parada') ||
        descricao.contains('parada') ||
        titulo.contains('erro') ||
        descricao.contains('erro') ||
        titulo.contains('problema') ||
        descricao.contains('problema') ||
        titulo.contains('reclama') ||
        descricao.contains('reclama') ||
        titulo.contains('defeito') ||
        descricao.contains('defeito');
  }

  Future<void> deletarFeedback(String feedbackId) async {
    try {
      await _service.deletarFeedback(feedbackId);
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao deletar feedback: $e');
    }
  }

  Future<void> deletarChamado(String chamadoId) async {
    try {
      await _repository.deletarChamado(chamadoId);
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao deletar chamado: $e');
    }
  }

  Future<Map<String, dynamic>> gerarAnaliseFeedback(Map<String, dynamic> feedbackData) async {
    try {
      final texto = _extrairTextoFeedback(feedbackData);
      return await _geminiService.analisarFeedback(texto);
    } catch (e) {
      throw Exception('Erro ao analisar feedback com IA: $e');
    }
  }

  String _extrairTextoFeedback(Map<String, dynamic> feedbackData) {
    final titulo = feedbackData['titulo'] as String? ?? '';
    final mensagem = feedbackData['mensagem'] as String? ?? '';
    final descricao = feedbackData['descricao'] as String? ?? '';
    final atendimentoMood = feedbackData['atendimentoMood'] as String? ?? '';
    final tags = (feedbackData['tags'] as List<dynamic>?)?.cast<String>() ?? [];
    final notaMedia = feedbackData['notaMedia'] as num? ?? 0;

    return '''
Título: $titulo
Mensagem: $mensagem
Descrição: $descricao
Nota: $notaMedia
Humor do atendimento: $atendimentoMood
Tags: ${tags.join(', ')}
'''.trim();
  }
}

import 'package:flutter/foundation.dart';
import 'package:projeto_integrado/data/models/chamado_model.dart';
import 'package:projeto_integrado/data/repositories/chamados_repository.dart';
import 'package:projeto_integrado/services/auth_service.dart';
import 'package:projeto_integrado/services/history_service.dart';

class ChamadosViewModel extends ChangeNotifier {
  final ChamadosRepository _repository = ChamadosRepository();
  final AuthService _authService = AuthService();

  List<ChamadoModel> chamados = [];
  bool isLoading = false;
  String? error;

  // Obter stream de chamados do usuário
  Stream<List<ChamadoModel>> obterChamadosDoUsuario() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return Stream.error('Usuário não autenticado');
    }
    return _repository.buscarChamadosDoUsuario(userId);
  }

  // Obter stream de chamados da empresa (gestor)
  Stream<List<ChamadoModel>> obterChamadosDaEmpresa() async* {
    final userData = await _authService.getCurrentUserData();
    final empresaId = userData?['empresaId'] as String? ?? 'copperfio';
    yield* _repository.buscarChamadosDaEmpresa(empresaId);
  }

  // Criar novo chamado
  Future<void> criarChamado({
    required String titulo,
    required String descricao,
    required String prioridade,
    String status = 'aberto',
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final userData = await _authService.getCurrentUserData();
      final usuarioNome = userData?['nome'] as String? ?? 'Usuário';
      final usuarioEmail = userData?['email'] as String? ?? '';
      final empresaId = userData?['empresaId'] as String? ?? 'copperfio';
      final empresaNome = userData?['empresa'] as String? ?? 'Empresa';

      final chamado = ChamadoModel(
        id: '',
        usuarioId: userId,
        usuarioNome: usuarioNome,
        usuarioEmail: usuarioEmail,
        empresaId: empresaId,
        empresaNome: empresaNome,
        titulo: titulo,
        descricao: descricao,
        status: status,
        prioridade: prioridade,
        dataAbertura: DateTime.now(),
      );

      await _repository.criarChamado(chamado);
      await const HistoryService().addAction(
        type: 'chamado',
        title: 'Chamado criado',
        description: 'Chamado enviado: $titulo.',
        metadata: {'prioridade': prioridade, 'status': status},
      );
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Atualizar status do chamado
  Future<void> atualizarStatus(String chamadoId, String novoStatus) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _repository.atualizarStatus(chamadoId, novoStatus);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Atualizar prioridade do chamado
  Future<void> atualizarPrioridade(
    String chamadoId,
    String novaPrioridade,
  ) async {
    try {
      await _repository.atualizarPrioridade(chamadoId, novaPrioridade);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Deletar chamado
  Future<void> deletarChamado(String chamadoId) async {
    try {
      await _repository.deletarChamado(chamadoId);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Obter chamado específico
  Future<ChamadoModel?> obterChamado(String chamadoId) async {
    try {
      return await _repository.buscarChamado(chamadoId);
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }
}

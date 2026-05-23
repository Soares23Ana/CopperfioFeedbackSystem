import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/app_exception.dart';
import '../../../data/models/usuario_model.dart';
import '../../../services/auth_service.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthService _authService;

  SignupViewModel({AuthService? authService})
    : _authService = authService ?? AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> cadastrarUsuario(UsuarioModel user) async {
    _setLoading(true);
    _clearMessages();

    if (user.nome.trim().isEmpty) {
      final message = 'Nome não pode ser vazio.';
      _errorMessage = message;
      _setLoading(false);
      throw Exception(message);
    }

    if (user.email.trim().isEmpty) {
      final message = 'E-mail não pode ser vazio.';
      _errorMessage = message;
      _setLoading(false);
      throw Exception(message);
    }

    if (user.senha == null || user.senha!.trim().isEmpty) {
      final message = 'Senha não pode ser vazia.';
      _errorMessage = message;
      _setLoading(false);
      throw Exception(message);
    }

    try {
      await _authService.register(
        email: user.email,
        password: user.senha ?? '',
        nome: user.nome,
        empresa: user.empresa ?? '',
        cnpj: user.cnpj ?? '',
      );
      _successMessage = 'Cadastro concluído com sucesso.';
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message =
              'Este e-mail já está cadastrado. Faça login ou recupere sua senha.';
          break;
        case 'weak-password':
          message = 'Senha muito fraca. Use pelo menos 6 caracteres.';
          break;
        case 'invalid-email':
          message = 'E-mail inválido.';
          break;
        default:
          message = 'Erro ao cadastrar: ${e.message}';
      }
      _errorMessage = message;
      throw AppException(message, e.code);
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      _errorMessage = message;
      throw AppException(message);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> existeEmail(String email) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      return await _authService.existsUserByEmail(email);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> redefinirSenha(String email) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.resetPassword(email);
      _successMessage = 'Email de recuperação enviado com sucesso.';
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'E-mail não cadastrado ou inválido. Verifique e tente novamente.';
          break;
        case 'invalid-email':
          message = 'E-mail inválido. Verifique e tente novamente.';
          break;
        default:
          message = 'Erro ao enviar e-mail de recuperação. Tente novamente mais tarde.';
      }
      _errorMessage = message;
      throw AppException(message, e.code);
    } catch (e) {
      final message = 'Erro ao enviar e-mail de recuperação. Tente novamente mais tarde.';
      _errorMessage = message;
      throw AppException(message);
    } finally {
      _setLoading(false);
    }
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

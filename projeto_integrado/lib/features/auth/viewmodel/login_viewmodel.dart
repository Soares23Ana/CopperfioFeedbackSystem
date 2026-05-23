import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/app_exception.dart';
import '../../../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;

  LoginViewModel({AuthService? authService})
    : _authService = authService ?? AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<String?> signIn({required String email, required String senha}) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    if (email.trim().isEmpty || senha.trim().isEmpty) {
      final message = 'Preencha e-mail e senha.';
      _errorMessage = message;
      _setLoading(false);
      throw Exception(message);
    }

    try {
      final tipo = await _authService.login(email: email, password: senha);
      if (tipo == null) {
        throw AppException('Usuário não encontrado.', 'user-not-found');
      }

      _successMessage = 'Login realizado com sucesso.';
      return tipo;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message =
              'Usuário não encontrado. Verifique o e-mail ou cadastre-se.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta. Tente novamente ou recupere a senha.';
          break;
        case 'invalid-email':
          message = 'E-mail inválido.';
          break;
        case 'invalid-credential':
          message = 'Credencial inválida ou expirada. Tente novamente.';
          break;
        default:
          message = 'Erro de autenticação: ${e.message}';
      }
      _errorMessage = message;
      throw AppException(message, e.code);
    } on ArgumentError catch (e) {
      final message = e.message?.toString() ?? 'Argumento inválido.';
      _errorMessage = message;
      throw ArgumentError(message);
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      _errorMessage = message;
      throw AppException(message);
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> fazerLogin({
    required String email,
    required String senha,
  }) async {
    return await signIn(email: email, senha: senha);
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuário não encontrado. Verifique o e-mail.';
          break;
        case 'invalid-email':
          message = 'E-mail inválido.';
          break;
        default:
          message = 'Erro ao resetar senha: ${e.message}';
      }
      _errorMessage = message;
      throw AppException(message, e.code);
    } catch (e) {
      _errorMessage = 'Ocorreu um erro inesperado.';
      throw AppException(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

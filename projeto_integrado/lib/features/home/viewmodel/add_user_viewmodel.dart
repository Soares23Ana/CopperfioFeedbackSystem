import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class AddUserViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> promoteUserToGestor(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _authService.promoteUserToGestor(email);
      _successMessage = 'Usuário promovido a gestor com sucesso!';
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '').isEmpty
          ? 'Erro ao promover usuário. Tente novamente.'
          : e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

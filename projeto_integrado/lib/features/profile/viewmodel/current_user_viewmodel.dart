import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class CurrentUserViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  String? _userType;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  String? get userType => _userType;
  User? get currentUser => _authService.getCurrentUser();
  bool get hasUser => currentUser != null;
  bool get hasLoaded => _hasLoaded;
  String get displayName {
    final nome = _userData?['nome'] as String? ?? '';
    if (nome.trim().isNotEmpty) return nome.trim();

    final firebaseDisplay = currentUser?.displayName;
    if (firebaseDisplay != null && firebaseDisplay.trim().isNotEmpty) {
      return firebaseDisplay.trim();
    }

    return 'Usuário';
  }

  String get firstName {
    final name = displayName.trim();
    if (name.isEmpty || name == 'Usuário') return 'Usuário';
    return name.split(' ').first.trim();
  }

  String get companyId => _userData?['empresaId'] as String? ?? 'copperfio';
  bool get isEmpresa => _userType == 'empresa';

  Future<void> loadUserData({bool force = false}) async {
    if (_hasLoaded && !force) return;
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userData = await _authService.getCurrentUserData();
      // Debug prints to help diagnose missing name issues
      // ignore: avoid_print
      print('[CurrentUserViewModel] loadUserData -> userData: $_userData');
      // ignore: avoid_print
      print('[CurrentUserViewModel] loadUserData -> firebase user: ${currentUser?.uid}, ${currentUser?.email}, ${currentUser?.displayName}');
      _userType = _userData?['tipo'] as String?;
      _hasLoaded = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    await loadUserData(force: true);
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateCurrentUserData(updates);
      await refreshUserData();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userData = null;
    _userType = null;
    _hasLoaded = false;
    notifyListeners();
  }
}

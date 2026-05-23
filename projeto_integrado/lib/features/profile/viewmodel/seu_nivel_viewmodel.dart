import 'package:flutter/foundation.dart';
import 'package:projeto_integrado/core/level_calculator.dart';
import 'package:projeto_integrado/services/auth_service.dart';
import 'package:projeto_integrado/services/firestore_service.dart';

class SeuNivelViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  int _copperPoints = 0;
  String _currentLevel = 'Bronze';
  String _nextLevel = 'Prata';
  double _progress = 0.0;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  int get copperPoints => _copperPoints;
  String get currentLevel => _currentLevel;
  String get nextLevel => _nextLevel;
  double get progress => _progress;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;

  Future<void> loadUserLevel({bool force = false}) async {
    if (_hasLoaded && !force) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _authService.currentUserId;
      if (userId == null || userId.isEmpty) {
        _error = 'Usuário não autenticado.';
      } else {
        final copperPoints = await _firestoreService.getUserCopperPoints(
          userId,
        );
        _copperPoints = copperPoints;
        _currentLevel = LevelCalculator.calculateLevel(copperPoints);
        _nextLevel = LevelCalculator.getNextLevel(_currentLevel);
        _progress = LevelCalculator.calculateProgress(
          copperPoints,
          _currentLevel,
        );
      }
    } catch (e) {
      _error = 'Erro ao calcular seu nível: $e';
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }
}

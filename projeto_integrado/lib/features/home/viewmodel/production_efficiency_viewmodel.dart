import 'package:flutter/material.dart';
import '../../../services/firestore_service.dart';
import '../../profile/viewmodel/current_user_viewmodel.dart';

class ProductionEfficiencyViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  CurrentUserViewModel _userViewModel;

  double _efficiency = 83.5;
  double _variation = 2.1;
  int _feedbackCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  Stream<Map<String, dynamic>>? _cachedStream;

  double get efficiency => _efficiency;
  double get variation => _variation;
  int get feedbackCount => _feedbackCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get variationText {
    if (_variation >= 0) {
      return '+${_variation.toStringAsFixed(1)}% desde o último turno';
    } else {
      return '${_variation.toStringAsFixed(1)}% desde o último turno';
    }
  }

  ProductionEfficiencyViewModel(this._userViewModel);

  void updateCurrentUser(CurrentUserViewModel userViewModel) {
    _userViewModel = userViewModel;
  }

  String _getEmpresaId() {
    try {
      final userData = _userViewModel.userData;
      return userData?['empresaId'] as String? ?? 'copperfio';
    } catch (e) {
      debugPrint('Erro ao obter empresaId: $e');
      return 'copperfio';
    }
  }

  Future<void> loadEfficiency() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final empresaId = _getEmpresaId();
      debugPrint('ProductionEfficiencyViewModel.loadEfficiency empresaId=$empresaId');
      final result = await _firestoreService.getProductionEfficiency(empresaId);
      
      _efficiency = (result['efficiency'] as num?)?.toDouble() ?? 83.5;
      _variation = (result['variation'] as num?)?.toDouble() ?? 2.1;
      _feedbackCount = (result['feedbackCount'] as num?)?.toInt() ?? 0;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erro ao carregar eficiência: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<Map<String, dynamic>> getEfficiencyStream() {
    final empresaId = _getEmpresaId();
    debugPrint('ProductionEfficiencyViewModel.getEfficiencyStream empresaId=$empresaId');
    return _firestoreService.getProductionEfficiencyStream(empresaId);
  }
}

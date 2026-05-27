import 'package:flutter/foundation.dart';
import 'package:projeto_integrado/data/models/feedback_model.dart';
import 'package:projeto_integrado/services/auth_service.dart';
import 'package:projeto_integrado/services/firestore_service.dart';

class MeusFeedbacksViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String _currentUserId = '';
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedStatus = 'Todos';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String get currentUserId => _currentUserId;

  Future<void> loadCurrentUserId() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _authService.currentUserId;
      if (userId == null || userId.isEmpty) {
        _error = 'Usuário não autenticado.';
      } else {
        _currentUserId = userId;
      }
    } catch (e) {
      _error = 'Erro ao carregar usuário: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<FeedbackModel>> userFeedbacksStream() {
    if (_currentUserId.isEmpty) {
      return Stream.value([]);
    }

    return _firestoreService
        .getFeedbacksByUserStream(_currentUserId)
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FeedbackModel.fromFirestore(doc))
              .toList(),
        );
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  List<FeedbackModel> filterFeedbacks(List<FeedbackModel> feedbacks) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = feedbacks.where((feedback) {
      final matchesSearch =
          query.isEmpty ||
          feedback.mensagem.toLowerCase().contains(query) ||
          feedback.lote.toLowerCase().contains(query);

      final effectiveStatus = _getEffectiveStatus(feedback);
      final matchesStatus =
          _selectedStatus == 'Todos' || effectiveStatus == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    filtered.sort((a, b) => b.data.compareTo(a.data));
    return filtered;
  }

  bool _isNewFeedback(FeedbackModel feedback) {
    final difference = DateTime.now().difference(feedback.data);
    return feedback.status.toLowerCase() == 'novo' && difference.inDays < 2;
  }

  String _getEffectiveStatus(FeedbackModel feedback) {
    if (feedback.status.toLowerCase() == 'novo' && !_isNewFeedback(feedback)) {
      return 'pendente';
    }
    return feedback.status.toLowerCase();
  }
}

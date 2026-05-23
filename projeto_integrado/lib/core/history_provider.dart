import 'package:flutter/material.dart';
import 'package:projeto_integrado/data/models/history_item_model.dart';
import 'package:projeto_integrado/services/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _historyService = const HistoryService();
  final List<HistoryItemModel> _history = [];
  bool _isLoading = false;

  HistoryProvider() {
    _loadHistory();
  }

  bool get isLoading => _isLoading;

  List<HistoryItemModel> get history => List.unmodifiable(_history);

  Future<void> _loadHistory() async {
    _isLoading = true;
    notifyListeners();
    _history.clear();
    _history.addAll(await _historyService.loadHistory());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logAction({
    required String type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final item = HistoryItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
    _history.insert(0, item);
    if (_history.length > HistoryService.maxItems) {
      _history.removeRange(HistoryService.maxItems, _history.length);
    }
    await _historyService.saveHistory(_history);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _historyService.clearHistory();
    notifyListeners();
  }
}

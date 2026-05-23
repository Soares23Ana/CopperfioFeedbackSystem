import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:projeto_integrado/data/models/history_item_model.dart';

class HistoryService {
  static const String storageKey = 'app_history_items';
  static const int maxItems = 200;

  const HistoryService();

  Future<List<HistoryItemModel>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(storageKey) ?? [];

    final items = <HistoryItemModel>[];
    for (final rawItem in rawList) {
      try {
        final map = jsonDecode(rawItem) as Map<String, dynamic>;
        items.add(HistoryItemModel.fromMap(map));
      } catch (_) {
        continue;
      }
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> saveHistory(List<HistoryItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = items.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList(storageKey, rawList);
  }

  Future<void> addAction({
    required String type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final items = await loadHistory();
    final item = HistoryItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
    items.insert(0, item);
    if (items.length > maxItems) {
      items.removeRange(maxItems, items.length);
    }
    await saveHistory(items);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}

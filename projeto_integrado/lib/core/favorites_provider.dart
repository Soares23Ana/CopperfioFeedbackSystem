import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projeto_integrado/data/models/product_model.dart';
import 'package:projeto_integrado/services/history_service.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _storageKey = 'saved_favorite_products';

  final List<ProductModel> _favorites = [];

  FavoritesProvider() {
    _loadFavorites();
  }

  List<ProductModel> get favorites => List.unmodifiable(_favorites);

  String _uniqueKey(ProductModel product) {
    if (product.pdfUrl.isNotEmpty) return product.pdfUrl;
    return '${product.title}|${product.imageUrl}';
  }

  bool isFavorite(ProductModel product) {
    final key = _uniqueKey(product);
    return _favorites.any((item) => _uniqueKey(item) == key);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_storageKey) ?? [];
    _favorites.clear();
    for (final rawItem in rawItems) {
      try {
        final map = jsonDecode(rawItem) as Map<String, dynamic>;
        _favorites.add(ProductModel.fromMap(map));
      } catch (_) {
        continue;
      }
    }
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = _favorites.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList(_storageKey, rawItems);
  }

  Future<void> toggleFavorite(ProductModel product) async {
    final alreadyFavorite = isFavorite(product);
    if (alreadyFavorite) {
      final key = _uniqueKey(product);
      _favorites.removeWhere((item) => _uniqueKey(item) == key);
    } else {
      _favorites.add(product);
    }
    await _saveFavorites();
    notifyListeners();

    await const HistoryService().addAction(
      type: alreadyFavorite ? 'item_removido' : 'item_salvo',
      title: alreadyFavorite ? 'Item removido dos salvos' : 'Item salvo',
      description: '${product.title} foi ${alreadyFavorite ? 'removido dos itens salvos' : 'adicionado aos itens salvos'}.',
      metadata: product.toMap(),
    );
  }

  Future<void> removeFavorite(ProductModel product) async {
    final key = _uniqueKey(product);
    _favorites.removeWhere((item) => _uniqueKey(item) == key);
    await _saveFavorites();
    notifyListeners();

    await const HistoryService().addAction(
      type: 'item_removido',
      title: 'Item removido dos salvos',
      description: '${product.title} foi removido dos itens salvos.',
      metadata: product.toMap(),
    );
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    await _saveFavorites();
    notifyListeners();

    await const HistoryService().addAction(
      type: 'item_removido',
      title: 'Itens salvos limpos',
      description: 'Todos os itens salvos foram removidos.',
    );
  }
}

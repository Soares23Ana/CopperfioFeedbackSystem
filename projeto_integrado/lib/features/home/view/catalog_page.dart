import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/core/favorites_provider.dart';
import 'package:projeto_integrado/core/theme_provider.dart';
import 'package:projeto_integrado/data/models/product_model.dart';
import 'package:projeto_integrado/data/repositories/product_repository.dart';
import '../../chat/view/contact_page.dart';
import 'product_detail_page.dart';

class CatalogPage extends StatefulWidget {
  CatalogPage({super.key});

  final ProductRepository _repository = ProductRepository();

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<ProductModel> _products = [];
  final List<ProductModel> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  String _assetFromUrl(String url) {
    try {
      if (url.startsWith('assets/')) return url;
      final name = Uri.parse(url).pathSegments.last;

      // Map legacy remote basenames (01g.jpg .. 11g.jpg) to local filenames
      const legacyMap = {
        '01g.jpg': '000130.png',
        '02g.jpg': '000108.png',
        '03g.jpg': '000144.png',
        '04g.jpg': '000202.png',
        '05g.jpg': '000356_copia.png',
        '06g.jpg': '000356_copia.png',
        '07g.jpg': '000234.png',
        '08g.jpg': '000301.png',
        '09g.jpg': '000247.png',
        '10g.jpg': '000046.png',
        '11g.jpg': '000217.png',
      };

      if (legacyMap.containsKey(name)) {
        return 'assets/images/produtos_copperfio/${legacyMap[name]}';
      }

      return 'assets/images/$name';
    } catch (_) {
      return 'assets/images/icon.png';
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await widget._repository.fetchProducts();
      setState(() {
        _products.addAll(products);
        _filteredProducts.addAll(products);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _filterProducts(_searchController.text);
  }

  String _normalizeText(String value) {
    var text = value.toLowerCase().trim();
    const accents = 'áàãâäéèêëíìîïóòõôöúùûüçñ';
    const replacements = 'aaaaaeeeeiiiiooooouuuucn';
    for (var i = 0; i < accents.length; i++) {
      text = text.replaceAll(accents[i], replacements[i]);
    }
    return text;
  }

  void _filterProducts(String query) {
    final normalizedQuery = _normalizeText(query);
    final tokens = normalizedQuery
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();

    setState(() {
      if (tokens.isEmpty) {
        _filteredProducts
          ..clear()
          ..addAll(_products);
        return;
      }

      _filteredProducts
        ..clear()
        ..addAll(
          _products.where((item) {
            final itemText = _normalizeText('${item.title} ${item.subtitle}');
            return tokens.every(itemText.contains);
          }),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Busca por produto',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildProductList(context)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactPage()),
              );
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: const Text(
              'Fazer pedido',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C1818),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: SelectableText(
          'Erro ao carregar produtos: $_error',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return const Center(
        child: SelectableText(
          'Nenhum produto encontrado.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final item = _filteredProducts[index];
        return Consumer<FavoritesProvider>(
          builder: (context, favorites, _) {
            final isSaved = favorites.isFavorite(item);
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(product: item),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          child: SizedBox(
                            height: 140,
                            width: double.infinity,
                            child: item.imageUrl.startsWith('assets/')
                                ? Image.asset(
                                    item.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Image.network(
                                    item.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Network failed — fall back to bundled asset
                                      final asset = _assetFromUrl(
                                        item.imageUrl,
                                      );
                                      debugPrint(
                                        'Image.network failed for ${item.imageUrl}: $error',
                                      );
                                      debugPrint(
                                        'Falling back to asset: $asset',
                                      );
                                      return Image.asset(
                                        asset,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              isSaved ? Icons.favorite : Icons.favorite_outline,
                              color: isSaved
                                  ? Colors.red
                                  : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black54),
                            ),
                            iconSize: 22,
                            onPressed: () async {
                              await favorites.toggleFavorite(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isSaved
                                        ? 'Removido dos itens salvos'
                                        : 'Adicionado aos itens salvos',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText(
                            item.title,
                            maxLines: 3,
                            onTap: () {},
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            item.subtitle,
                            maxLines: 2,
                            onTap: () {},
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color?.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

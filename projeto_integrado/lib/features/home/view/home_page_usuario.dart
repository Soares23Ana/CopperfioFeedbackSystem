import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme_provider.dart';
import '../../profile/viewmodel/current_user_viewmodel.dart';
import 'catalog_page.dart';
import '../../chat/view/client_chat_home_page.dart';
import '../../dashboard/view/feedback_page.dart';
import '../../chamados/view/ticket_create_page.dart';
import '../../auth/view/login_page.dart';
import '../../profile/view/perfil_page.dart';

class HomePageUsuario extends StatefulWidget {
  const HomePageUsuario({super.key});

  @override
  State<HomePageUsuario> createState() => _HomePageUsuarioState();
}

class _HomePageUsuarioState extends State<HomePageUsuario> {
  final PageController _pageController = PageController();
  final List<String> _images = [
    'https://i.imgur.com/ZC2OCaF.jpg',
    'https://i.imgur.com/A0OPEqF.jpg',
    'https://i.imgur.com/fPx9DLu.jpg',
    'https://i.imgur.com/aIrRyPa.jpg',
  ];
  Timer? _carouselTimer;
  int _currentPage = 0;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrentUserViewModel>().loadUserData();
      _startAutoScroll();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrentUserViewModel>().loadUserData();
    });
  }

  void _startAutoScroll() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients) return;
      _currentPage = (_currentPage + 1) % _images.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  String _localAssetFromUrl(String url) {
    try {
      final name = Uri.parse(url).pathSegments.last;
      return 'assets/images/$name';
    } catch (_) {
      return 'assets/images/icon.png';
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final primaryColor = const Color(0xFF8C1D18);
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double availableHeight =
        MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.vertical -
        260;
    final double carouselSize = min(screenWidth * 0.82, availableHeight * 0.88);
    final double redBackgroundHeight = carouselSize + 110;

    return Scaffold(
      backgroundColor: bgColor,
      drawer: _buildDrawer(primaryColor, isDark),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'COPPERFIO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Consumer<CurrentUserViewModel>(
                      builder: (context, userViewModel, _) {
                        final userName = userViewModel.displayName;
                        return Text(
                          'Bem-vindo,\n$userName',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Center Image Carousel in Circular Frame
                    SizedBox(
                      height: redBackgroundHeight + 16,
                      width: double.infinity,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: -24,
                            right: -24,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              height: redBackgroundHeight,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ),
                          Positioned(
                            top: (redBackgroundHeight - carouselSize) / 2,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: carouselSize,
                                height: carouselSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(
                                        ((isDark ? 0.3 : 0.15) * 255).round(),
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: _images.length,
                                    onPageChanged: (page) {
                                      _currentPage = page;
                                    },
                                    itemBuilder: (context, index) {
                                      final image = Image.network(
                                        _images[index],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.grey,
                                                    ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              final assetPath =
                                                  _localAssetFromUrl(
                                                    _images[index],
                                                  );
                                              return Image.asset(
                                                assetPath,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              );
                                            },
                                      );

                                      return Transform.scale(
                                        scale: index == 1 ? 1.38 : 1.18,
                                        child: image,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),

              // Buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CatalogPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        'CATÁLOGO & FICHA TÉCNICA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.description, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(
                    color: primaryColor.withAlpha((0.3 * 255).round()),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        'AVALIAR EXPERIÊNCIA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.star_border, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(
                ((isDark ? 0.2 : 0.05) * 255).round(),
              ),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _bottomNavIndex.clamp(0, 2),
          selectedItemColor: primaryColor,
          unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
          backgroundColor: cardColor,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
          elevation: 0,
          onTap: (index) {
            setState(() {
              _bottomNavIndex = index;
            });
            if (index == 1) {
              // Suporte
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TicketCreatePage()),
              );
            } else if (index == 2) {
              // Perfil
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfilPage()),
              );
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? primaryColor.withAlpha((0.2 * 255).round())
                        : const Color(0xFFF5EBEB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.home, color: primaryColor, size: 20),
                ),
              ),
              label: 'HOME',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.headset_mic),
              ),
              label: 'SUPORTE',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person),
              ),
              label: 'PERFIL',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(Color primaryColor, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: primaryColor,
              child: Row(
                children: const [
                  Icon(Icons.factory, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'COPPERFIO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDrawerItem('Perfil', Icons.person_outline, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfilPage()),
              );
            }, isDark),
            _buildDrawerItem('Enviar Feedback', Icons.feedback_outlined, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackPage()),
              );
            }, isDark),
            _buildDrawerItem('Criar Chamado', Icons.support_agent, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TicketCreatePage()),
              );
            }, isDark),
            _buildDrawerItem('Chat com Suporte', Icons.chat_bubble_outline, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientChatHomePage()),
              );
            }, isDark),
            _buildDrawerItem('Catálogo', Icons.menu_book, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CatalogPage()),
              );
            }, isDark),
            const Spacer(),
            InkWell(
              onTap: () async {
                const email = 'contato@copperfio.com.br';
                await Clipboard.setData(const ClipboardData(text: email));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.fromLTRB(16, 0, 16, 100),
                      content: Text(
                        'E-mail copiado para a área de transferência.',
                      ),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                child: Text(
                  'Caso tenha dúvidas, entre em contato por este email: contato@copperfio.com.br',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const Divider(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildDrawerItem(
                'Sair',
                Icons.logout,
                () async {
                  await context.read<CurrentUserViewModel>().signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                isDark,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    Color? color,
  }) {
    final defaultColor = isDark ? Colors.white70 : Colors.black87;
    final itemColor = color ?? defaultColor;
    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        title,
        style: TextStyle(color: itemColor, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}

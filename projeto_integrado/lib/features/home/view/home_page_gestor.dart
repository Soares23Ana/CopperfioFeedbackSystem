import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../profile/viewmodel/historico_viewmodel.dart';
import '../../../core/theme_provider.dart';
import '../../profile/viewmodel/current_user_viewmodel.dart';
import '../../auth/view/login_page.dart';
import '../../dashboard/view/dashboard_page.dart';
import '../../dashboard/view/feedbacks_page.dart';
import '../../dashboard/view/alertas_page.dart';
import '../../chamados/view/chamados_page.dart';
import '../../profile/view/historico_page.dart';
import '../../profile/view/historico_relatorio_page.dart';
import '../../profile/view/perfil_gestor_page.dart';
import 'pedidos_gestor_page.dart';
import '../viewmodel/production_efficiency_viewmodel.dart';

class HomePageGestor extends StatefulWidget {
  const HomePageGestor({super.key});

  @override
  State<HomePageGestor> createState() => _HomePageGestorState();
}

class _HomePageGestorState extends State<HomePageGestor> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrentUserViewModel>().loadUserData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrentUserViewModel>().loadUserData();
    });
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 320),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation =
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              );
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  Widget _buildIAReportsPreview(
    BuildContext context,
    Color cardColor,
    Color textColor,
    Color primaryColor,
    bool isDark,
  ) {
    return Consumer<CurrentUserViewModel>(
      builder: (context, userViewModel, _) {
        final companyId = userViewModel.companyId;

        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Histórico de relatórios IA',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoricoPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Acessar todos',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: context.read<HistoricoViewModel>().getRelatorios(
                  companyId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Erro ao carregar histórico.',
                      style: TextStyle(color: textColor),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 140,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final docs = List<QueryDocumentSnapshot>.from(
                    snapshot.data?.docs ?? [],
                  );
                  docs.sort((a, b) {
                    final aDate =
                        (a.data() as Map<String, dynamic>?)?['criadoEm'];
                    final bDate =
                        (b.data() as Map<String, dynamic>?)?['criadoEm'];

                    if (aDate == null && bDate == null) return 0;
                    if (aDate == null) return 1;
                    if (bDate == null) return -1;

                    return bDate.compareTo(aDate);
                  });

                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        'Nenhum relatório IA encontrado.',
                        style: TextStyle(
                          color: textColor.withAlpha((0.85 * 255).round()),
                        ),
                      ),
                    );
                  }

                  final previewDocs = docs.take(3).toList();

                  return Column(
                    children: previewDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>? ?? {};
                      final metadata =
                          data['metadata'] as Map<String, dynamic>? ?? {};
                      final totalFeedbacks =
                          metadata['totalFeedbacks']?.toString() ?? '—';
                      final filtroTipo =
                          metadata['filtroTipo'] ?? 'Todos os tipos';
                      final createdAt = (data['criadoEm'])?.toDate();
                      final createdText = createdAt != null
                          ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}'
                          : 'Sem data';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            final relatorio =
                                data['relatorio'] as Map<String, dynamic>? ??
                                {};
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HistoricoRelatorioPage(
                                  relatorioData: relatorio,
                                  metadata: metadata,
                                  createdText: createdText,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withAlpha((0.06 * 255).round())
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Feedbacks: $totalFeedbacks',
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        filtroTipo.toString(),
                                        style: TextStyle(
                                          color: textColor.withAlpha(
                                            (0.8 * 255).round(),
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        createdText,
                                        style: TextStyle(
                                          color: textColor.withAlpha(
                                            (0.65 * 255).round(),
                                          ),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
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
            const SizedBox(height: 24),
            _buildDrawerItem('Perfil', Icons.person_outline, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfilGestorPage()),
              );
            }, isDark),
            _buildDrawerItem('Dashboard', Icons.dashboard, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            }, isDark),
            _buildDrawerItem('Alertas', Icons.warning, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertasPage()),
              );
            }, isDark),
            _buildDrawerItem('Feedbacks', Icons.feedback, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbacksPage()),
              );
            }, isDark),
            _buildDrawerItem('Chamados', Icons.support_agent, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChamadosPage()),
              );
            }, isDark),
            _buildDrawerItem('Pedidos', Icons.shopping_cart_outlined, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PedidosGestorPage()),
              );
            }, isDark),
            _buildDrawerItem('Histórico de relatórios IA', Icons.bar_chart, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoricoPage()),
              );
            }, isDark),
            const Spacer(),
            const Divider(height: 1),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF8C1D18),
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
    final itemColor = color ?? (isDark ? Colors.white70 : Colors.black87);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        final primaryColor = const Color(0xFF8C1D18);
        final bgColor = isDark
            ? const Color(0xFF121212)
            : const Color(0xFFFAFAFA);
        final textColor = isDark ? Colors.white : Colors.black87;
        final gridCardColor = isDark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFFBEAEA);
        final whiteCardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

        return Scaffold(
          backgroundColor: bgColor,
          drawer: _buildDrawer(primaryColor, isDark),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar
                    Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.factory,
                                  color: primaryColor,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'GESTOR',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: themeProvider.toggleTheme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Header Area
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SISTEMA OPERACIONAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Consumer<CurrentUserViewModel>(
                      builder: (context, userViewModel, _) {
                        final gestorName = userViewModel.displayName;
                        return Text(
                          'Bem-vindo(a),\n$gestorName',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    const SizedBox(height: 24),

                    // Big Stats Card - Production Efficiency KPI
                    Consumer<ProductionEfficiencyViewModel>(
                      builder: (context, efficiencyVm, _) {
                        return StreamBuilder<Map<String, dynamic>>(
                          stream: efficiencyVm.getEfficiencyStream(),
                          initialData: {
                            'efficiency': 83.5,
                            'variation': 2.1,
                            'feedbackCount': 0,
                          },
                          builder: (context, snapshot) {
                            final efficiency =
                                snapshot.data?['efficiency'] as double? ?? 83.5;
                            final variation =
                                snapshot.data?['variation'] as double? ?? 2.1;

                            return Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withAlpha(
                                      ((isDark ? 0.2 : 0.4) * 255).round(),
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -20,
                                    bottom: -20,
                                    child: Icon(
                                      Icons.precision_manufacturing,
                                      size: 120,
                                      color: Colors.white.withAlpha(
                                        (0.1 * 255).round(),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'EFICIÊNCIA DE PRODUÇÃO',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(
                                            (0.8 * 255).round(),
                                          ),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            efficiency.toStringAsFixed(1),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 48,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -1,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '%',
                                            style: TextStyle(
                                              color: Colors.white.withAlpha(
                                                (0.8 * 255).round(),
                                              ),
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Icon(
                                            variation >= 0
                                                ? Icons.trending_up
                                                : Icons.trending_down,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${variation >= 0 ? '+' : ''}${variation.toStringAsFixed(1)}% desde o último turno',
                                            style: TextStyle(
                                              color: Colors.white.withAlpha(
                                                (0.9 * 255).round(),
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Grid Options
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      children: [
                        _buildGridCard(
                          context,
                          title: 'DASHBOARD',
                          subtitle: 'Métricas em tempo real',
                          icon: Icons.dashboard,
                          page: const DashboardPage(),
                          cardColor: gridCardColor,
                          textColor: textColor,
                          primaryColor: primaryColor,
                        ),
                        _buildGridCard(
                          context,
                          title: 'FEEDBACKS',
                          subtitle: '8 novos relatos',
                          icon: Icons.feedback,
                          page: const FeedbacksPage(),
                          cardColor: gridCardColor,
                          textColor: textColor,
                          primaryColor: primaryColor,
                        ),
                        _buildGridCard(
                          context,
                          title: 'ALERTAS',
                          subtitle: '2 Manutenções',
                          icon: Icons.warning,
                          page: const AlertasPage(),
                          cardColor: gridCardColor,
                          textColor: textColor,
                          primaryColor: primaryColor,
                        ),
                        _buildGridCard(
                          context,
                          title: 'CHAMADOS',
                          subtitle: 'Setor Operacional',
                          icon: Icons.support_agent,
                          page: const ChamadosPage(),
                          cardColor: gridCardColor,
                          textColor: textColor,
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // IA Reports Preview below dashboard options
                    _buildIAReportsPreview(
                      context,
                      gridCardColor,
                      textColor,
                      primaryColor,
                      isDark,
                    ),
                    const SizedBox(height: 24),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).round()),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex.clamp(0, 3),
              selectedItemColor: primaryColor,
              unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
              backgroundColor: whiteCardColor,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
              elevation: 0,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });

                if (index == 0) return;

                if (index == 1) {
                  _navigateToPage(context, const FeedbacksPage());
                } else if (index == 2) {
                  _navigateToPage(context, const AlertasPage());
                } else if (index == 3) {
                  _navigateToPage(context, const ChamadosPage());
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.dashboard),
                  ),
                  label: 'DASHBOARD',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.chat_bubble_outline),
                  ),
                  label: 'FEEDBACKS',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.notifications_none),
                  ),
                  label: 'ALERTAS',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.support_agent),
                  ),
                  label: 'CHAMADOS',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget page,
    required Color cardColor,
    required Color textColor,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 160),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: primaryColor, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.5,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withAlpha((0.5 * 255).round()),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

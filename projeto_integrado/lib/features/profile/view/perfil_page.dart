import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:projeto_integrado/core/theme_provider.dart';
import 'package:projeto_integrado/features/profile/viewmodel/current_user_viewmodel.dart';
import 'package:projeto_integrado/features/profile/view/atualizar_perfil_page.dart';
import 'package:projeto_integrado/features/profile/view/meus_feedbacks_page.dart';
import 'package:projeto_integrado/features/profile/view/ajuda_page.dart';
import 'package:projeto_integrado/features/profile/view/itens_salvos_page.dart';
import 'package:projeto_integrado/features/profile/view/historico_geral_page.dart';
import 'package:projeto_integrado/features/profile/view/notificacoes_page.dart';
import 'package:projeto_integrado/features/profile/view/pedidos_history_page.dart';
import 'package:projeto_integrado/features/profile/view/seu_nivel_page.dart';
import 'package:projeto_integrado/features/profile/viewmodel/seu_nivel_viewmodel.dart';
import 'package:projeto_integrado/features/auth/view/login_page.dart';
import 'package:projeto_integrado/features/chamados/view/user_chamados_page.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final headerColor = isDark ? Theme.of(context).colorScheme.primary : const Color(0xFF9C1818);
    final userViewModel = context.watch<CurrentUserViewModel>();
    final nivelVm = context.watch<SeuNivelViewModel>();
    final data = userViewModel.userData ?? {};
    final currentUserEmail = userViewModel.currentUser?.email;

    if (!nivelVm.isLoading && !nivelVm.hasLoaded) {
      Future.microtask(() => context.read<SeuNivelViewModel>().loadUserLevel());
    }

    if (!userViewModel.isLoading && !userViewModel.hasLoaded) {
      Future.microtask(() => context.read<CurrentUserViewModel>().loadUserData(force: true));
    }

    if (userViewModel.isLoading && userViewModel.userData == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: headerColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Perfil', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: headerColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: isDark ? 'Modo Claro' : 'Modo Noturno',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header com avatar
            Container(
              color: headerColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: data['fotoPerfil'] != null && (data['fotoPerfil'] as String).isNotEmpty
                            ? ClipOval(
                                child: (() {
                                  final fotoPerfil = data['fotoPerfil'] as String;
                                  if (fotoPerfil.startsWith('data:image')) {
                                    // Base64 image
                                    try {
                                      return Image.memory(
                                        base64Decode(fotoPerfil.split(',').last),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                                size: 36,
                                                color: Color(0xFF9C1818),
                                              );
                                            },
                                      );
                                    } catch (e) {
                                      return const Icon(
                                        Icons.person,
                                        size: 36,
                                        color: Color(0xFF9C1818),
                                      );
                                    }
                                  } else {
                                    // Network URL
                                    return Image.network(
                                      fotoPerfil,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.person,
                                              size: 36,
                                              color: Color(0xFF9C1818),
                                            );
                                          },
                                    );
                                  }
                                })(),
                              )
                            : const Icon(
                                Icons.person,
                                size: 36,
                                color: Color(0xFF9C1818),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userViewModel.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['empresa'] as String? ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                if ((currentUserEmail ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    currentUserEmail!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    nivelVm.isLoading ? 'Carregando...' : nivelVm.currentLevel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AtualizarPerfilPage(),
                            ),
                          ).then((_) {
                            context.read<CurrentUserViewModel>().refreshUserData();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Cards de �cones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconCard('Pedidos', Icons.shopping_bag, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PedidosHistoryPage(),
                      ),
                    );
                  }),
                  _buildIconCard('FeedBacks', Icons.comment, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MeusFeedbacksPage(),
                      ),
                    );
                  }),
                  _buildIconCard('Ajuda', Icons.help, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AjudaPage()),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Minha Conta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minha Conta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem('Itens Salvos', Icons.favorite, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ItensSalvosPage()),
                          );
                        }),
                        _buildMenuDivider(),
                        _buildMenuItem('Histórico', Icons.history, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HistoricoGeralPage()),
                          );
                        }),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          'Notificações',
                          Icons.notifications,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NotificacoesPage()),
                            );
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          'Meus Chamados',
                          Icons.list_alt,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UserChamadosPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Seu N�vel e Sair
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.trending_up,
                        color: Color(0xFFB02820),
                      ),
                      title: Text(
                        'Seu Nível',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SeuNivelPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Color(0xFFB02820),
                      ),
                      title: const Text(
                        'Sair da Conta',
                        style: TextStyle(color: Color(0xFFB02820)),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Sair da Conta?'),
                            content: const Text('Deseja realmente sair?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await userViewModel.signOut();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: const Text(
                                  'Sair',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildIconCard(String label, IconData icon, VoidCallback onTap) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFB02820),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String label, IconData icon, VoidCallback onTap) {
    return Builder(
      builder: (context) => ListTile(
        leading: Icon(icon, color: const Color(0xFFB02820), size: 24),
        title: Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Builder(
      builder: (context) => Divider(
        height: 1,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
        indent: 16,
        endIndent: 16,
      ),
    );
  }
}

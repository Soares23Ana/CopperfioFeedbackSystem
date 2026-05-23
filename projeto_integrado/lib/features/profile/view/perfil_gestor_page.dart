import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../auth/view/login_page.dart';
import '../../chamados/view/chamados_page.dart';
import '../../../core/theme_provider.dart';
import 'package:projeto_integrado/features/profile/viewmodel/current_user_viewmodel.dart';
import 'atualizar_perfil_page.dart';
import 'historico_page.dart';
import 'notificacoes_page.dart';
import '../../dashboard/view/alertas_page.dart';
import '../../home/view/add_user_page.dart';

class PerfilGestorPage extends StatelessWidget {
  const PerfilGestorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final headerColor = isDark ? Theme.of(context).colorScheme.primary : const Color(0xFF9C1818);
    final userViewModel = context.watch<CurrentUserViewModel>();
    final data = userViewModel.userData ?? {};

    if (userViewModel.isLoading && userViewModel.userData == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: headerColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Perfil Gestor', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: themeProvider.toggleTheme,
              tooltip: isDark ? 'Modo Claro' : 'Modo Noturno',
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
        title: const Text('Perfil Gestor', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: themeProvider.toggleTheme,
            tooltip: isDark ? 'Modo Claro' : 'Modo Noturno',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: headerColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              color: Colors.black.withAlpha((0.2 * 255).round()),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: (() {
                                final fotoPerfil = data['fotoPerfil'];
                                if (fotoPerfil != null && fotoPerfil.toString().isNotEmpty) {
                                  final fotoPerfilStr = fotoPerfil.toString();
                                  if (fotoPerfilStr.startsWith('data:image')) {
                                    // Base64 image
                                    try {
                                      return ClipOval(
                                        child: Image.memory(
                                          base64Decode(
                                              fotoPerfilStr.split(',').last),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.person,
                                                  size: 36,
                                                  color: Color(0xFF9C1818),
                                                );
                                              },
                                        ),
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
                                    return ClipOval(
                                      child: Image.network(
                                        fotoPerfilStr,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                                size: 36,
                                                color: Color(0xFF9C1818),
                                              );
                                            },
                                      ),
                                    );
                                  }
                                }
                                return const Icon(
                                  Icons.person,
                                  size: 36,
                                  color: Color(0xFF9C1818),
                                );
                              })(),
                            ),
                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: (() {
                                final active = data['ativo'] == true;
                                return Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: active ? Colors.green : Colors.grey,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                );
                              })(),
                            ),
                          ],
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
                                  data['nome'] as String? ?? 'Gestor',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['cargo'] as String? ?? 'Gestor Operacional',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                if ((data['email'] as String?)?.isNotEmpty ?? false) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    data['email'] as String,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AtualizarPerfilPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconCard('Chamados', Icons.support_agent, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChamadosPage()),
                    );
                  }),
                  _buildIconCard('Alertas', Icons.warning, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AlertasPage()),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações profissionais',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withAlpha((0.08 * 255).round()),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.business, 'Empresa', data['empresa'] as String? ?? data['empresaId'] as String? ?? 'Copperfio'),
                        _buildInfoDivider(context),
                        _buildInfoRow(Icons.badge, 'Cargo', data['cargo'] as String? ?? 'Gestor Operacional'),
                        _buildInfoDivider(context),
                        _buildInfoRow(Icons.location_city, 'Setor', data['setor'] as String? ?? data['departamento'] as String? ?? 'Produção'),
                        _buildInfoDivider(context),
                        _buildInfoRow(Icons.confirmation_number, 'Matrícula', data['matricula'] as String? ?? data['idInterno'] as String? ?? 'G-204'),
                        _buildInfoDivider(context),
                        _buildInfoRow(Icons.email, 'Email corporativo', data['email'] as String? ?? 'Não informado'),
                        _buildInfoDivider(context),
                        _buildInfoRow(Icons.phone, 'Telefone corporativo', data['telefone'] as String? ?? data['celular'] as String? ?? 'Não informado'),
                        _buildInfoDivider(context),
                        _buildInfoRow(Icons.corporate_fare, 'CNPJ', data['cnpj'] as String? ?? 'Não informado'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                          color: Theme.of(context).shadowColor.withAlpha((0.08 * 255).round()),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          'Adm permissões',
                          Icons.admin_panel_settings,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddUserPage()),
                            );
                          },
                        ),
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
                          'Relatórios',
                          Icons.bar_chart,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HistoricoPage()),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
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
                                MaterialPageRoute(builder: (_) => const LoginPage()),
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
          color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
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
        color: Theme.of(context).colorScheme.onSurface.withAlpha((0.2 * 255).round()),
        indent: 16,
        endIndent: 16,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFB02820), size: 24),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 13, height: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  Widget _buildInfoDivider(BuildContext context) {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.onSurface.withAlpha((0.2 * 255).round()),
      indent: 16,
      endIndent: 16,
    );
  }

}

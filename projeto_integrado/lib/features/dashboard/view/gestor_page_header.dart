import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme_provider.dart';

class GestorPageHeader extends StatelessWidget {
  final String pageTitle;
  final String subtitle;
  final bool dashboardSelected;
  final bool feedbacksSelected;
  final bool alertasSelected;
  final bool chamadosSelected;
  final VoidCallback onDashboard;
  final VoidCallback onFeedbacks;
  final VoidCallback onAlertas;
  final VoidCallback onChamados;
  final VoidCallback? onLogout;

  const GestorPageHeader({
    super.key,
    required this.pageTitle,
    required this.subtitle,
    required this.dashboardSelected,
    required this.feedbacksSelected,
    required this.alertasSelected,
    required this.chamadosSelected,
    required this.onDashboard,
    required this.onFeedbacks,
    required this.onAlertas,
    required this.onChamados,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/copperfio_logo.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.apartment,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pageTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                    ),
                    onPressed: themeProvider.toggleTheme,
                    tooltip: themeProvider.isDarkMode ? 'Modo Claro' : 'Modo Noturno',
                  ),
                  if (onLogout != null)
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: onLogout,
                      tooltip: 'Sair',
                    ),
                ],
              ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _GestorTab(
                      label: 'Dashboard',
                      selected: dashboardSelected,
                      onTap: onDashboard,
                    ),
                    const SizedBox(width: 10),
                    _GestorTab(
                      label: 'Feedbacks',
                      selected: feedbacksSelected,
                      onTap: onFeedbacks,
                    ),
                    const SizedBox(width: 10),
                    _GestorTab(
                      label: 'Alertas',
                      selected: alertasSelected,
                      onTap: onAlertas,
                    ),
                    const SizedBox(width: 10),
                    _GestorTab(
                      label: 'Chamados',
                      selected: chamadosSelected,
                      onTap: onChamados,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GestorTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GestorTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withAlpha((0.35 * 255).round())),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF9C1818) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

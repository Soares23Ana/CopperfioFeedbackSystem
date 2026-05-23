import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/core/theme_provider.dart';
import 'package:projeto_integrado/features/home/view/catalog_page.dart';
import 'package:projeto_integrado/features/profile/view/ajuda_page.dart';
import 'package:projeto_integrado/features/profile/viewmodel/notificacoes_viewmodel.dart';
import 'package:projeto_integrado/features/dashboard/view/feedbacks_page.dart';
import 'package:projeto_integrado/features/chamados/view/chamados_page.dart';
import 'package:projeto_integrado/features/profile/view/pedidos_history_page.dart';
import 'package:projeto_integrado/services/auth_service.dart';

class NotificacoesPage extends StatelessWidget {
  const NotificacoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final notificacoesViewModel = Provider.of<NotificacoesViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<NotificacaoItem>>(
        stream: notificacoesViewModel.obterNotificacoes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar notificações: ${snapshot.error}',
              ),
            );
          }

          final notificacoes = snapshot.data ?? [];

          if (notificacoes.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma notificação',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withAlpha((0.6 * 255).round())
                      : Colors.black.withAlpha((0.6 * 255).round()),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notificacoes.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notificacoes[index];
              return _buildNotificationCard(context, notification, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificacaoItem notification,
    bool isDark,
  ) {
    final iconColor = const Color(0xFF9C1818);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: iconColor.withAlpha((0.15 * 255).round()),
          child: Icon(
            _getIconForType(notification.icon),
            color: iconColor,
            size: 26,
          ),
        ),
        title: Text(
          notification.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(notification.subtitulo, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha((0.12 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.status,
                    style: const TextStyle(
                      color: Color(0xFF9C1818),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _navigateToPage(context, notification),
      ),
    );
  }

  void _navigateToPage(BuildContext context, NotificacaoItem notification) {
    Widget destinationPage;

    switch (notification.tipo) {
      case 'feedback':
        destinationPage = const FeedbacksPage();
        break;
      case 'chamado':
        destinationPage = const ChamadosPage();
        break;
      case 'pedido':
        destinationPage = const PedidosHistoryPage();
        break;
      case 'catalogo':
        destinationPage = CatalogPage();
        break;
      case 'app_error':
        destinationPage = const AjudaPage();
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => destinationPage));
  }

  IconData _getIconForType(IconType type) {
    switch (type) {
      case IconType.feedback:
        return Icons.feedback;
      case IconType.chamado:
        return Icons.support_agent;
      case IconType.pedido:
        return Icons.shopping_bag;
      case IconType.catalogo:
        return Icons.inventory_2;
      case IconType.appError:
        return Icons.error_outline;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '${mins}m atrás';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h atrás';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '${days}d atrás';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

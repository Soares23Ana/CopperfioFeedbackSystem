import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/core/history_provider.dart';
import 'package:projeto_integrado/core/theme_provider.dart';

class HistoricoGeralPage extends StatelessWidget {
  const HistoricoGeralPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de ações'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Limpar histórico',
            onPressed: () {
              final historyProvider = context.read<HistoryProvider>();
              if (historyProvider.history.isEmpty) {
                return;
              }
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Limpar histórico'),
                    content: const Text('Deseja apagar todo o histórico de ações?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await historyProvider.clearHistory();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Limpar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          if (historyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final historyItems = historyProvider.history;
          if (historyItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Nenhuma ação registrada ainda. As ações do app serão salvas aqui automaticamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.75),
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: historyItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = historyItems[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    child: Icon(
                      _iconForType(item.type),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(item.description),
                      const SizedBox(height: 8),
                      Text(
                        '${item.type.replaceAll('_', ' ').toUpperCase()} · ${_formatDate(item.createdAt)}',
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'feedback':
        return Icons.feedback;
      case 'chamado':
        return Icons.support_agent;
      case 'item_salvo':
        return Icons.favorite;
      case 'item_removido':
        return Icons.remove_circle_outline;
      case 'chat':
        return Icons.chat_bubble;
      case 'pedido':
        return Icons.shopping_bag;
      default:
        return Icons.history;
    }
  }

  String _formatDate(DateTime timestamp) {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

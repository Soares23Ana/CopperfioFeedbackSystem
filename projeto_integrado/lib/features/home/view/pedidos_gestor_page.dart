import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/core/theme_provider.dart';
import 'package:projeto_integrado/features/profile/model/pedido_record.dart';
import 'package:projeto_integrado/features/profile/view/pedido_detail_page.dart';
import 'package:projeto_integrado/features/profile/viewmodel/current_user_viewmodel.dart';
import 'package:projeto_integrado/services/firestore_service.dart';

class PedidosGestorPage extends StatefulWidget {
  const PedidosGestorPage({super.key});

  @override
  State<PedidosGestorPage> createState() => _PedidosGestorPageState();
}

class _PedidosGestorPageState extends State<PedidosGestorPage> {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<PedidoRecord>> _ordersStream(String empresaId) {
    return _firestoreService.getPedidosStream(empresaId).map(
      (snapshot) {
        final sortedDocs = snapshot.docs.toList();
        sortedDocs.sort((a, b) {
          final aDate = a.data()['createdAt'];
          final bDate = b.data()['createdAt'];
          if (aDate is Timestamp && bDate is Timestamp) {
            return bDate.compareTo(aDate);
          }
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          return -1;
        });

        return sortedDocs.map((doc) {
          final data = doc.data();
          final createdAt = data['createdAt'];
          String formattedDate = data['date']?.toString() ?? '';
          if (createdAt is Timestamp) {
            formattedDate = createdAt.toDate().toLocal().toString().split('.').first;
          }
          final summary = data['summary']?.toString().trim() ?? '';
          final details = data['details']?.toString().trim() ?? data['observacoes']?.toString().trim() ?? '';
          final notes = data['notes']?.toString().trim() ?? 'Sem observações adicionais';

          return PedidoRecord(
            id: doc.id,
            date: formattedDate,
            status: data['status']?.toString() ?? 'Novo',
            summary: summary.isNotEmpty ? summary : 'Pedido de orçamento',
            items: List<String>.from(data['items'] ?? []),
            total: data['total']?.toString() ?? '',
            details: details,
            notes: notes,
            companyName: data['empresa']?.toString() ?? '',
            createdAt: createdAt is Timestamp ? createdAt.toDate().toLocal() : null,
          );
        }).toList();
      },
    );
  }

  bool _isNewPedido(PedidoRecord order) {
    if (order.status.toLowerCase() != 'novo') return false;
    if (order.createdAt == null) return false;
    return DateTime.now().difference(order.createdAt!).inDays < 2;
  }

  String _effectivePedidoStatus(PedidoRecord order) {
    if (order.status.toLowerCase() == 'novo' && !_isNewPedido(order)) {
      return 'Pendente';
    }
    return order.status;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Consumer<CurrentUserViewModel>(
      builder: (context, userViewModel, _) {
        final companyId = userViewModel.companyId;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pedidos dos Clientes'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: themeProvider.toggleTheme,
              ),
            ],
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: StreamBuilder<List<PedidoRecord>>(
            stream: _ordersStream(companyId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar pedidos: ${snapshot.error}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                );
              }

              final orders = snapshot.data ?? [];
              if (orders.isEmpty) {
                return Center(
                  child: Text(
                    'Nenhum pedido de cliente encontrado.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (context, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.companyName.isNotEmpty
                                          ? 'Pedido ${order.companyName}'
                                          : 'Pedido ${order.id}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(order.summary),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                color: _effectivePedidoStatus(order) == 'Concluído'
                                    ? const Color(0xFFE3F7E8)
                                    : _effectivePedidoStatus(order) == 'Cancelado'
                                          ? const Color(0xFFFDEAEA)
                                          : const Color(0xFFEEF3FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                _effectivePedidoStatus(order),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _effectivePedidoStatus(order) == 'Concluído'
                                      ? const Color(0xFF1B7F35)
                                      : _effectivePedidoStatus(order) == 'Cancelado'
                                            ? const Color(0xFFB00020)
                                            : const Color(0xFF1A3F9B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                order.date,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                order.total,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: order.items
                                .map(
                                  (item) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).dividerColor.withAlpha(38),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PedidoDetailPage(pedido: order),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Ver detalhes'),
                            ),
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
      },
    );
  }
}

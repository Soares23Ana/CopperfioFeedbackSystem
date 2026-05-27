import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/core/theme_provider.dart';
import 'package:projeto_integrado/features/profile/model/pedido_record.dart';
import 'package:projeto_integrado/features/profile/view/pedido_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_integrado/services/auth_service.dart';

class PedidosHistoryPage extends StatefulWidget {
  const PedidosHistoryPage({super.key});

  @override
  State<PedidosHistoryPage> createState() => _PedidosHistoryPageState();
}

class _PedidosHistoryPageState extends State<PedidosHistoryPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  Stream<List<PedidoRecord>> _ordersStream() {
    final user = _auth.getCurrentUser();
    final uid = user?.uid;
    final email = user?.email?.trim().toLowerCase();

    if (uid == null && (email == null || email.isEmpty)) {
      return Stream<List<PedidoRecord>>.value(const <PedidoRecord>[]);
    }

    final ref = _db.collection('pedidos');

    final query = uid != null
        ? ref.where('userId', isEqualTo: uid)
        : ref.where('userEmailLower', isEqualTo: email);

    return query.snapshots().asyncMap((snap) async {
      if (snap.docs.isNotEmpty) {
        return _pedidosFromDocs(snap.docs);
      }

      if (email != null && email.isNotEmpty) {
        final fallbackSnapshot = await ref
            .where('userEmailLower', isEqualTo: email)
            .get();
        if (fallbackSnapshot.docs.isNotEmpty) {
          return _pedidosFromDocs(fallbackSnapshot.docs);
        }

        final typedEmailLowerSnapshot = await ref
            .where('emailLower', isEqualTo: email)
            .get();
        if (typedEmailLowerSnapshot.docs.isNotEmpty) {
          return _pedidosFromDocs(typedEmailLowerSnapshot.docs);
        }

        final rawEmailSnapshot = await ref
            .where('email', isEqualTo: email)
            .get();
        if (rawEmailSnapshot.docs.isNotEmpty) {
          return _pedidosFromDocs(rawEmailSnapshot.docs);
        }
      }

      return const <PedidoRecord>[];
    });
  }

  List<PedidoRecord> _pedidosFromDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sortedDocs = docs.toList()
      ..sort((a, b) {
        final aDate = a.data()['createdAt'];
        final bDate = b.data()['createdAt'];
        if (aDate is Timestamp && bDate is Timestamp) {
          return bDate.compareTo(aDate);
        }
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        return -1;
      });

    return sortedDocs.map((d) => _pedidoFromDoc(d)).toList();
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

  PedidoRecord _pedidoFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    final createdAt = data['createdAt'];
    String formattedDate = data['date']?.toString() ?? '';
    if (createdAt is Timestamp) {
      formattedDate = createdAt.toDate().toLocal().toString().split('.').first;
    }
    final summary = data['summary']?.toString().trim() ?? '';
    final details =
        data['details']?.toString().trim() ??
        data['observacoes']?.toString().trim() ??
        '';
    final notes =
        data['notes']?.toString().trim() ?? 'Sem observações adicionais';

    return PedidoRecord(
      id: d.id,
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
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
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
        stream: _ordersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Text(
                'Nenhum pedido encontrado.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                                  'Pedido ${order.id}',
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withAlpha(38),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'VER PEDIDO',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
  }
}

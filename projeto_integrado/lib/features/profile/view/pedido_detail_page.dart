import 'package:flutter/material.dart';
import 'package:projeto_integrado/features/profile/model/pedido_record.dart';

class PedidoDetailPage extends StatelessWidget {
  final PedidoRecord pedido;

  const PedidoDetailPage({super.key, required this.pedido});

  Color _statusColor(String status) {
    switch (status) {
      case 'Concluído':
        return const Color(0xFF1B7F35);
      case 'Cancelado':
        return const Color(0xFFB00020);
      default:
        return const Color(0xFF1A3F9B);
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Concluído':
        return const Color(0xFFE3F7E8);
      case 'Cancelado':
        return const Color(0xFFFDEAEA);
      default:
        return const Color(0xFFEEF3FF);
    }
  }

  Widget _buildStatusStepper(BuildContext context, String status) {
    final steps = ['Separação', 'Em Andamento', 'Processo de Entrega', 'Entregue'];
    var current = steps.indexWhere((s) => s.toLowerCase() == status.toLowerCase());
    if (current == -1) {
      current = steps.indexWhere((s) => status.toLowerCase().contains(s.toLowerCase()));
    }
    if (current == -1) current = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(steps.length, (i) {
            final done = i <= current;
            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: done ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Container(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: i == current ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Pedido'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(18),
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
                                pedido.companyName.isNotEmpty
                                    ? 'Pedido ${pedido.companyName}'
                                    : 'Pedido ${pedido.id}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (pedido.companyName.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'ID ${pedido.id}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBackground(pedido.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pedido.status,
                            style: TextStyle(
                              color: _statusColor(pedido.status),
                              fontWeight: FontWeight.bold,
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
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          pedido.date,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Spacer(),
                        Text(
                          pedido.total,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 12),
                  ...pedido.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'O que a pessoa pediu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pedido.summary,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(217),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Observações',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pedido.notes,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(217),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Status do pedido',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildStatusStepper(context, pedido.status),
                  const SizedBox(height: 6),
                  Text(
                    pedido.details,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(217),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

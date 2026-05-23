class PedidoRecord {
  final String id;
  final String date;
  final String status;
  final String summary;
  final List<String> items;
  final String total;
  final String details;
  final String notes;

  const PedidoRecord({
    required this.id,
    required this.date,
    required this.status,
    required this.summary,
    required this.items,
    required this.total,
    required this.details,
    required this.notes,
  });
}

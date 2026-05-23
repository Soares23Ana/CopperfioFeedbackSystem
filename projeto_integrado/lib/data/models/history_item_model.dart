class HistoryItemModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  HistoryItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.metadata,
  });

  factory HistoryItemModel.fromMap(Map<String, dynamic> map) {
    return HistoryItemModel(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? 'unknown',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

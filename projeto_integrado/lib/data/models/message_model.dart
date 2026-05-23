class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'cliente' ou 'empresa'
  final String recipientId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.recipientId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  // Converter para JSON para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'recipientId': recipientId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  // Criar a partir de JSON do Firebase
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? '',
      recipientId: map['recipientId'] ?? '',
      content: map['content'] ?? '',
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int? ?? 0),
      isRead: map['isRead'] ?? false,
    );
  }

  // Para exibição
  @override
  String toString() {
    return 'MessageModel(id: $id, from: $senderName, content: $content)';
  }
}

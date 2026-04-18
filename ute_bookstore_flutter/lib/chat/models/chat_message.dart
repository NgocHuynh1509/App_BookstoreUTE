enum MessageType { TEXT, IMAGE, VIDEO, PRODUCT, ORDER }
enum SenderRole { USER, ADMIN }

class ChatMessage {
  final String? id;
  final String content;
  final String? mediaUrl;
  final MessageType messageType;
  final SenderRole senderRole;
  final DateTime createdAt;
  final String? userName; // Người gửi
  final String? receiverName; // Người nhận
  final String? reaction;

  ChatMessage({
    this.id,
    required this.content,
    this.mediaUrl,
    required this.messageType,
    required this.senderRole,
    required this.createdAt,
    this.userName,
    this.receiverName,
    this.reaction, // ✅ THÊM
  });

  // Chuyển từ JSON (Map) sang Object
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id']?.toString(),
      content: map['content'] ?? '',
      mediaUrl: map['mediaUrl'],
      // Sửa lại trong chat_message.dart
      senderRole: SenderRole.values.firstWhere(
        (e) => e.name.toUpperCase() == (map['senderRole']?.toString().toUpperCase() ?? 'USER'),
        orElse: () => SenderRole.USER,
      ),
      messageType: MessageType.values.firstWhere(
        (e) => e.name.toUpperCase() == (map['messageType']?.toString().toUpperCase() ?? 'TEXT'),
        orElse: () => MessageType.TEXT,
      ),
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      userName: map['userName'],
      receiverName: map['receiverName'],
      reaction: map['reaction'], // ✅ THÊM
    );
  }

  // Chuyển từ Object sang Map (Dùng khi gửi tin qua Socket)
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'messageType': messageType.name,
      'senderRole': senderRole.name,
      'userName': userName,
      'receiverName': receiverName,
      'mediaUrl': mediaUrl,
    };
  }
}
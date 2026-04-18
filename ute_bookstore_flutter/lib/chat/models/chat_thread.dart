class ChatThread {
  final String customerUsername;
  final String lastMessage;
  final DateTime lastTime;
  final int unreadCount;
  final String? customerAvatar;

  ChatThread({
    required this.customerUsername,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
    this.customerAvatar,
  });

  factory ChatThread.fromMap(Map<String, dynamic> map) {
    return ChatThread(
      // Entity Java là userName, không phải customerUsername
      customerUsername: map['userName'] ?? 'Unknown User',
      // Entity Java là content, không phải lastMessage
      lastMessage: map['content'] ?? '',
      // Entity Java là createdAt
      lastTime: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      unreadCount: 0, // Hiện tại Backend chưa tính cái này nên mặc định là 0
      customerAvatar: null,
    );
  }

  // Tiện ích để copy và cập nhật object khi có tin nhắn mới từ Socket
  ChatThread copyWith({
    String? lastMessage,
    DateTime? lastTime,
    int? unreadCount,
  }) {
    return ChatThread(
      customerUsername: this.customerUsername,
      lastMessage: lastMessage ?? this.lastMessage,
      lastTime: lastTime ?? this.lastTime,
      unreadCount: unreadCount ?? this.unreadCount,
      customerAvatar: this.customerAvatar,
    );
  }
}
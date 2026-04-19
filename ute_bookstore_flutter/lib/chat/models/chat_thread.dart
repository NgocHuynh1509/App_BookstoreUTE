class ChatThread {
  final String customerUsername;
  final String lastMessage;
  final DateTime lastTime;
  final int unreadCount;
  final bool isManualUnread;
  final String? customerAvatar;

  ChatThread({
    required this.customerUsername,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
    this.isManualUnread = false,
    this.customerAvatar,
  });

  factory ChatThread.fromMap(Map<String, dynamic> map) {
    return ChatThread(
      customerUsername: map['customerUsername'] ?? 'Unknown User',
      lastMessage: map['lastMessage'] ?? '',
      lastTime: map['lastTime'] != null
          ? DateTime.parse(map['lastTime'])
          : DateTime.now(),
      unreadCount: map['unreadCount'] ?? 0,
      isManualUnread: map['manualUnread'] ?? false,
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
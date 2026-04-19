import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm intl vào pubspec.yaml để định dạng ngày
import '../../models/chat_thread.dart';

class ChatItemWidget extends StatelessWidget {
  final ChatThread thread;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChatItemWidget({
    super.key,
    required this.thread,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.blueGrey[100],
        child: Text(
          thread.customerUsername[0].toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      title: Text(
        thread.customerUsername,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        thread.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormat('HH:mm').format(thread.lastTime),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (thread.unreadCount > 0 || thread.isManualUnread)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: thread.unreadCount > 0
                  ? Text(
                      "${thread.unreadCount}",
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    )
                  : const SizedBox(width: 10, height: 10), // Dấu chấm đỏ đơn thuần nếu là thủ công
            ),
        ],
      ),
    );
  }
}
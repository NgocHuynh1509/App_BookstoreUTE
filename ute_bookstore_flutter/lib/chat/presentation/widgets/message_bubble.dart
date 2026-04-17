import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../../api_config.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    bool isAdmin = message.senderRole == SenderRole.ADMIN;

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isAdmin ? Colors.blue[600] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 16 : 0),
            bottomRight: Radius.circular(isAdmin ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.messageType == MessageType.IMAGE && message.mediaUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  '${ApiConfig.baseUrl}${message.mediaUrl}',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            if (message.content.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: message.messageType == MessageType.IMAGE ? 8.0 : 0),
                child: Text(
                  message.content,
                  style: TextStyle(color: isAdmin ? Colors.white : Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
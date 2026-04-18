import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../../api_config.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final Function(String) onReact;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onReact,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _showTime = false;
  bool _isReactAnimating = false;

  String getEmoji(String? reaction) {
    switch (reaction) {
      case 'LIKE':
        return '👍';
      case 'LOVE':
        return '❤️';
      case 'HAHA':
        return '😆';
      case 'WOW':
        return '😮';
      case 'SAD':
        return '😢';
      case 'ANGRY':
        return '😡';
      default:
        return '';
    }
  }

  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  void didUpdateWidget(covariant MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.message.reaction != widget.message.reaction &&
        widget.message.reaction != null) {
      _triggerReactAnimation();
    }
  }

  void _triggerReactAnimation() {
    setState(() => _isReactAnimating = true);

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _isReactAnimating = false);
      }
    });
  }

  void _showReactionBar(BuildContext context) {
    if (widget.isMe) return;

    final reactions = ['LIKE', 'LOVE', 'HAHA', 'WOW', 'SAD', 'ANGRY'];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: reactions.map((type) {
              final isSelected = widget.message.reaction == type;

              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  widget.onReact(type);
                },
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  scale: isSelected ? 1.3 : 1.0,
                  curve: Curves.easeOutBack,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      getEmoji(type),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildMessageContent(bool isMe) {
    final msg = widget.message;

    // 🔥 IMAGE → NO BACKGROUND
    if (msg.messageType == MessageType.IMAGE && msg.mediaUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          '${ApiConfig.baseUrl}${msg.mediaUrl}',
          width: 220,
          fit: BoxFit.cover,
        ),
      );
    }

    // 🔥 TEXT → NORMAL BUBBLE CONTENT
    return Text(
      msg.content,
      style: TextStyle(
        color: isMe ? Colors.white : Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.isMe;
    final isImage = widget.message.messageType == MessageType.IMAGE;

    return GestureDetector(
      onTap: () => setState(() => _showTime = !_showTime),
      onLongPress: isMe ? null : () => _showReactionBar(context),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment:
                    isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  scale: _isReactAnimating ? 1.05 : 1.0,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),

                    // 🔥 IMPORTANT: IMAGE = NO BACKGROUND + NO EXTRA PADDING
                    padding: isImage
                        ? EdgeInsets.zero
                        : const EdgeInsets.all(12),

                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),

                    decoration: BoxDecoration(
                      color: isImage
                          ? Colors.transparent
                          : (isMe
                              ? Colors.blue[600]
                              : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: _buildMessageContent(isMe),
                  ),
                ),
              ),

              // ❤️ reaction bubble
              if (widget.message.reaction != null)
                Positioned(
                  bottom: -10,
                  left: isMe ? null : 4,
                  right: isMe ? 4 : null,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: _isReactAnimating ? 1.4 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: Text(
                        getEmoji(widget.message.reaction),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ⏰ TIME
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _showTime ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                formatTime(widget.message.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
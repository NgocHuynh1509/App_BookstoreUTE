import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../../api_config.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final Function(String) onReact;
  final Function(ChatMessage) onReply; // ✅ THÊM

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onReact,
    required this.onReply, // ✅ THÊM
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _showTime = false;
  bool _isReactAnimating = false;

  String getEmoji(String? reaction) {
    switch (reaction) {
      case 'LIKE': return '👍';
      case 'LOVE': return '❤️';
      case 'HAHA': return '😆';
      case 'WOW': return '😮';
      case 'SAD': return '😢';
      case 'ANGRY': return '😡';
      default: return '';
    }
  }

  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  void didUpdateWidget(covariant MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.reaction != widget.message.reaction && widget.message.reaction != null) {
      _triggerReactAnimation();
    }
  }

  void _triggerReactAnimation() {
    setState(() => _isReactAnimating = true);
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _isReactAnimating = false);
    });
  }

  void _showOptions(BuildContext context) {
    final reactions = ['LIKE', 'LOVE', 'HAHA', 'WOW', 'SAD', 'ANGRY'];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reaction Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: reactions.map((type) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onReact(type);
                      },
                      child: Text(getEmoji(type), style: const TextStyle(fontSize: 32)),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1),
              // Option: Reply
              ListTile(
                leading: const Icon(Icons.reply, color: Colors.blue),
                title: const Text("Trả lời"),
                onTap: () {
                  Navigator.pop(context);
                  widget.onReply(widget.message);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReplyPreview() {
    final msg = widget.message;
    if (msg.replyToId == null) return const SizedBox.shrink();

    final isImage = msg.replyToMessageType == MessageType.IMAGE;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: widget.isMe ? Colors.white70 : Colors.blue, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            msg.replyToSender ?? "Người dùng",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: widget.isMe ? Colors.white.withOpacity(0.9) : Colors.blue[800],
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              if (isImage && msg.replyToMediaUrl != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      '${ApiConfig.baseUrl}${msg.replyToMediaUrl}',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  isImage ? "[Hình ảnh]" : (msg.replyToContent ?? ""),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isMe ? Colors.white.withOpacity(0.8) : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(bool isMe) {
    final msg = widget.message;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildReplyPreview(),
        if (msg.messageType == MessageType.IMAGE && msg.mediaUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              '${ApiConfig.baseUrl}${msg.mediaUrl}',
              width: 220,
              fit: BoxFit.cover,
            ),
          )
        else
          Text(
            msg.content,
            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.isMe;
    final isImage = widget.message.messageType == MessageType.IMAGE;

    return GestureDetector(
      onTap: () => setState(() => _showTime = !_showTime),
      onLongPress: () => _showOptions(context),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  scale: _isReactAnimating ? 1.05 : 1.0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: (isImage && widget.message.replyToId == null)
                        ? EdgeInsets.zero
                        : const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: (isImage && widget.message.replyToId == null)
                          ? Colors.transparent
                          : (isMe ? Colors.blue[600] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildMessageContent(isMe),
                  ),
                ),
              ),
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
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Text(getEmoji(widget.message.reaction), style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
            ],
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _showTime ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                formatTime(widget.message.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
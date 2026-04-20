import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'widgets/message_bubble.dart';
import '../data/chat_repository.dart';
import 'package:image_picker/image_picker.dart';
import '../../../api_config.dart';
import 'package:intl/intl.dart';
import '../../core/session_storage.dart';

class ChatDetailScreen extends StatefulWidget {
  final String customerUsername;
  final ChatRepository repository;

  // Thêm các thuộc tính phục vụ việc hiển thị banner
    final String? initialOrderId;
    final double? initialOrderPrice;
    final int? initialOrderItemCount;
    final String? initialOrderImage;

  const ChatDetailScreen({
    super.key,
    required this.customerUsername,
    required this.repository,
    this.initialOrderId,      // Mã đơn hàng
        this.initialOrderPrice,   // Tổng tiền
        this.initialOrderItemCount, // Số lượng món
        this.initialOrderImage,    // Ảnh đại diện đơn hàng
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  ChatMessage? _replyMessage; // ✅ THÊM
  String? _pendingOrderId;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _initSocketListener();
    _pendingOrderId = widget.initialOrderId;
    widget.repository.markAsSeen(widget.customerUsername);
  }



  void _loadHistory() async {
    try {
      final history = await widget.repository.fetchMessages(widget.customerUsername);
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(history);
        });
      }
    } catch (e) {
      print("❌ Lỗi load history: $e");
    }
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} "
        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  bool _shouldShowDate(int index) {
    if (index == _messages.length - 1) return true;
    final current = _messages[index].createdAt;
    final next = _messages[index + 1].createdAt;
    return current.difference(next).inMinutes.abs() > 30;
  }

  void _initSocketListener() {
    widget.repository.updateCallbacks(
      onMessage: (payload) {
        final newMessage = ChatMessage.fromMap(payload);
        bool isRelevant = (newMessage.userName == widget.customerUsername) ||
            (newMessage.receiverName == widget.customerUsername);
        if (!isRelevant) return;
        setState(() {
          _messages.removeWhere((m) =>
              m.id != null && m.id!.startsWith('temp_') && m.content == newMessage.content);
          _messages.insert(0, newMessage);
        });
      },
      onReaction: (payload) {
        final updated = ChatMessage.fromMap(payload);
        setState(() {
          final index = _messages.indexWhere((m) => m.id == updated.id);
          if (index != -1) {
            _messages[index] = updated;
          }
        });
      },
    );
  }

  void _onPickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final mediaUrl = await widget.repository.uploadImage(image);
        widget.repository.sendAdminReply(
          widget.customerUsername, "",
          mediaUrl: mediaUrl,
          replyToId: _replyMessage?.id
        );
        setState(() => _replyMessage = null); // Reset reply sau khi gửi
      }
    } catch (e) {
      print("Lỗi chọn ảnh: $e");
    }
  }

  void _onSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    // Sửa điều kiện check: Cho phép gửi nếu có text HOẶC có orderId
        if (text.isEmpty && _pendingOrderId == null) return;

        // BƯỚC 1: QUAN TRỌNG - Lưu lại giá trị vào biến cục bộ
        final String? orderIdToSend = _pendingOrderId;

    final tempMsg = ChatMessage(
      id: 'temp_${DateTime.now().microsecondsSinceEpoch}',
      content: text,
      messageType: MessageType.TEXT,
      senderRole: SenderRole.ADMIN,
      createdAt: DateTime.now(),
      userName: 'admin',
      receiverName: widget.customerUsername,
      replyToId: _replyMessage?.id,
      replyToContent: _replyMessage?.content,
      replyToMessageType: _replyMessage?.messageType,
      replyToMediaUrl: _replyMessage?.mediaUrl,
      replyToSender: _replyMessage?.userName,
// Đính kèm dữ liệu order để UI hiện Card ngay lập tức
      orderId: orderIdToSend,
      totalPrice: widget.initialOrderPrice,
      orderItemCount: widget.initialOrderItemCount,
      image: widget.initialOrderImage,
      orderStatus: 'Đang xử lý',
    );

    setState(() {
      _messages.insert(0, tempMsg);
      _pendingOrderId = null;
    });

    widget.repository.sendAdminReply(
      widget.customerUsername,
      text,
      replyToId: _replyMessage?.id,
      orderId: orderIdToSend,
    );

    _controller.clear();
    setState(() => _replyMessage = null); // Reset reply sau khi gửi
  }

  void _sendReaction(ChatMessage message, String reaction) {
    if (message.id == null) return;
    widget.repository.socket.sendReaction(
      messageId: message.id!,
      reaction: reaction,
      partnerName: widget.customerUsername,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat với ${widget.customerUsername}")),
      body: Column(
        children: [
          // HIỂN THỊ BANNER ĐƠN HÀNG Ở ĐÂY
          if (_pendingOrderId != null) _buildOrderBanner(),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Column(
                  children: [
                    if (_shouldShowDate(index))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          formatDate(msg.createdAt),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: msg.senderRole == SenderRole.ADMIN
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (msg.senderRole != SenderRole.ADMIN)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 4),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundImage: const NetworkImage("/upload/avt.jpg"),
                                ),
                              ),
                            ),
                          MessageBubble(
                            message: msg,
                            isMe: msg.senderRole == SenderRole.ADMIN,
                            onReact: (reaction) => _sendReaction(msg, reaction),
                            onReply: (message) => setState(() => _replyMessage = message), // ✅ THÊM
                            repository: widget.repository,
                          ),
                          if (msg.senderRole == SenderRole.ADMIN) const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
          if (_replyMessage != null) _buildReplyPreview(), // ✅ THÊM
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    final isImage = _replyMessage!.messageType == MessageType.IMAGE;
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Icon(Icons.reply, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Đang trả lời ${_replyMessage!.userName ?? 'Người dùng'}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
                ),
                Text(
                  isImage ? "[Hình ảnh]" : _replyMessage!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          if (isImage && _replyMessage!.mediaUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Image.network(
                '${ApiConfig.baseUrl}${_replyMessage!.mediaUrl}',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _replyMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBanner() {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(bottom: BorderSide(color: Colors.orange.shade200)),
      ),
      child: Row(
        children: [
          // Ảnh đơn hàng
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.initialOrderImage != null
                ? Image.network(
                    widget.initialOrderImage!.startsWith('http')
                      ? widget.initialOrderImage!
                      : 'http://10.0.2.2:8080/uploads/${widget.initialOrderImage}',
                    width: 50, height: 50, fit: BoxFit.cover,
                  )
                : Container(width: 50, height: 50, color: Colors.orange.shade100),
          ),
          const SizedBox(width: 12),
          // Thông tin đơn hàng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bạn đang phản hồi về Đơn hàng #${widget.initialOrderId}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange),
                ),
                Text(
                  "${widget.initialOrderItemCount} sản phẩm - Tổng: ${formatter.format(widget.initialOrderPrice)}đ",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          // Nút đóng banner
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
            onPressed: () => setState(() => _pendingOrderId = null),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _onPickImage,
            icon: const Icon(Icons.image, color: Colors.blue)
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Nhập phản hồi...",
                border: InputBorder.none
              ),
              onSubmitted: (_) => _onSend(),
            ),
          ),
          IconButton(
            onPressed: _onSend,
            icon: const Icon(Icons.send, color: Colors.blue)
          ),
        ],
      ),
    );
  }
}
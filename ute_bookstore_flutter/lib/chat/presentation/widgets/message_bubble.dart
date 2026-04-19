import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../../api_config.dart';
import 'package:intl/intl.dart';
// Ví dụ nếu file nằm ở: lib/screens/product/product_detail_screen.dart
import '../../../features/products/presentation/product_detail_screen.dart';
// Ví dụ nếu file nằm ở: lib/data/product_models.dart
import '../../../features/products/data/product_models.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final Function(String) onReact;
  final Function(ChatMessage) onReply;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onReact,
    required this.onReply,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> with SingleTickerProviderStateMixin{
  bool _showTime = false;
  bool _isReactAnimating = false;
  late AnimationController _scaleController;
    late Animation<double> _scaleAnimation;
  @override
    void initState() {
      super.initState();
      // Khởi tạo controller cho hiệu ứng nảy
      _scaleController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      _scaleAnimation = CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut, // Hiệu ứng nảy đàn hồi
      );
    }

    @override
    void dispose() {
      _scaleController.dispose();
      super.dispose();
    }

    @override
    void didUpdateWidget(covariant MessageBubble oldWidget) {
      super.didUpdateWidget(oldWidget);
      // Nếu reaction thay đổi (từ null sang có, hoặc từ emoji này sang emoji khác)
      if (widget.message.reaction != oldWidget.message.reaction && widget.message.reaction != null) {
        _scaleController.reset();
        _scaleController.forward();
      }
    }

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


  void _triggerReactAnimation() {
    setState(() => _isReactAnimating = true);
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _isReactAnimating = false);
    });
  }

  void _showOptions(BuildContext context) {
    final reactions = ['LIKE', 'LOVE', 'HAHA', 'WOW', 'SAD', 'ANGRY'];
    final currentReaction = widget.message.reaction; // Lấy reaction hiện tại

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Làm nền trong suốt để đổ bóng đẹp hơn
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: reactions.map((type) {
                    final isSelected = currentReaction == type; // Kiểm tra xem có đang chọn emoji này không
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onReact(type);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // Nếu đã chọn thì hiện nền xanh nhạt, không thì trong suốt
                          color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          getEmoji(type),
                          style: TextStyle(
                            fontSize: isSelected ? 38 : 32, // Phóng to nhẹ emoji đã chọn
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1),
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
        ),
      ),
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
                      width: 40, height: 40, fit: BoxFit.cover,
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

  Widget _buildProductCard(BuildContext context) {
    final currencyFormat = NumberFormat("#,###", "vi_VN");
    final msg = widget.message;

    return GestureDetector(
      onTap: () {
        if (msg.bookId != null) {
          // Tạo object Product từ dữ liệu chat để truyền qua trang Detail
          final productDetail = Product(
            bookId: msg.bookId!,
            title: msg.bookName ?? '',
            price: msg.bookPrice ?? 0,
            picture: msg.bookImage ?? '',
            author: 'Đang cập nhật', // Các thông tin này chat không có đủ
            publisher: '',
            description: '',
            quantity: 0,
            soldQuantity: 0,
            isActive: true,
            categoryId: '',
            categoryName: '',
            publicationYear: null,
            originalPrice: null,
          );

          // Chuyển hướng sang màn hình chi tiết sản phẩm
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: productDetail),
            ),
          );
        }
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                msg.bookImage ?? '',
                width: 80,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 80, height: 100, color: Colors.grey[300]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.bookName ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (msg.bookPrice != null && msg.bookPrice! > 0)
                        ? "${currencyFormat.format(msg.bookPrice)}đ"
                        : "Liên hệ",
                    style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context) {
    final currencyFormat = NumberFormat("#,###", "vi_VN");
    final msg = widget.message;

    return GestureDetector(
      onTap: () {
        // Chuyển hướng sang màn hình chi tiết đơn hàng của bạn
        // Navigator.pushNamed(context, '/order-detail', arguments: msg.orderId);
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // Viền màu cam để phân biệt với sản phẩm
          border: Border.all(color: Colors.orange.shade200, width: 1),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh đơn hàng (lấy tấm đầu tiên từ backend gửi về)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                msg.image ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.orange[50],
                  child: const Icon(Icons.shopping_bag, color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Đơn hàng #${msg.orderId}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.orangeAccent
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Số lượng: ${msg.orderItemCount ?? 0} sản phẩm",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tổng: ${currencyFormat.format(msg.totalPrice ?? 0)}đ",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      msg.orderStatus ?? 'Đang xử lý',
                      style: const TextStyle(fontSize: 10, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bong bóng text: Dùng widget.isMe và widget.message
  Widget _buildTextBubble() {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.blue[600] : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReplyPreview(),
          Text(
            widget.message.content,
            style: TextStyle(color: widget.isMe ? Colors.white : Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.isMe;
    final msg = widget.message;
    final isImage = msg.messageType == MessageType.IMAGE;

    return GestureDetector(
      onTap: () => setState(() => _showTime = !_showTime),
      onLongPress: isMe ? null : () => _showOptions(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 1. Sản phẩm
            if (msg.bookId != null) _buildProductCard(context),

            // 2. Hiển thị Card Đơn hàng (nếu có) - MỚI THÊM
            if (msg.orderId != null) _buildOrderCard(context),

            // 2. Nội dung (Ảnh hoặc Chữ)
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (isImage && msg.mediaUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network('${ApiConfig.baseUrl}${msg.mediaUrl}', width: 220, fit: BoxFit.cover),
                  )
                else if (msg.content.isNotEmpty)
                  _buildTextBubble(),

                // Trong hàm build, phần hiển thị ScaleTransition:
                if (msg.reaction != null)
                  Positioned(
                    bottom: -22,
                    left: isMe ? null : 2,
                    right: isMe ? 2 : null,
                    child: ScaleTransition(
                      scale: _scaleAnimation.isAnimating ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade100, width: 1), // Viền nhẹ cho nổi
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getEmoji(msg.reaction),
                              style: const TextStyle(fontSize: 15), // Tăng kích thước emoji một chút
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Thời gian
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showTime ? 1 : 0,
              child: Text(formatTime(msg.createdAt), style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../widgets/primary_button.dart';
import '../data/product_models.dart';
import 'preview_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  String _formatCurrency(num value) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(value).replaceAll(',', '.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = !product.isActive
        ? 'Đang ẩn'
        : product.quantity <= 0
            ? 'Hết hàng'
            : 'Còn hàng';
    final statusColor = !product.isActive
        ? Colors.grey
        : product.quantity <= 0
            ? Colors.redAccent
            : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sách'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              product.picture,
              height: 260,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 260,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Mã/ISBN: ${product.bookId}'),
          Text('Tác giả: ${product.author}'),
          Text('Nhà xuất bản: ${product.publisher}'),
          if (product.publicationYear != null)
            Text('Năm xuất bản: ${product.publicationYear}'),
          Text('Thể loại: ${product.categoryName}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _formatCurrency(product.price),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (product.originalPrice != null && product.originalPrice! > product.price) ...[
                const SizedBox(width: 8),
                Text(
                  _formatCurrency(product.originalPrice!),
                  style: const TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MetaChip(label: 'Tồn kho: ${product.quantity}'),
              const SizedBox(width: 8),
              _MetaChip(label: 'Đã bán: ${product.soldQuantity}'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            product.description.isEmpty ? 'Chưa có mô tả chi tiết.' : product.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Thêm vào giỏ',
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PreviewScreen()),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Đọc thử'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../reviews/data/review_models.dart';
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

    final galleryImages = <String>[];
    if (product.picture.isNotEmpty) {
      galleryImages.addAll([
        product.picture,
        product.picture,
        product.picture,
      ]);
    }

    final sold = product.soldQuantity;
    final views = sold * 42 + 320;
    final purchases = sold;
    final revenue = sold * product.price;
    final conversion = views == 0 ? 0 : (purchases / views) * 100;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB),
        appBar: AppBar(
          title: const Text('Quản trị sản phẩm'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mở chỉnh sửa sản phẩm')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tùy chọn quản trị')),
                );
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelStyle: TextStyle(fontWeight: FontWeight.w700),
            tabs: [
              Tab(text: 'Tổng quan'),
              Tab(text: 'Kinh doanh'),
              Tab(text: 'Đánh giá'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(
              product: product,
              statusLabel: statusLabel,
              statusColor: statusColor,
              galleryImages: galleryImages,
              formatCurrency: _formatCurrency,
              views: views,
              purchases: purchases,
              revenue: revenue,
              conversion: conversion.toDouble(),
            ),
            _BusinessTab(
              product: product,
              statusLabel: statusLabel,
              statusColor: statusColor,
              formatCurrency: _formatCurrency,
            ),
            _ReviewTab(product: product),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.product,
    required this.statusLabel,
    required this.statusColor,
    required this.galleryImages,
    required this.formatCurrency,
    required this.views,
    required this.purchases,
    required this.revenue,
    required this.conversion,
  });

  final Product product;
  final String statusLabel;
  final Color statusColor;
  final List<String> galleryImages;
  final String Function(num value) formatCurrency;
  final int views;
  final int purchases;
  final double revenue;
  final double conversion;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Thông tin sản phẩm',
          icon: Icons.menu_book_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: product.picture.isNotEmpty
                    ? Image.network(
                        product.picture,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(220),
                      )
                    : _imageFallback(220),
              ),
              const SizedBox(height: 12),
              if (galleryImages.isNotEmpty)
                SizedBox(
                  height: 82,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          galleryImages[index],
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imageFallback(82),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: galleryImages.length,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _TagChip(label: 'Best Seller'),
                  _TagChip(label: 'Hot'),
                  _TagChip(label: 'New'),
                ],
              ),
              const SizedBox(height: 14),
              _KeyValueRow(label: 'Mã sách / ISBN', value: product.bookId),
              _KeyValueRow(label: 'Tác giả', value: product.author),
              _KeyValueRow(label: 'Danh mục', value: product.categoryName),
              _KeyValueRow(label: 'Nhà xuất bản', value: product.publisher),
              _KeyValueRow(
                label: 'Năm xuất bản',
                value:
                    product.publicationYear?.toString() ?? 'Chưa cập nhật',
              ),
              _KeyValueRow(label: 'Ngôn ngữ', value: 'Tiếng Việt'),
              _KeyValueRow(label: 'Số trang', value: '320'),
              _KeyValueRow(label: 'Kích thước', value: '14 x 20 cm'),
              _KeyValueRow(label: 'Trọng lượng', value: '420g'),
              _KeyValueRow(label: 'Loại bìa', value: 'Bìa mềm'),
              const Divider(height: 24),
              const _SectionTitle(title: 'Mô tả ngắn'),
              Text(
                product.description.isEmpty
                    ? 'Chưa có mô tả ngắn.'
                    : product.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              const _SectionTitle(title: 'Mô tả chi tiết'),
              Text(
                product.description.isEmpty
                    ? 'Chưa có mô tả chi tiết.'
                    : product.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              const _SectionTitle(title: 'Nội dung đọc thử'),
              Text(
                'Tóm tắt chương 1... (dữ liệu mẫu)'
                '\nGiới thiệu tác giả và nội dung chính.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PreviewScreen()),
                  );
                },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Xem PDF đọc thử'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Thống kê nhanh',
          icon: Icons.insights_outlined,
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 520;
                  final itemWidth = isWide
                      ? (constraints.maxWidth - 16) / 2
                      : (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatCard(
                        label: 'Lượt xem',
                        value: views.toString(),
                        icon: Icons.remove_red_eye_outlined,
                        width: itemWidth,
                      ),
                      _StatCard(
                        label: 'Lượt mua',
                        value: purchases.toString(),
                        icon: Icons.shopping_bag_outlined,
                        width: itemWidth,
                      ),
                      _StatCard(
                        label: 'Doanh thu',
                        value: formatCurrency(revenue),
                        icon: Icons.payments_outlined,
                        width: itemWidth,
                      ),
                      _StatCard(
                        label: 'Chuyển đổi',
                        value: '${conversion.toStringAsFixed(1)}%',
                        icon: Icons.trending_up_outlined,
                        width: itemWidth,
                      ),
                      _StatCard(
                        label: 'Wishlist',
                        value: '${purchases * 2}',
                        icon: Icons.favorite_border,
                        width: itemWidth,
                      ),
                      _StatCard(
                        label: 'Đánh giá',
                        value: '4.6/5',
                        icon: Icons.star_outline,
                        width: itemWidth,
                      ),
                      _StatCard(
                        label: 'Số review',
                        value: '${purchases * 3}',
                        icon: Icons.rate_review_outlined,
                        width: itemWidth,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Gợi ý cho admin',
          icon: Icons.lightbulb_outline,
          child: Column(
            children: const [
              _InsightTile(
                icon: Icons.warning_amber_outlined,
                color: Colors.orange,
                title: 'Sắp hết hàng',
                subtitle: 'Cân nhắc nhập thêm để tránh thiếu sản phẩm.',
              ),
              SizedBox(height: 10),
              _InsightTile(
                icon: Icons.trending_down_outlined,
                color: Colors.redAccent,
                title: 'Doanh số giảm',
                subtitle: 'Xem xét chạy khuyến mãi cho sản phẩm này.',
              ),
              SizedBox(height: 10),
              _InsightTile(
                icon: Icons.local_offer_outlined,
                color: Colors.blue,
                title: 'Gợi ý giảm giá',
                subtitle: 'Giảm 10% để tăng chuyển đổi trong 7 ngày tới.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _imageFallback(double size) {
    return Container(
      height: size,
      width: size,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}

class _BusinessTab extends StatelessWidget {
  const _BusinessTab({
    required this.product,
    required this.statusLabel,
    required this.statusColor,
    required this.formatCurrency,
  });

  final Product product;
  final String statusLabel;
  final Color statusColor;
  final String Function(num value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final originalPrice = product.originalPrice ?? product.price;
    final discount = originalPrice > product.price
        ? ((originalPrice - product.price) / originalPrice) * 100
        : 0.0;
    final importPrice = (originalPrice * 0.65);
    final profit = product.price - importPrice;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Thông tin kinh doanh',
          icon: Icons.business_center_outlined,
          child: Column(
            children: [
              _KeyValueRow(
                label: 'Giá nhập',
                value: formatCurrency(importPrice),
              ),
              _KeyValueRow(
                label: 'Giá bán',
                value: formatCurrency(product.price),
              ),
              _KeyValueRow(
                label: 'Giá gốc',
                value: formatCurrency(originalPrice),
              ),
              _KeyValueRow(
                label: 'Giảm giá',
                value: '${discount.toStringAsFixed(1)}%',
              ),
              _KeyValueRow(
                label: 'Lợi nhuận dự kiến',
                value: formatCurrency(profit),
                valueColor: profit >= 0 ? Colors.green : Colors.red,
              ),
              const Divider(height: 24),
              _KeyValueRow(label: 'Tổng tồn kho', value: '${product.quantity}'),
              _KeyValueRow(label: 'Đã bán', value: '${product.soldQuantity}'),
              _KeyValueRow(
                label: 'Sắp hết hàng',
                value: product.quantity < 10 ? 'Cần nhập thêm' : 'Ổn định',
                valueColor:
                    product.quantity < 10 ? Colors.redAccent : Colors.green,
              ),
              _KeyValueRow(label: 'Trạng thái', value: statusLabel),
              _KeyValueRow(label: 'Nhà cung cấp', value: 'Công ty Sách UTE'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Kho & phân phối',
          icon: Icons.warehouse_outlined,
          child: Column(
            children: const [
              _KeyValueRow(label: 'Kho chính', value: 'Kho TP.HCM'),
              _KeyValueRow(label: 'Kho phụ', value: 'Kho Hà Nội'),
              _KeyValueRow(label: 'Khu vực bán chạy', value: 'Quận 9, TP.HCM'),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ReviewTab extends ConsumerStatefulWidget {
  const _ReviewTab({required this.product});

  final Product product;

  @override
  ConsumerState<_ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends ConsumerState<_ReviewTab> {
  late Future<_ReviewPayload> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<_ReviewPayload> _fetch() async {
    final repository = ref.read(reviewRepositoryProvider);
    final reviews = await repository.fetchReviews(widget.product.bookId);
    final summary = await repository.fetchSummary(widget.product.bookId);
    return _ReviewPayload(reviews: reviews, summary: summary);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _fetch();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ReviewPayload>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final payload = snapshot.data;
        final reviews = payload?.reviews ?? const <Review>[];
        final summary = payload?.summary ?? ReviewSummary(averageRating: 0, reviewCount: 0);
        final averageRating = summary.averageRating;
        final reviewCount = summary.reviewCount;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoCard(
                title: 'Đánh giá khách hàng',
                icon: Icons.rate_review_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => Icon(
                                      index < averageRating.round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$reviewCount đánh giá',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Cập nhật từ DB',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Icon(Icons.verified_outlined, color: Colors.blue.shade400),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (reviews.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text('Chưa có đánh giá nào')),
                      )
                    else
                      ...reviews.map((review) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFD),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      review.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    review.creationDate.isEmpty ? '-' : review.creationDate,
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < review.rating ? Icons.star : Icons.star_border,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(review.comment),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Đã ẩn đánh giá này'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.visibility_off_outlined),
                                    label: const Text('Ẩn review'),
                                  ),
                                  const SizedBox(width: 6),
                                  TextButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Mở phản hồi khách hàng'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.reply_outlined),
                                    label: const Text('Phản hồi'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewPayload {
  const _ReviewPayload({required this.reviews, required this.summary});

  final List<Review> reviews;
  final ReviewSummary summary;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.blue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? '---' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 15,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.width,
  });

  final String label;
  final String value;
  final IconData icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}


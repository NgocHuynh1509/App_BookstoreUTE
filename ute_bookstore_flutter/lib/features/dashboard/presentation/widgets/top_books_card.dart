import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../theme/admin_theme.dart';

class TopBooksCard extends StatelessWidget {
  const TopBooksCard({super.key, required this.items});

  final List<TopBookItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Sản phẩm bán chạy', action: 'Xem tất cả'),
          const SizedBox(height: 12),
          Column(
            children: items
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(bottom: entry.key == items.length - 1 ? 0 : 12),
                    child: _TopBookRow(item: entry.value, rank: entry.key + 1),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TopBookRow extends StatelessWidget {
  const _TopBookRow({required this.item, required this.rank});

  final TopBookItem item;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFFEFF6FF),
          child: Text(
            '$rank',
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        const SizedBox(width: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _BookCover(imageUrl: item.imageUrl),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 2),
              Text(item.author, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AdminColors.textSecondary)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatNumber(item.sold),
              style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              _formatCurrency(item.revenue),
              style: GoogleFonts.beVietnamPro(fontSize: 10, color: AdminColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _placeholder();
    }
    return Image.network(
      imageUrl,
      width: 40,
      height: 54,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 40,
      height: 54,
      color: const Color(0xFFEFF2F7),
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book_rounded, size: 18, color: AdminColors.textSecondary),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 13)),
        const Spacer(),
        Text(action, style: GoogleFonts.beVietnamPro(fontSize: 11, color: AdminColors.primary)),
      ],
    );
  }
}

class TopBookItem {
  const TopBookItem({
    required this.title,
    required this.author,
    required this.sold,
    required this.revenue,
    this.imageUrl = '',
  });

  final String title;
  final String author;
  final int sold;
  final double revenue;
  final String imageUrl;
}

String _formatCurrency(num value) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(value).replaceAll(',', '.')} đ';
}

String _formatNumber(num value) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return formatter.format(value).replaceAll(',', '.');
}

const _cardDecoration = BoxDecoration(
  color: AdminColors.surface,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  boxShadow: [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8)),
  ],
);


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/admin_theme.dart';

class ChannelBreakdownCard extends StatelessWidget {
  const ChannelBreakdownCard({super.key, required this.items});

  final List<SalesChannelItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Kênh bán hàng', action: 'Xem tất cả'),
          const SizedBox(height: 12),
          Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ChannelRow(item: item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow({required this.item});

  final SalesChannelItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(item.icon, size: 16, color: item.color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: item.percent / 100,
                  minHeight: 6,
                  backgroundColor: AdminColors.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(item.color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text('${item.percent.toStringAsFixed(0)}%', style: GoogleFonts.beVietnamPro(fontSize: 11)),
      ],
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

class SalesChannelItem {
  const SalesChannelItem({
    required this.label,
    required this.percent,
    required this.icon,
    required this.color,
  });

  final String label;
  final double percent;
  final IconData icon;
  final Color color;
}

const _cardDecoration = BoxDecoration(
  color: AdminColors.surface,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  boxShadow: [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8)),
  ],
);


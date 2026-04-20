import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/admin_theme.dart';

class ActivityTimelineCard extends StatelessWidget {
  const ActivityTimelineCard({super.key, required this.items});

  final List<ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Hoạt động gần đây', action: 'Xem tất cả'),
          const SizedBox(height: 12),
          Column(
            children: items
                .asMap()
                .entries
                .map(
                  (entry) => _TimelineRow(
                    item: entry.value,
                    showLine: entry.key != items.length - 1,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item, required this.showLine});

  final ActivityItem item;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 16),
              ),
              if (showLine)
                Container(
                  width: 2,
                  height: 26,
                  color: AdminColors.border,
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(height: 2),
                Text(item.subtitle, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AdminColors.textSecondary)),
              ],
            ),
          ),
          Text(item.time, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AdminColors.textSecondary)),
        ],
      ),
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

class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String time;
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


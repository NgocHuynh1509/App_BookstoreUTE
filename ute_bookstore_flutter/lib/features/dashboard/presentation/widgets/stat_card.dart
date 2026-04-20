import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../theme/admin_theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.isMoney = false,
    this.trendPercent,
    this.trendLabel,
  });

  final String title;
  final double value;
  final IconData icon;
  final Color accentColor;
  final bool isMoney;
  final double? trendPercent;
  final String? trendLabel;

  @override
  Widget build(BuildContext context) {
    final trend = trendPercent;
    final trendColor = (trend ?? 0) >= 0 ? AdminColors.success : AdminColors.danger;
    final displayValue = isMoney ? _formatCurrency(value) : _formatNumber(value);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        trend >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 12,
                        color: trendColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${trend.abs().toStringAsFixed(1)}%',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: trendColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: GoogleFonts.beVietnamPro(fontSize: 11, color: AdminColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            displayValue,
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          if (trendLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              trendLabel!,
              style: GoogleFonts.beVietnamPro(fontSize: 10, color: AdminColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatCurrency(num value) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(value).replaceAll(',', '.')} đ';
}

String _formatNumber(num value) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return formatter.format(value).replaceAll(',', '.');
}


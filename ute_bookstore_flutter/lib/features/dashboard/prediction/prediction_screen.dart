import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/dashboard_models.dart';
import '../presentation/widgets/revenue_prediction_card.dart';
import 'prediction_provider.dart';
import 'prediction_service.dart';

class PredictionSection extends ConsumerWidget {
  const PredictionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionAsync = ref.watch(predictionProvider);

    return predictionAsync.when(
      data: (prediction) => RevenuePredictionCard(prediction: prediction),
      loading: () => const _PredictionLoadingCard(),
      error: (error, _) => RevenuePredictionError(
        message: _mapErrorMessage(error),
        onRetry: () => ref.read(predictionProvider.notifier).retry(),
      ),
    );
  }

  String _mapErrorMessage(Object error) {
    if (error is PredictionTimeoutException) {
      return error.message;
    }
    final message = error.toString();
    if (message.toLowerCase().contains('timeout')) {
      return 'Máy chủ đang xử lý dữ liệu lâu hơn bình thường. Vui lòng thử lại.';
    }
    return message;
  }
}

class _PredictionLoadingCard extends StatelessWidget {
  const _PredictionLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dự đoán doanh thu',
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
              const SizedBox(width: 12),
              Text(
                'Đang dự đoán...',
                style: GoogleFonts.beVietnamPro(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  boxShadow: [
    BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 6)),
  ],
);


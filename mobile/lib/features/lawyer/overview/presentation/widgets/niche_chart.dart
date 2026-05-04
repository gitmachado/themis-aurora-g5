import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../../../features/procedures/domain/entities/legal_process.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';

class NicheChart extends StatelessWidget {
  final List<LegalProcess> procedures;

  const NicheChart({super.key, required this.procedures});

  @override
  Widget build(BuildContext context) {
    final data = _buildData();

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribuição por nicho', style: AppTextStyles.cap),
          const SizedBox(height: 24),
          if (data.isEmpty)
            Text('Nenhum trâmite encontrado', style: AppTextStyles.caption)
          else
            Row(
              children: [
                SizedBox(
                  height: 140,
                  width: 140,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: const Size(140, 140),
                        painter: _DonutChartPainter(data: data),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${procedures.length}',
                              style: AppTextStyles.h1.copyWith(fontSize: 20),
                            ),
                            Text(
                              'Total',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(children: data.map(_buildLegendItem).toList()),
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<_ChartItem> _buildData() {
    final counts = <String, int>{};
    for (final procedure in procedures) {
      final label = procedure.caseType?.trim().isNotEmpty == true
          ? procedure.caseType!.trim()
          : 'Nao informado';
      counts[label] = (counts[label] ?? 0) + 1;
    }

    final total = procedures.length;
    if (total == 0) return const [];

    final colors = [
      AppColors.yellow,
      AppColors.ink,
      AppColors.yellow2,
      AppColors.surface3,
      AppColors.success,
    ];

    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return [
      for (var i = 0; i < entries.length; i++)
        _ChartItem(
          label: entries[i].key,
          percentage: entries[i].value / total,
          color: colors[i % colors.length],
        ),
    ];
  }

  Widget _buildLegendItem(_ChartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textBody,
              ),
            ),
          ),
          Text(
            '${(item.percentage * 100).round()}%',
            style: AppTextStyles.caption.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartItem {
  final String label;
  final double percentage;
  final Color color;

  const _ChartItem({
    required this.label,
    required this.percentage,
    required this.color,
  });
}

class _DonutChartPainter extends CustomPainter {
  final List<_ChartItem> data;

  _DonutChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.35;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    double startAngle = -math.pi / 2;

    for (final item in data) {
      final sweepAngle = item.percentage * 2 * math.pi;
      final gap = data.length == 1 ? 0.0 : 0.04;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        rect,
        startAngle + gap,
        math.max(0.0, sweepAngle - (gap * 2)),
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

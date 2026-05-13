import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../domain/entities/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      hasBorder: true,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _colorForType(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.title,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textCaption,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AppBadge(
                          label: appointment.typeLabel.toUpperCase(),
                          type: _badgeTypeForType(),
                        ),
                      ],
                    ),
                    if (appointment.isDeadline && _showCountdown())
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _countdownText(),
                          style: AppTextStyles.tiny.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForType() => switch (appointment.type) {
    'DEADLINE' => AppColors.error,
    'HEARING' => AppColors.warning,
    _ => AppColors.ink,
  };

  BadgeType _badgeTypeForType() => switch (appointment.type) {
    'DEADLINE' => BadgeType.error,
    'HEARING' => BadgeType.warning,
    'MEETING' => BadgeType.primary,
    _ => BadgeType.neutral,
  };

  String _formatTime() {
    final time = appointment.scheduledAt;
    final endTime = appointment.endTime;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  bool _showCountdown() {
    final timeUntil = appointment.timeUntilStart;
    return timeUntil != null && timeUntil.inHours < 24;
  }

  String _countdownText() {
    final timeUntil = appointment.timeUntilStart;
    if (timeUntil == null) return 'Vencido';

    if (timeUntil.inHours > 0) {
      return '⚠️ Vence em ${timeUntil.inHours}h';
    } else if (timeUntil.inMinutes > 0) {
      return '🔴 Vence em ${timeUntil.inMinutes}m';
    } else {
      return '🔴 VENCENDO AGORA';
    }
  }
}

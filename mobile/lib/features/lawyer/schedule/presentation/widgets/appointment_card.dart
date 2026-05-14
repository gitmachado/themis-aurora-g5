import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../domain/entities/appointment.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';

class AppointmentCard extends ConsumerWidget {
  final Appointment appointment;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = appointment.status == 'COMPLETED';
    final isCanceled = appointment.status == 'CANCELED';
    final procedures = ref.watch(myProceduresProvider).valueOrNull ?? const [];
    final processName = appointment.processId != null
        ? procedures
            .where((p) => p.id == appointment.processId)
            .map((p) => p.title)
            .firstOrNull ?? 'Processo Vinculado'
        : null;

    return AppCard(
      onTap: !isCanceled ? onTap : null,
      hasBorder: true,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _colorForStatus(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 12, right: 16, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            appointment.title,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isCanceled ? AppColors.ink3 : AppColors.ink,
                              decoration: isCanceled
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (appointment.status == 'COMPLETED' || appointment.status == 'CANCELED') ...[
                          const SizedBox(width: 8),
                          _buildStatusIcon(),
                        ],
                        const SizedBox(width: 8),
                        AppBadge(
                          label: appointment.typeLabel.toUpperCase(),
                          type: _badgeTypeForType(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: AppColors.textCaption,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${_formatTime()} (${appointment.durationMinutes} min)',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textCaption,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (appointment.description != null &&
                        appointment.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        appointment.description!,
                        style: AppTextStyles.caption.copyWith(
                          color: isCanceled ? AppColors.ink3 : AppColors.ink2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (appointment.processId != null && processName != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              processName,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if ((appointment.isDeadline || appointment.isHearing) &&
                        _showCountdown() &&
                        !isCompleted &&
                        !isCanceled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _countdownText(),
                            style: AppTextStyles.tiny.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
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

  Widget _buildStatusIcon() {
    if (appointment.status == 'COMPLETED') {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: Colors.green,
        ),
      );
    } else if (appointment.status == 'CANCELED') {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.cancel_rounded,
          size: 16,
          color: AppColors.error,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Color _colorForStatus() {
    if (appointment.status == 'COMPLETED') {
      return Colors.green;
    } else if (appointment.status == 'CANCELED') {
      return AppColors.error;
    }
    return _colorForType();
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
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    return '$day/$month às ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
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

import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/sizes.dart';
import '../../models/appointment.dart';

class StatusChip extends StatelessWidget {
  final ApptStatus status;
  final bool isAr;

  const StatusChip({super.key, required this.status, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      ApptStatus.confirmed => (
          isAr ? 'مؤكد' : 'Confirmed',
          JuhColors.successSoft,
          JuhColors.statusConfirmed,
        ),
      ApptStatus.cancelled => (
          isAr ? 'ملغى' : 'Cancelled',
          JuhColors.errorSoft,
          JuhColors.statusCancelled,
        ),
      ApptStatus.pending => (
          isAr ? 'بانتظار التأكيد' : 'Pending',
          JuhColors.warningSoft,
          JuhColors.statusPending,
        ),
      ApptStatus.completed => (
          isAr ? 'مكتمل' : 'Completed',
          JuhColors.primarySoft,
          JuhColors.primary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: JuhSizes.fontXs,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

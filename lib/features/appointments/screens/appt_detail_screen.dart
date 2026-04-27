import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../models/appointment.dart';
import '../../../providers/appointments_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/alert_banner.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/status_chip.dart';

class ApptDetailScreen extends ConsumerWidget {
  final String apptId;
  const ApptDetailScreen({super.key, required this.apptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final appts = ref.watch(appointmentsProvider);
    final appt = appts.where((a) => a.id == apptId).firstOrNull;

    if (appt == null) {
      return Scaffold(
        appBar: ScreenHeader(titleAr: 'تفاصيل الموعد', titleEn: 'Appointment Details'),
        body: Center(child: Text(isAr ? 'لم يتم العثور على الموعد' : 'Appointment not found')),
      );
    }

    final dateFmt = DateFormat(isAr ? 'EEEE، d MMMM yyyy' : 'EEEE, d MMMM yyyy', isAr ? 'ar' : 'en');
    final timeFmt = DateFormat('hh:mm a');
    final isCancellable = appt.status == ApptStatus.confirmed && appt.dateTime.isAfter(DateTime.now());

    return Scaffold(
      appBar: ScreenHeader(titleAr: 'تفاصيل الموعد', titleEn: 'Appointment Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(JuhSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Doctor header card
            Container(
              padding: const EdgeInsets.all(JuhSizes.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [JuhColors.primary, JuhColors.primaryInk],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white24,
                    child: Text(
                      (isAr ? appt.doctorNameAr : appt.doctorNameEn).replaceAll('د. ', '').replaceAll('Dr. ', '')[0],
                      style: const TextStyle(color: Colors.white, fontSize: JuhSizes.fontXl, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: JuhSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? appt.doctorNameAr : appt.doctorNameEn,
                          style: const TextStyle(color: Colors.white, fontSize: JuhSizes.fontMd, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          isAr ? appt.doctorTitleAr : appt.doctorTitleEn,
                          style: const TextStyle(color: Colors.white70, fontSize: JuhSizes.fontSm),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr ? appt.specialtyAr : appt.specialtyEn,
                          style: const TextStyle(color: Colors.white60, fontSize: JuhSizes.fontXs),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: appt.status, isAr: isAr),
                ],
              ),
            ),
            const SizedBox(height: JuhSizes.md),

            // Reference code
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: appt.refCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isAr ? 'تم نسخ الكود' : 'Code copied')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(JuhSizes.md),
                decoration: BoxDecoration(
                  color: JuhColors.primarySoft,
                  borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? 'رقم المرجع' : 'Reference',
                      style: const TextStyle(color: JuhColors.primaryInk, fontSize: JuhSizes.fontSm),
                    ),
                    Row(
                      children: [
                        Text(
                          appt.refCode,
                          style: const TextStyle(
                            color: JuhColors.primary,
                            fontSize: JuhSizes.fontBase,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.copy, size: 16, color: JuhColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: JuhSizes.md),

            // Details card
            _DetailCard(rows: [
              (Icons.person_outline, isAr ? 'المريض' : 'Patient', isAr ? appt.patientNameAr : appt.patientNameEn),
              (Icons.shield_outlined, isAr ? 'التأمين' : 'Insurance', isAr ? appt.insuranceAr : appt.insuranceEn),
              (Icons.calendar_today_outlined, isAr ? 'التاريخ' : 'Date', dateFmt.format(appt.dateTime)),
              (Icons.access_time, isAr ? 'الوقت' : 'Time', timeFmt.format(appt.dateTime)),
              (Icons.location_on_outlined, isAr ? 'الموقع' : 'Location', appt.location),
            ], isAr: isAr),

            const SizedBox(height: JuhSizes.md),

            if (appt.status == ApptStatus.cancelled)
              AlertBanner(
                message: isAr ? 'هذا الموعد ملغى' : 'This appointment has been cancelled',
                type: AlertType.error,
              ),

            if (isCancellable) ...[
              const SizedBox(height: JuhSizes.lg),
              AppButton(
                label: isAr ? 'إعادة جدولة' : 'Reschedule',
                onTap: () => context.push('/booking?who=${appt.patientNameAr}'),
                icon: Icons.edit_calendar,
              ),
              const SizedBox(height: JuhSizes.sm),
              AppButton.outline(
                label: isAr ? 'إلغاء الموعد' : 'Cancel Appointment',
                onTap: () => _showCancelDialog(context, ref, appt, isAr),
              ),
            ],
            const SizedBox(height: JuhSizes.md),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, Appointment appt, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'إلغاء الموعد' : 'Cancel Appointment'),
        content: Text(isAr
            ? 'هل أنت متأكد من إلغاء هذا الموعد؟'
            : 'Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'لا' : 'No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: JuhColors.error),
            onPressed: () {
              ref.read(appointmentsProvider.notifier).cancel(appt.id);
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text(isAr ? 'نعم، إلغاء' : 'Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<(IconData, String, String)> rows;
  final bool isAr;
  const _DetailCard({required this.rows, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border.all(color: context.cs.outline),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md, vertical: 12),
                child: Row(
                  children: [
                    Icon(row.$1, size: JuhSizes.iconMd, color: JuhColors.primary),
                    const SizedBox(width: JuhSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(row.$2, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
                          Text(row.$3, style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < rows.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

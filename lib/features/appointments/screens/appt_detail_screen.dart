import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../models/appointment.dart';
import '../../../providers/appointments_provider.dart';
import '../../../providers/locale_provider.dart';
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
        appBar: const ScreenHeader(
            titleAr: 'تفاصيل الموعد',
            titleEn: 'Appointment Details'),
        body: Center(
            child: Text(
          isAr ? 'لم يتم العثور على الموعد' : 'Appointment not found',
          style: TextStyle(color: context.juhTextSub),
        )),
      );
    }

    final dateFmt = DateFormat(
        isAr ? 'EEEE، d MMMM yyyy' : 'EEEE, d MMMM yyyy',
        isAr ? 'ar' : 'en');
    final timeFmt = DateFormat('hh:mm a');
    final isCancellable = appt.status == ApptStatus.confirmed &&
        appt.dateTime.isAfter(DateTime.now());

    final doctorName = isAr ? appt.doctorNameAr : appt.doctorNameEn;
    final initial = doctorName
        .replaceAll('د. ', '')
        .replaceAll('Dr. ', '')[0];

    return Scaffold(
      backgroundColor: context.juhBg,
      appBar: const ScreenHeader(
          titleAr: 'تفاصيل الموعد', titleEn: 'Appointment Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(JuhSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero card ──
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection:
                        isAr ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: JuhSizes.fontXl,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: JuhSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: JuhSizes.fontMd,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              isAr
                                  ? appt.doctorTitleAr
                                  : appt.doctorTitleEn,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: JuhSizes.fontSm),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(status: appt.status, isAr: isAr),
                    ],
                  ),
                  const SizedBox(height: JuhSizes.md),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: JuhSizes.md),
                  Row(
                    textDirection:
                        isAr ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Colors.white70, size: JuhSizes.iconSm),
                      const SizedBox(width: 6),
                      Text(
                        dateFmt.format(appt.dateTime),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: JuhSizes.fontSm),
                      ),
                      const SizedBox(width: JuhSizes.md),
                      const Icon(Icons.access_time_outlined,
                          color: Colors.white70, size: JuhSizes.iconSm),
                      const SizedBox(width: 6),
                      Text(
                        timeFmt.format(appt.dateTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: JuhSizes.fontSm,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuhSizes.md),

            // ── Reference code (tap to copy) ──
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: appt.refCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            isAr ? 'تم نسخ الكود' : 'Code copied')),
                  );
                },
                splashColor: JuhColors.primary.withValues(alpha: 0.12),
                highlightColor: JuhColors.primary.withValues(alpha: 0.06),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: JuhSizes.md, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.juhPrimarySoft,
                    borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
                  ),
                  child: Row(
                    textDirection:
                        isAr ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Text(
                        isAr ? 'رقم المرجع' : 'Reference',
                        style: const TextStyle(
                            color: JuhColors.primaryInk,
                            fontSize: JuhSizes.fontSm),
                      ),
                      const Spacer(),
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
                      const Icon(Icons.copy,
                          size: 16, color: JuhColors.primary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: JuhSizes.md),

            // ── Detail rows ──
            _DetailCard(
              isAr: isAr,
              rows: [
                (
                  Icons.person_outline,
                  isAr ? 'المريض' : 'Patient',
                  isAr ? appt.patientNameAr : appt.patientNameEn
                ),
                (
                  Icons.shield_outlined,
                  isAr ? 'التأمين' : 'Insurance',
                  isAr ? appt.insuranceAr : appt.insuranceEn
                ),
                (
                  Icons.local_hospital_outlined,
                  isAr ? 'التخصص' : 'Specialty',
                  isAr ? appt.specialtyAr : appt.specialtyEn
                ),
                (
                  Icons.location_on_outlined,
                  isAr ? 'الموقع' : 'Location',
                  appt.location
                ),
              ],
            ),
            const SizedBox(height: JuhSizes.md),

            // ── Action buttons 2×2 ──
            if (isCancellable) ...[
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3,
                children: [
                  _ActionBtn(
                    icon: Icons.edit_calendar_outlined,
                    label: isAr ? 'إعادة جدولة' : 'Reschedule',
                    onTap: () => context.push('/booking?who=self'),
                    color: JuhColors.primary,
                  ),
                  _ActionBtn(
                    icon: Icons.cancel_outlined,
                    label: isAr ? 'إلغاء الموعد' : 'Cancel',
                    onTap: () =>
                        _showCancelDialog(context, ref, appt, isAr),
                    color: JuhColors.error,
                  ),
                  _ActionBtn(
                    icon: Icons.note_add_outlined,
                    label: isAr ? 'إضافة ملاحظة' : 'Add Note',
                    onTap: () {},
                    color: JuhColors.textSecondary,
                  ),
                  _ActionBtn(
                    icon: Icons.share_outlined,
                    label: isAr ? 'مشاركة' : 'Share',
                    onTap: () {},
                    color: JuhColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: JuhSizes.md),
            ],

            if (appt.status == ApptStatus.cancelled)
              Container(
                padding: const EdgeInsets.all(JuhSizes.md),
                decoration: BoxDecoration(
                  color: context.juhErrorSoft,
                  borderRadius:
                      BorderRadius.circular(JuhSizes.radiusMd),
                  border: Border.all(
                      color: JuhColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  textDirection:
                      isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    const Icon(Icons.cancel_outlined,
                        color: JuhColors.error,
                        size: JuhSizes.iconMd),
                    const SizedBox(width: JuhSizes.sm),
                    Text(
                      isAr
                          ? 'هذا الموعد ملغى'
                          : 'This appointment has been cancelled',
                      style: const TextStyle(
                          color: JuhColors.error,
                          fontSize: JuhSizes.fontSm,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: JuhSizes.lg),

            AppButton.ghost(
              label: isAr ? 'العودة للمواعيد' : 'Back to Appointments',
              onTap: () => context.pop(),
            ),
            const SizedBox(height: JuhSizes.md),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, WidgetRef ref, Appointment appt, bool isAr) {
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
            style: ElevatedButton.styleFrom(
                backgroundColor: JuhColors.error,
                foregroundColor: Colors.white),
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
        color: context.juhSurface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border.all(color: context.juhBorder),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: JuhSizes.md, vertical: 12),
                child: Row(
                  textDirection:
                      isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.juhPrimarySoft,
                        borderRadius:
                            BorderRadius.circular(JuhSizes.radiusSm),
                      ),
                      child: Icon(row.$1,
                          size: JuhSizes.iconMd,
                          color: JuhColors.primary),
                    ),
                    const SizedBox(width: JuhSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.$2,
                            style: TextStyle(
                              fontSize: JuhSizes.fontXs,
                              color: context.juhTextSub,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            row.$3,
                            style: TextStyle(
                              fontSize: JuhSizes.fontSm,
                              fontWeight: FontWeight.w600,
                              color: context.juhText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                Divider(height: 1, color: context.juhBorder),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.onTap,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withValues(alpha: 0.12),
        highlightColor: color.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(
            color: context.juhSurface,
            borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
            border: Border.all(color: context.juhBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: JuhSizes.iconMd),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: JuhSizes.fontXs,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

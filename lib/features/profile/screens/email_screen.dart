import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../models/appointment.dart';
import '../../../providers/appointments_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/screen_header.dart';

class EmailScreen extends ConsumerWidget {
  const EmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final appts = ref.watch(appointmentsProvider);
    final profile = ref.watch(profileProvider);
    final confirmed = appts.where((a) => a.status == ApptStatus.confirmed).toList();

    return Scaffold(
      appBar: ScreenHeader(
        titleAr: 'رسائل التأكيد',
        titleEn: 'Email Confirmations',
      ),
      body: confirmed.isEmpty
          ? Center(
              child: Text(
                isAr ? 'لا توجد رسائل' : 'No email messages',
                style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(JuhSizes.md),
              separatorBuilder: (_, __) => const SizedBox(height: JuhSizes.sm),
              itemCount: confirmed.length,
              itemBuilder: (ctx, i) => _EmailCard(appt: confirmed[i], isAr: isAr, email: profile.email),
            ),
    );
  }
}

class _EmailCard extends StatelessWidget {
  final Appointment appt;
  final bool isAr;
  final String email;
  const _EmailCard({required this.appt, required this.isAr, required this.email});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat(isAr ? 'd MMMM yyyy — hh:mm a' : 'd MMMM yyyy — hh:mm a', isAr ? 'ar' : 'en');

    return Container(
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border.all(color: context.cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md, vertical: JuhSizes.sm + 2),
            decoration: BoxDecoration(
              color: JuhColors.primarySoft,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(JuhSizes.radiusLg)),
            ),
            child: Row(
              children: [
                const Icon(Icons.email_outlined, color: JuhColors.primary, size: JuhSizes.iconMd),
                const SizedBox(width: JuhSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'تأكيد موعد — مستشفى الجامعة الأردنية' : 'Appointment Confirmation — JUH',
                        style: const TextStyle(
                          color: JuhColors.primaryInk,
                          fontWeight: FontWeight.w600,
                          fontSize: JuhSizes.fontSm,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(color: JuhColors.primary, fontSize: JuhSizes.fontXs),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Email body
          Padding(
            padding: const EdgeInsets.all(JuhSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr
                      ? 'عزيزي ${appt.patientNameAr}،'
                      : 'Dear ${appt.patientNameEn},',
                  style: context.tt.bodyMedium,
                ),
                const SizedBox(height: JuhSizes.sm),
                Text(
                  isAr
                      ? 'يسرنا إبلاغك بتأكيد موعدك في مستشفى الجامعة الأردنية.'
                      : 'We are pleased to confirm your appointment at Jordan University Hospital.',
                  style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                ),
                const SizedBox(height: JuhSizes.md),
                _EmailRow(label: isAr ? 'الطبيب' : 'Doctor', value: isAr ? appt.doctorNameAr : appt.doctorNameEn),
                _EmailRow(label: isAr ? 'التخصص' : 'Specialty', value: isAr ? appt.specialtyAr : appt.specialtyEn),
                _EmailRow(label: isAr ? 'الموعد' : 'Date & Time', value: dateFmt.format(appt.dateTime)),
                _EmailRow(label: isAr ? 'الموقع' : 'Location', value: appt.location),
                const SizedBox(height: JuhSizes.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md, vertical: JuhSizes.sm),
                  decoration: BoxDecoration(
                    color: JuhColors.primarySoft,
                    borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? 'رقم المرجع' : 'Reference', style: const TextStyle(color: JuhColors.primaryInk, fontSize: JuhSizes.fontXs)),
                      Text(appt.refCode, style: const TextStyle(color: JuhColors.primary, fontWeight: FontWeight.w800, fontSize: JuhSizes.fontBase)),
                    ],
                  ),
                ),
                const SizedBox(height: JuhSizes.sm),
                Text(
                  isAr
                      ? 'يرجى الحضور قبل الموعد بـ ١٥ دقيقة وإحضار هويتك ووثائق التأمين.'
                      : 'Please arrive 15 minutes early and bring your ID and insurance documents.',
                  style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailRow extends StatelessWidget {
  final String label;
  final String value;
  const _EmailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: context.tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

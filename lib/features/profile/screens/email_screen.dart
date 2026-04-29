import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/colors.dart';
import '../../../core/sizes.dart';
import '../../../models/appointment.dart';
import '../../../providers/appointments_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/screen_header.dart';

class EmailScreen extends ConsumerStatefulWidget {
  const EmailScreen({super.key});

  @override
  ConsumerState<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends ConsumerState<EmailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final appts = ref.watch(appointmentsProvider);
    final profile = ref.watch(profileProvider);

    final confirmed =
        appts.where((a) => a.status == ApptStatus.confirmed).toList();
    final all = List<Appointment>.from(appts);

    return Scaffold(
      backgroundColor: JuhColors.bg,
      appBar: ScreenHeader(
        titleAr: 'البريد الوارد',
        titleEn: 'Inbox',
        bottom: TabBar(
          controller: _tabs,
          labelColor: JuhColors.primary,
          unselectedLabelColor: JuhColors.textSecondary,
          indicatorColor: JuhColors.primary,
          labelStyle: const TextStyle(
              fontSize: JuhSizes.fontSm, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: JuhSizes.fontSm),
          tabs: [
            Tab(text: isAr ? 'تأكيدات (${confirmed.length})' : 'Confirmations (${confirmed.length})'),
            Tab(text: isAr ? 'تذكيرات (${all.length})' : 'Reminders (${all.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _EmailListView(
              appts: confirmed,
              isAr: isAr,
              email: profile.email,
              isReminder: false),
          _EmailListView(
              appts: all,
              isAr: isAr,
              email: profile.email,
              isReminder: true),
        ],
      ),
    );
  }
}

class _EmailListView extends StatelessWidget {
  final List<Appointment> appts;
  final bool isAr;
  final String email;
  final bool isReminder;
  const _EmailListView(
      {required this.appts,
      required this.isAr,
      required this.email,
      required this.isReminder});

  @override
  Widget build(BuildContext context) {
    if (appts.isEmpty) {
      return Center(
        child: Text(
          isAr ? 'لا توجد رسائل' : 'No messages',
          style: const TextStyle(
              fontSize: JuhSizes.fontSm, color: JuhColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(JuhSizes.md),
      separatorBuilder: (_, __) => const SizedBox(height: JuhSizes.sm),
      itemCount: appts.length,
      itemBuilder: (ctx, i) => _EmailCard(
          appt: appts[i],
          isAr: isAr,
          email: email,
          isReminder: isReminder),
    );
  }
}

class _EmailCard extends StatelessWidget {
  final Appointment appt;
  final bool isAr;
  final String email;
  final bool isReminder;
  const _EmailCard(
      {required this.appt,
      required this.isAr,
      required this.email,
      required this.isReminder});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat(
        isAr ? 'd MMMM yyyy — hh:mm a' : 'MMM d, yyyy — hh:mm a',
        isAr ? 'ar' : 'en');

    final subject = isReminder
        ? (isAr
            ? 'تذكير: موعدك غداً — ${appt.doctorNameAr}'
            : 'Reminder: Appointment Tomorrow — ${appt.doctorNameEn}')
        : (isAr
            ? 'تأكيد موعد — مستشفى الجامعة الأردنية'
            : 'Appointment Confirmation — JUH');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border.all(color: JuhColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email header row
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: JuhSizes.md, vertical: 12),
            decoration: const BoxDecoration(
              color: JuhColors.primarySoft,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(JuhSizes.radiusLg)),
            ),
            child: Row(
              textDirection:
                  isAr ? TextDirection.rtl : TextDirection.ltr,
              children: [
                // JUH avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: JuhColors.primary,
                    borderRadius:
                        BorderRadius.circular(JuhSizes.radiusSm),
                  ),
                  child: const Center(
                    child: Text(
                      'J',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: JuhSizes.fontMd,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: JuhSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isAr
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                          color: JuhColors.primaryInk,
                          fontWeight: FontWeight.w600,
                          fontSize: JuhSizes.fontSm,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                            color: JuhColors.primary,
                            fontSize: JuhSizes.fontXs),
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
              crossAxisAlignment: isAr
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  isAr
                      ? 'عزيزي ${appt.patientNameAr}،'
                      : 'Dear ${appt.patientNameEn},',
                  style: const TextStyle(
                    fontSize: JuhSizes.fontSm,
                    fontWeight: FontWeight.w600,
                    color: JuhColors.textPrimary,
                  ),
                ),
                const SizedBox(height: JuhSizes.sm),
                Text(
                  isReminder
                      ? (isAr
                          ? 'تذكير بموعدك القادم في مستشفى الجامعة الأردنية.'
                          : 'A reminder of your upcoming appointment at Jordan University Hospital.')
                      : (isAr
                          ? 'يسرنا إبلاغك بتأكيد موعدك في مستشفى الجامعة الأردنية.'
                          : 'We are pleased to confirm your appointment at Jordan University Hospital.'),
                  style: const TextStyle(
                      fontSize: JuhSizes.fontXs,
                      color: JuhColors.textSecondary,
                      height: 1.5),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: JuhSizes.md),

                _EmailRow(
                    isAr: isAr,
                    label: isAr ? 'الطبيب' : 'Doctor',
                    value: isAr ? appt.doctorNameAr : appt.doctorNameEn),
                _EmailRow(
                    isAr: isAr,
                    label: isAr ? 'التخصص' : 'Specialty',
                    value: isAr ? appt.specialtyAr : appt.specialtyEn),
                _EmailRow(
                    isAr: isAr,
                    label: isAr ? 'الموعد' : 'Date & Time',
                    value: dateFmt.format(appt.dateTime)),
                _EmailRow(
                    isAr: isAr,
                    label: isAr ? 'الموقع' : 'Location',
                    value: appt.location),

                const SizedBox(height: JuhSizes.sm),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: JuhSizes.md, vertical: JuhSizes.sm),
                  decoration: BoxDecoration(
                    color: JuhColors.primarySoft,
                    borderRadius:
                        BorderRadius.circular(JuhSizes.radiusSm),
                  ),
                  child: Row(
                    textDirection:
                        isAr ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Text(
                        isAr ? 'رقم المرجع' : 'Reference',
                        style: const TextStyle(
                            color: JuhColors.primaryInk,
                            fontSize: JuhSizes.fontXs),
                      ),
                      const Spacer(),
                      Text(
                        appt.refCode,
                        style: const TextStyle(
                          color: JuhColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: JuhSizes.fontBase,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: JuhSizes.sm),
                Text(
                  isAr
                      ? 'يرجى الحضور قبل الموعد بـ ١٥ دقيقة وإحضار هويتك ووثائق التأمين.'
                      : 'Please arrive 15 minutes early and bring your ID and insurance documents.',
                  style: const TextStyle(
                    fontSize: JuhSizes.fontXs,
                    color: JuhColors.textSecondary,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
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
  final bool isAr;
  final String label;
  final String value;
  const _EmailRow(
      {required this.isAr, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                  fontSize: JuhSizes.fontXs,
                  color: JuhColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                fontSize: JuhSizes.fontXs,
                fontWeight: FontWeight.w600,
                color: JuhColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

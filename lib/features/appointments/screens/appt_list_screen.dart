import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../models/appointment.dart';
import '../../../providers/appointments_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/status_chip.dart';

class ApptListScreen extends ConsumerStatefulWidget {
  const ApptListScreen({super.key});

  @override
  ConsumerState<ApptListScreen> createState() => _ApptListScreenState();
}

class _ApptListScreenState extends ConsumerState<ApptListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final all = ref.watch(appointmentsProvider);
    final now = DateTime.now();

    final upcoming = all
        .where((a) =>
            a.status == ApptStatus.confirmed && a.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final completed = all
        .where((a) =>
            a.status == ApptStatus.completed ||
            (a.status == ApptStatus.confirmed && a.dateTime.isBefore(now)))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final cancelled = all
        .where((a) => a.status == ApptStatus.cancelled)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      backgroundColor: context.juhBg,
      appBar: ScreenHeader(
        titleAr: 'مواعيدي',
        titleEn: 'My Appointments',
        bottom: TabBar(
          controller: _tabs,
          labelColor: JuhColors.primary,
          unselectedLabelColor: context.juhTextSub,
          indicatorColor: JuhColors.primary,
          labelStyle: const TextStyle(
              fontSize: JuhSizes.fontSm, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: JuhSizes.fontSm),
          tabs: [
            Tab(
                text: isAr
                    ? 'قادمة (${upcoming.length})'
                    : 'Upcoming (${upcoming.length})'),
            Tab(
                text: isAr
                    ? 'سابقة (${completed.length})'
                    : 'Past (${completed.length})'),
            Tab(
                text: isAr
                    ? 'ملغاة (${cancelled.length})'
                    : 'Cancelled (${cancelled.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ApptListView(
              appts: upcoming, isAr: isAr, showReschedule: true),
          _ApptListView(appts: completed, isAr: isAr),
          _ApptListView(appts: cancelled, isAr: isAr),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/relatives'),
        icon: const Icon(Icons.add),
        label: Text(isAr ? 'حجز موعد' : 'Book'),
        backgroundColor: JuhColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _ApptListView extends StatelessWidget {
  final List<Appointment> appts;
  final bool isAr;
  final bool showReschedule;
  const _ApptListView(
      {required this.appts,
      required this.isAr,
      this.showReschedule = false});

  @override
  Widget build(BuildContext context) {
    if (appts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 56, color: context.juhTextMuted),
            const SizedBox(height: JuhSizes.md),
            Text(
              isAr ? 'لا توجد مواعيد' : 'No appointments',
              style: TextStyle(
                  fontSize: JuhSizes.fontBase,
                  color: context.juhTextSub),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(JuhSizes.md),
      separatorBuilder: (_, __) => const SizedBox(height: JuhSizes.sm),
      itemCount: appts.length,
      itemBuilder: (ctx, i) => _ApptCard(
          appt: appts[i], isAr: isAr, showReschedule: showReschedule),
    );
  }
}

class _ApptCard extends StatelessWidget {
  final Appointment appt;
  final bool isAr;
  final bool showReschedule;
  const _ApptCard(
      {required this.appt,
      required this.isAr,
      this.showReschedule = false});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat(
        isAr ? 'd MMMM yyyy' : 'MMM d, yyyy', isAr ? 'ar' : 'en');
    final timeFmt = DateFormat('hh:mm a');

    final doctorName =
        isAr ? appt.doctorNameAr : appt.doctorNameEn;
    final initial = doctorName
        .replaceAll('د. ', '')
        .replaceAll('Dr. ', '')[0];

    // Show "للقريب" badge if patient is a relative (not self name)
    final isForRelative = appt.patientNameEn != 'Faris Ahmed';

    return Container(
      padding: const EdgeInsets.all(JuhSizes.md),
      decoration: BoxDecoration(
        color: context.juhSurface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border.all(color: context.juhBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor + status row
          Row(
            textDirection:
                isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: context.juhPrimarySoft, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: JuhColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: JuhSizes.fontMd,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: JuhSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: TextStyle(
                        fontSize: JuhSizes.fontBase,
                        fontWeight: FontWeight.w700,
                        color: context.juhText,
                      ),
                    ),
                    Text(
                      isAr ? appt.specialtyAr : appt.specialtyEn,
                      style: TextStyle(
                          fontSize: JuhSizes.fontXs,
                          color: context.juhTextSub),
                    ),
                  ],
                ),
              ),
              StatusChip(status: appt.status, isAr: isAr),
            ],
          ),

          const SizedBox(height: JuhSizes.sm),
          Divider(height: 1, color: context.juhBorder),
          const SizedBox(height: JuhSizes.sm),

          // Date/time + patient
          Row(
            textDirection:
                isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Icon(Icons.access_time_outlined,
                  size: 14, color: context.juhTextSub),
              const SizedBox(width: 4),
              Text(
                '${dateFmt.format(appt.dateTime)}  ${timeFmt.format(appt.dateTime)}',
                style: TextStyle(
                    fontSize: JuhSizes.fontXs,
                    color: context.juhTextSub),
              ),
              const Spacer(),
              if (isForRelative)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.juhWarningSoft,
                    borderRadius:
                        BorderRadius.circular(JuhSizes.radiusFull),
                  ),
                  child: Text(
                    isAr ? 'للقريب' : 'Relative',
                    style: const TextStyle(
                      fontSize: JuhSizes.fontXs,
                      fontWeight: FontWeight.w600,
                      color: JuhColors.warning,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: JuhSizes.sm),

          // Action buttons
          Row(
            textDirection:
                isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      context.push('/appointments/${appt.id}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: JuhColors.primary,
                    side: const BorderSide(color: JuhColors.primary),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            JuhSizes.radiusSm)),
                    textStyle: const TextStyle(
                        fontSize: JuhSizes.fontXs,
                        fontWeight: FontWeight.w600),
                  ),
                  child: Text(isAr ? 'التفاصيل' : 'Details'),
                ),
              ),
              if (showReschedule) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        context.push('/booking?who=self'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.juhTextSub,
                      side: BorderSide(color: context.juhBorder),
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              JuhSizes.radiusSm)),
                      textStyle: const TextStyle(
                          fontSize: JuhSizes.fontXs,
                          fontWeight: FontWeight.w600),
                    ),
                    child: Text(isAr ? 'تعديل' : 'Reschedule'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

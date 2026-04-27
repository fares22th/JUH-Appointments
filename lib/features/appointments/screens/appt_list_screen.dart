import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    final notifier = ref.read(appointmentsProvider.notifier);
    final upcoming = notifier.upcoming;
    final past = notifier.past;

    return Scaffold(
      appBar: ScreenHeader(
        titleAr: 'مواعيدي',
        titleEn: 'My Appointments',
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: isAr ? 'القادمة (${upcoming.length})' : 'Upcoming (${upcoming.length})'),
            Tab(text: isAr ? 'السابقة (${past.length})' : 'Past (${past.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ApptListView(appts: upcoming, isAr: isAr),
          _ApptListView(appts: past, isAr: isAr),
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
  const _ApptListView({required this.appts, required this.isAr});

  @override
  Widget build(BuildContext context) {
    if (appts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 56, color: JuhColors.textMuted),
            const SizedBox(height: JuhSizes.md),
            Text(
              isAr ? 'لا توجد مواعيد' : 'No appointments',
              style: context.tt.titleMedium?.copyWith(color: context.cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(JuhSizes.md),
      separatorBuilder: (_, __) => const SizedBox(height: JuhSizes.sm),
      itemCount: appts.length,
      itemBuilder: (ctx, i) => _ApptCard(appt: appts[i], isAr: isAr),
    );
  }
}

class _ApptCard extends StatelessWidget {
  final Appointment appt;
  final bool isAr;
  const _ApptCard({required this.appt, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat(isAr ? 'd MMMM yyyy' : 'd MMMM yyyy', isAr ? 'ar' : 'en');
    final timeFmt = DateFormat('hh:mm a');

    return GestureDetector(
      onTap: () => context.push('/appointments/${appt.id}'),
      child: Container(
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          color: context.cs.surface,
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          border: Border.all(color: context.cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isAr ? appt.doctorNameAr : appt.doctorNameEn,
                    style: context.tt.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusChip(status: appt.status, isAr: isAr),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              isAr ? appt.specialtyAr : appt.specialtyEn,
              style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
            ),
            const SizedBox(height: JuhSizes.sm),
            const Divider(height: 1),
            const SizedBox(height: JuhSizes.sm),
            Row(
              children: [
                _InfoChip(icon: Icons.person_outline, label: isAr ? appt.patientNameAr : appt.patientNameEn),
                const SizedBox(width: JuhSizes.sm),
                _InfoChip(icon: Icons.access_time, label: '${dateFmt.format(appt.dateTime)}  ${timeFmt.format(appt.dateTime)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: context.cs.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(label, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
      ],
    );
  }
}

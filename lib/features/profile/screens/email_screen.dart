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
  final _searchCtrl = TextEditingController();
  String _query = '';
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Appointment> _filtered(List<Appointment> list) {
    var result = list;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      result = result.where((a) {
        return (a.doctorNameAr +
                a.doctorNameEn +
                a.specialtyAr +
                a.specialtyEn)
            .toLowerCase()
            .contains(q);
      }).toList();
    }
    if (_filterDate != null) {
      result = result
          .where((a) =>
              a.dateTime.year == _filterDate!.year &&
              a.dateTime.month == _filterDate!.month &&
              a.dateTime.day == _filterDate!.day)
          .toList();
    }
    return result;
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: JuhColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _filterDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final appts = ref.watch(appointmentsProvider);
    final profile = ref.watch(profileProvider);

    final confirmed =
        appts.where((a) => a.status == ApptStatus.confirmed).toList();
    final all = List<Appointment>.from(appts);

    final filteredConfirmed = _filtered(confirmed);
    final filteredAll = _filtered(all);

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
            Tab(
              text: isAr
                  ? 'تأكيدات (${confirmed.length})'
                  : 'Confirmations (${confirmed.length})',
            ),
            Tab(
              text: isAr
                  ? 'تذكيرات (${all.length})'
                  : 'Reminders (${all.length})',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Search + date filter ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                JuhSizes.md, JuhSizes.sm, JuhSizes.md, 0),
            child: Row(
              textDirection:
                  isAr ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchCtrl,
                      textAlign:
                          isAr ? TextAlign.right : TextAlign.left,
                      decoration: InputDecoration(
                        hintText: isAr ? 'بحث...' : 'Search...',
                        hintStyle: const TextStyle(
                            color: JuhColors.textMuted,
                            fontSize: JuhSizes.fontSm),
                        prefixIcon: const Icon(Icons.search,
                            color: JuhColors.textMuted, size: 20),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    size: 18,
                                    color: JuhColors.textMuted),
                                onPressed: () => _searchCtrl.clear(),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              JuhSizes.radiusMd),
                          borderSide:
                              const BorderSide(color: JuhColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              JuhSizes.radiusMd),
                          borderSide:
                              const BorderSide(color: JuhColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              JuhSizes.radiusMd),
                          borderSide:
                              const BorderSide(color: JuhColors.primary),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: JuhSizes.sm),
                // Date filter chip
                Material(
                  color: Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(JuhSizes.radiusMd),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _pickDate(context),
                    splashColor:
                        JuhColors.primary.withValues(alpha: 0.1),
                    highlightColor: Colors.transparent,
                    child: Container(
                      height: 44,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _filterDate != null
                            ? JuhColors.primarySoft
                            : Colors.white,
                        borderRadius: BorderRadius.circular(
                            JuhSizes.radiusMd),
                        border: Border.all(
                          color: _filterDate != null
                              ? JuhColors.primary
                              : JuhColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 18,
                            color: _filterDate != null
                                ? JuhColors.primary
                                : JuhColors.textMuted,
                          ),
                          if (_filterDate != null) ...[
                            const SizedBox(width: 5),
                            Text(
                              DateFormat('d/M').format(_filterDate!),
                              style: const TextStyle(
                                color: JuhColors.primary,
                                fontSize: JuhSizes.fontXs,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _filterDate = null),
                              child: const Icon(Icons.close,
                                  size: 14,
                                  color: JuhColors.primary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: JuhSizes.sm),

          // ── Tab content ───────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _EmailListView(
                  appts: filteredConfirmed,
                  isAr: isAr,
                  email: profile.email,
                  isReminder: false,
                ),
                _EmailListView(
                  appts: filteredAll,
                  isAr: isAr,
                  email: profile.email,
                  isReminder: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── List view ─────────────────────────────────────

class _EmailListView extends StatelessWidget {
  final List<Appointment> appts;
  final bool isAr;
  final String email;
  final bool isReminder;
  const _EmailListView({
    required this.appts,
    required this.isAr,
    required this.email,
    required this.isReminder,
  });

  @override
  Widget build(BuildContext context) {
    if (appts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mail_outline,
                size: 48, color: JuhColors.textMuted),
            const SizedBox(height: JuhSizes.sm),
            Text(
              isAr ? 'لا توجد رسائل' : 'No messages',
              style: const TextStyle(
                  fontSize: JuhSizes.fontSm,
                  color: JuhColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
          JuhSizes.md, 0, JuhSizes.md, JuhSizes.md),
      separatorBuilder: (_, __) =>
          const SizedBox(height: JuhSizes.sm),
      itemCount: appts.length,
      itemBuilder: (ctx, i) => _CompactEmailCard(
        appt: appts[i],
        isAr: isAr,
        email: email,
        isReminder: isReminder,
      ),
    );
  }
}

// ────────────────────────── Compact card ───────────────────────────────────

class _CompactEmailCard extends StatelessWidget {
  final Appointment appt;
  final bool isAr;
  final String email;
  final bool isReminder;
  const _CompactEmailCard({
    required this.appt,
    required this.isAr,
    required this.email,
    required this.isReminder,
  });

  String _subject() => isReminder
      ? (isAr
          ? 'تذكير: موعدك غداً — ${appt.doctorNameAr}'
          : 'Reminder: Tomorrow — ${appt.doctorNameEn}')
      : (isAr
          ? 'تأكيد موعد — مستشفى الجامعة الأردنية'
          : 'Appointment Confirmed — JUH');

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat(
        isAr ? 'd MMM — hh:mm a' : 'MMM d — hh:mm a',
        isAr ? 'ar' : 'en');
    final specialty =
        isAr ? appt.specialtyAr : appt.specialtyEn;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetail(context),
        splashColor: JuhColors.primary.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: JuhSizes.md, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(JuhSizes.radiusLg),
            border: Border.all(color: JuhColors.border),
          ),
          child: Row(
            textDirection:
                isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // JUH avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isReminder
                      ? JuhColors.accent
                      : JuhColors.primary,
                  borderRadius:
                      BorderRadius.circular(JuhSizes.radiusSm),
                ),
                child: Center(
                  child: Icon(
                    isReminder
                        ? Icons.notifications_outlined
                        : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: JuhSizes.sm),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _subject(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: JuhSizes.fontSm,
                        fontWeight: FontWeight.w700,
                        color: JuhColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      textDirection: isAr
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: JuhColors.primarySoft,
                            borderRadius: BorderRadius.circular(
                                JuhSizes.radiusFull),
                          ),
                          child: Text(
                            specialty,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: JuhColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateFmt.format(appt.dateTime),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: isAr
                                ? TextAlign.left
                                : TextAlign.right,
                            style: const TextStyle(
                              fontSize: JuhSizes.fontXs,
                              color: JuhColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: JuhSizes.sm),
              Icon(
                isAr
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: JuhColors.textMuted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.45,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(JuhSizes.radiusXl),
            ),
          ),
          child: _EmailDetailContent(
            appt: appt,
            isAr: isAr,
            email: email,
            isReminder: isReminder,
            scrollCtrl: scrollCtrl,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── Detail bottom sheet ───────────────────────────────

class _EmailDetailContent extends StatelessWidget {
  final Appointment appt;
  final bool isAr;
  final String email;
  final bool isReminder;
  final ScrollController scrollCtrl;
  const _EmailDetailContent({
    required this.appt,
    required this.isAr,
    required this.email,
    required this.isReminder,
    required this.scrollCtrl,
  });

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

    return Column(
      children: [
        // Handle bar
        Container(
          width: 36,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: JuhColors.border,
            borderRadius:
                BorderRadius.circular(JuhSizes.radiusFull),
          ),
        ),

        // Email header
        Container(
          margin: const EdgeInsets.symmetric(
              horizontal: JuhSizes.md),
          padding: const EdgeInsets.symmetric(
              horizontal: JuhSizes.md, vertical: 12),
          decoration: BoxDecoration(
            color: JuhColors.primarySoft,
            borderRadius:
                BorderRadius.circular(JuhSizes.radiusMd),
          ),
          child: Row(
            textDirection:
                isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: 42,
                height: 42,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      maxLines: 2,
                      style: const TextStyle(
                        color: JuhColors.primaryInk,
                        fontWeight: FontWeight.w700,
                        fontSize: JuhSizes.fontSm,
                      ),
                    ),
                    const SizedBox(height: 2),
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

        // Scrollable body
        Expanded(
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(JuhSizes.md),
            children: [
              Text(
                isAr
                    ? 'عزيزي ${appt.patientNameAr}،'
                    : 'Dear ${appt.patientNameEn},',
                textAlign:
                    isAr ? TextAlign.right : TextAlign.left,
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
                textAlign:
                    isAr ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                    fontSize: JuhSizes.fontXs,
                    color: JuhColors.textSecondary,
                    height: 1.5),
              ),
              const SizedBox(height: JuhSizes.md),

              // Details card
              Container(
                decoration: BoxDecoration(
                  color: JuhColors.bg,
                  borderRadius:
                      BorderRadius.circular(JuhSizes.radiusMd),
                  border: Border.all(color: JuhColors.border),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      isAr: isAr,
                      label: isAr ? 'الطبيب' : 'Doctor',
                      value: isAr
                          ? appt.doctorNameAr
                          : appt.doctorNameEn,
                      icon: Icons.person_outline,
                    ),
                    const Divider(height: 1, color: JuhColors.border),
                    _DetailRow(
                      isAr: isAr,
                      label: isAr ? 'التخصص' : 'Specialty',
                      value: isAr
                          ? appt.specialtyAr
                          : appt.specialtyEn,
                      icon: Icons.local_hospital_outlined,
                    ),
                    const Divider(height: 1, color: JuhColors.border),
                    _DetailRow(
                      isAr: isAr,
                      label: isAr ? 'الموعد' : 'Date & Time',
                      value: dateFmt.format(appt.dateTime),
                      icon: Icons.calendar_today_outlined,
                    ),
                    const Divider(height: 1, color: JuhColors.border),
                    _DetailRow(
                      isAr: isAr,
                      label: isAr ? 'الموقع' : 'Location',
                      value: appt.location,
                      icon: Icons.location_on_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: JuhSizes.md),

              // Ref code
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: JuhSizes.md,
                    vertical: JuhSizes.sm),
                decoration: BoxDecoration(
                  color: JuhColors.primarySoft,
                  borderRadius:
                      BorderRadius.circular(JuhSizes.radiusMd),
                ),
                child: Row(
                  textDirection: isAr
                      ? TextDirection.rtl
                      : TextDirection.ltr,
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
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: JuhSizes.md),

              Text(
                isAr
                    ? 'يرجى الحضور قبل الموعد بـ ١٥ دقيقة وإحضار هويتك ووثائق التأمين.'
                    : 'Please arrive 15 minutes early and bring your ID and insurance documents.',
                textAlign:
                    isAr ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  fontSize: JuhSizes.fontXs,
                  color: JuhColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: JuhSizes.md),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────── Detail row ───────────────────────────────────

class _DetailRow extends StatelessWidget {
  final bool isAr;
  final String label;
  final String value;
  final IconData icon;
  const _DetailRow({
    required this.isAr,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: JuhSizes.md, vertical: 10),
      child: Row(
        textDirection:
            isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Icon(icon, size: 16, color: JuhColors.primary),
          const SizedBox(width: JuhSizes.sm),
          SizedBox(
            width: 72,
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
                fontWeight: FontWeight.w700,
                color: JuhColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../shared/widgets/screen_header.dart';

// ── Data ───────────────────────────────────────────────────────────────────────

typedef _LeaveRow = ({String rawName, String fromDate, String toDate});

const List<_LeaveRow> _allRows = [
  (rawName: 'رامي العداسي/جراحة عامة - جراحة أورام', fromDate: '01/05/2026', toDate: '30/04/2027'),
  (rawName: 'اسلام عبدالرحيم', fromDate: '01/09/2025', toDate: '31/08/2026'),
  (rawName: 'حسام القيسي', fromDate: '01/10/2025', toDate: '01/10/2026'),
  (rawName: 'محمد راضي الطراونة/جراحة عامة - جراحة المريء والمعدة', fromDate: '03/05/2026', toDate: '09/05/2026'),
  (rawName: 'عبدالهادي الزبن', fromDate: '03/05/2026', toDate: '03/05/2026'),
  (rawName: 'اسامه عبابنة', fromDate: '03/05/2026', toDate: '09/05/2026'),
  (rawName: 'اياد العموري', fromDate: '03/05/2026', toDate: '09/05/2026'),
  (rawName: 'فراس عبيدات', fromDate: '03/05/2026', toDate: '09/05/2026'),
  (rawName: 'محمد زيدون الرشدان/جراحة جهاز هضمي وجراحة سمنة', fromDate: '03/05/2029', toDate: '09/05/2029'),
  (rawName: 'فريهان البرغوثي', fromDate: '04/05/2026', toDate: '10/05/2026'),
  (rawName: 'هبة العباسي', fromDate: '04/05/2026', toDate: '10/05/2026'),
  (rawName: 'امجد بني هاني/جراحة قلب وأوعية دموية', fromDate: '05/12/2026', toDate: '10/12/2026'),
  (rawName: 'محمد الطوالبة', fromDate: '07/05/2026', toDate: '13/05/2026'),
  (rawName: 'محمد ابوعميرة', fromDate: '07/06/2026', toDate: '07/06/2026'),
  (rawName: 'فراس فرارجه', fromDate: '07/06/2026', toDate: '20/06/2026'),
  (rawName: 'باعث الرواشده', fromDate: '08/02/2026', toDate: '06/06/2026'),
  (rawName: 'محمد سميح/جراحة العظام والمناظير', fromDate: '08/02/2026', toDate: '07/02/2027'),
  (rawName: 'محمد سميح/جراحة عظام الأطفال وتشوهات العمود الفقري', fromDate: '08/02/2026', toDate: '07/02/2027'),
  (rawName: 'المعتز محمد غرايبه/طب الأطفال', fromDate: '08/06/2026', toDate: '08/06/2026'),
  (rawName: 'نخله الياس ابو ياغي', fromDate: '08/06/2026', toDate: '08/06/2026'),
  (rawName: 'محمود العبدالات', fromDate: '10/05/2026', toDate: '16/05/2026'),
  (rawName: 'مارجريت زريقات', fromDate: '10/05/2026', toDate: '16/05/2026'),
  (rawName: 'سهى ابوغزاله', fromDate: '10/06/2026', toDate: '18/06/2026'),
  (rawName: 'فريهان البرغوثي', fromDate: '11/05/2026', toDate: '24/05/2026'),
  (rawName: 'رندة فرح', fromDate: '18/05/2026', toDate: '18/05/2026'),
  (rawName: 'محمد الطوالبة', fromDate: '21/05/2026', toDate: '21/05/2026'),
  (rawName: 'امل ابو لبدة', fromDate: '23/04/2026', toDate: '29/04/2026'),
  (rawName: 'رشا العموش', fromDate: '24/05/2026', toDate: '24/05/2026'),
  (rawName: 'منتهى العيدي/صدرية واعتلالات نوم', fromDate: '25/07/2026', toDate: '31/07/2026'),
  (rawName: 'ناصر الحسبان', fromDate: '26/05/2026', toDate: '31/05/2026'),
  (rawName: 'اسماء باشا', fromDate: '28/04/2026', toDate: '29/04/2026'),
  (rawName: 'ديمة ابو بكر', fromDate: '28/09/2025', toDate: '28/09/2026'),
  (rawName: 'فراس فرارجه', fromDate: '29/04/2026', toDate: '03/05/2026'),
  (rawName: 'محمد تيم', fromDate: '30/04/2026', toDate: '30/04/2026'),
];

// ── Helpers ───────────────────────────────────────────────────────────────────

enum _LeaveFilter { all, active, upcoming, expired }

enum _LeaveStatus { active, upcoming, expired }

DateTime _parseDate(String s) {
  final p = s.split('/');
  return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
}

_LeaveStatus _leaveStatus(String from, String to) {
  final now = DateTime.now();
  final f = _parseDate(from);
  final t = _parseDate(to);
  if (t.isBefore(DateTime(now.year, now.month, now.day))) return _LeaveStatus.expired;
  if (f.isAfter(DateTime(now.year, now.month, now.day))) return _LeaveStatus.upcoming;
  return _LeaveStatus.active;
}

int _leaveDays(String from, String to) =>
    _parseDate(to).difference(_parseDate(from)).inDays + 1;

({String name, String? dept}) _splitName(String raw) {
  final idx = raw.indexOf('/');
  if (idx == -1) return (name: raw, dept: null);
  return (name: raw.substring(0, idx).trim(), dept: raw.substring(idx + 1).trim());
}

// ─────────────────────────────────────────────────────────────────────────────

class DoctorsLeaveInquiryScreen extends StatefulWidget {
  const DoctorsLeaveInquiryScreen({super.key});

  @override
  State<DoctorsLeaveInquiryScreen> createState() => _DoctorsLeaveInquiryScreenState();
}

class _DoctorsLeaveInquiryScreenState extends State<DoctorsLeaveInquiryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  _LeaveFilter _filter = _LeaveFilter.all;

  List<_LeaveRow> get _filtered {
    return _allRows.where((row) {
      final status = _leaveStatus(row.fromDate, row.toDate);

      final matchFilter = switch (_filter) {
        _LeaveFilter.all => true,
        _LeaveFilter.active => status == _LeaveStatus.active,
        _LeaveFilter.upcoming => status == _LeaveStatus.upcoming,
        _LeaveFilter.expired => status == _LeaveStatus.expired,
      };

      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty || row.rawName.toLowerCase().contains(q);

      return matchFilter && matchSearch;
    }).toList();
  }

  int _countByStatus(_LeaveStatus s) =>
      _allRows.where((r) => _leaveStatus(r.fromDate, r.toDate) == s).length;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: cs.outlineVariant,
      appBar: const ScreenHeader(
        titleAr: 'استفسار إجازات الأطباء',
        titleEn: 'Doctors Leave Inquiry',
      ),
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [JuhColors.primary, JuhColors.primaryMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _HeaderStat(
                      value: '${_allRows.length}',
                      label: 'إجمالي الإجازات',
                      icon: Icons.event_note_outlined,
                    ),
                    _HeaderStat(
                      value: '${_countByStatus(_LeaveStatus.active)}',
                      label: 'إجازة جارية',
                      icon: Icons.event_busy_outlined,
                      color: const Color(0xFFFFCDD2),
                    ),
                    _HeaderStat(
                      value: '${_countByStatus(_LeaveStatus.upcoming)}',
                      label: 'إجازة قادمة',
                      icon: Icons.schedule_outlined,
                      color: const Color(0xFFFFF9C4),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Search
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن اسم الطبيب…',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70, size: 18),
                            onPressed: () => setState(() {
                              _searchCtrl.clear();
                              _searchQuery = '';
                            }),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // ── Filter tabs ───────────────────────────────────────────────────
          Container(
            color: cs.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusTab(
                    label: 'الكل',
                    count: _allRows.length,
                    selected: _filter == _LeaveFilter.all,
                    color: JuhColors.primary,
                    onTap: () => setState(() => _filter = _LeaveFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _StatusTab(
                    label: 'جارية',
                    count: _countByStatus(_LeaveStatus.active),
                    selected: _filter == _LeaveFilter.active,
                    color: JuhColors.error,
                    onTap: () => setState(() => _filter = _LeaveFilter.active),
                  ),
                  const SizedBox(width: 8),
                  _StatusTab(
                    label: 'قادمة',
                    count: _countByStatus(_LeaveStatus.upcoming),
                    selected: _filter == _LeaveFilter.upcoming,
                    color: JuhColors.warning,
                    onTap: () => setState(() => _filter = _LeaveFilter.upcoming),
                  ),
                  const SizedBox(width: 8),
                  _StatusTab(
                    label: 'منتهية',
                    count: _countByStatus(_LeaveStatus.expired),
                    selected: _filter == _LeaveFilter.expired,
                    color: JuhColors.textSecondary,
                    onTap: () => setState(() => _filter = _LeaveFilter.expired),
                  ),
                ],
              ),
            ),
          ),

          // ── Result count ──────────────────────────────────────────────────
          Container(
            color: cs.outlineVariant,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Row(
              children: [
                Icon(Icons.format_list_bulleted, size: 13, color: cs.onSurfaceVariant),
                const SizedBox(width: 5),
                Text(
                  'إجمالي النتائج: ${filtered.length}',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // ── Leave cards ───────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 52, color: cs.outlineVariant),
                        const SizedBox(height: 12),
                        Text(
                          'لا توجد نتائج مطابقة',
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _LeaveCard(row: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _HeaderStat({
    required this.value,
    required this.label,
    required this.icon,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10)),
        ],
      );
}

class _StatusTab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _StatusTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : cs.surface,
          borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
          border: Border.all(color: selected ? color : cs.outline),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : cs.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final _LeaveRow row;
  const _LeaveCard({required this.row});

  static ({Color bg, Color fg, Color border, String label, IconData icon})
      _style(_LeaveStatus s, BuildContext ctx) {
    final isDark = ctx.isDark;
    return switch (s) {
      _LeaveStatus.active => (
          bg: ctx.juhErrorSoft,
          fg: JuhColors.error,
          border: JuhColors.error.withValues(alpha: 0.35),
          label: 'جارية',
          icon: Icons.event_busy,
        ),
      _LeaveStatus.upcoming => (
          bg: ctx.juhWarningSoft,
          fg: JuhColors.warning,
          border: JuhColors.warning.withValues(alpha: 0.35),
          label: 'قادمة',
          icon: Icons.schedule,
        ),
      _LeaveStatus.expired => (
          bg: isDark ? const Color(0xFF1A2A32) : const Color(0xFFF5F5F5),
          fg: isDark ? const Color(0xFF8AADB8) : const Color(0xFF757575),
          border: isDark ? const Color(0xFF1A3A4A) : const Color(0xFFE0E0E0),
          label: 'منتهية',
          icon: Icons.check_circle_outline,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final status = _leaveStatus(row.fromDate, row.toDate);
    final style = _style(status, context);
    final parsed = _splitName(row.rawName);
    final days = _leaveDays(row.fromDate, row.toDate);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border(right: BorderSide(color: style.fg, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // ── Top: name + status badge ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar circle
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: style.fg.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: style.fg.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      parsed.name.isNotEmpty ? parsed.name[0] : '?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: style.fg,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor name
                      Text(
                        parsed.name,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // Department (if available)
                      if (parsed.dept != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              parsed.dept!,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.local_hospital_outlined,
                                size: 12, color: cs.onSurfaceVariant),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: style.bg,
                    borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
                    border: Border.all(color: style.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(style.icon, size: 12, color: style.fg),
                      const SizedBox(width: 4),
                      Text(
                        style.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: style.fg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──
          Divider(height: 1, color: cs.outlineVariant),

          // ── Bottom: dates + duration ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 9, 14, 12),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // From date
                _DateCell(
                  label: 'من تاريخ',
                  date: row.fromDate,
                  icon: Icons.login_rounded,
                  color: JuhColors.info,
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_back_rounded, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                // To date
                _DateCell(
                  label: 'إلى تاريخ',
                  date: row.toDate,
                  icon: Icons.logout_rounded,
                  color: style.fg,
                ),
                const Spacer(),
                // Duration badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: style.fg.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$days',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: style.fg,
                        ),
                      ),
                      Text(
                        'يوم',
                        style: TextStyle(fontSize: 10, color: style.fg),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateCell extends StatelessWidget {
  final String label;
  final String date;
  final IconData icon;
  final Color color;
  const _DateCell({required this.label, required this.date, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
            Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          date,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/colors.dart';
import '../../../core/sizes.dart';
import '../../../data/seed_data.dart';
import '../../../models/doctor.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/screen_header.dart';

// ── Static clinic schedule per specialty ──────────────────────────────────────
typedef _Schedule = ({String daysAr, String daysEn, String hours, bool available});

const Map<String, _Schedule> _scheduleMap = {
  'cardio': (daysAr: 'الأحد، الثلاثاء، الخميس', daysEn: 'Sun, Tue, Thu', hours: '09:00 – 12:00', available: true),
  'neuro':  (daysAr: 'الأحد، الاثنين، الأربعاء', daysEn: 'Sun, Mon, Wed', hours: '10:00 – 13:00', available: true),
  'ortho':  (daysAr: 'الاثنين، الأربعاء، الخميس', daysEn: 'Mon, Wed, Thu', hours: '08:00 – 12:00', available: false),
  'peds':   (daysAr: 'يومياً (ما عدا الجمعة)', daysEn: 'Daily (excl. Fri)', hours: '08:00 – 14:00', available: true),
  'derm':   (daysAr: 'الأحد، الثلاثاء', daysEn: 'Sun, Tue', hours: '10:00 – 12:00', available: true),
  'ent':    (daysAr: 'الاثنين، الأربعاء', daysEn: 'Mon, Wed', hours: '09:00 – 12:00', available: true),
  'ophthal':(daysAr: 'الأحد، الثلاثاء، الخميس', daysEn: 'Sun, Tue, Thu', hours: '08:00 – 11:00', available: false),
  'gen':    (daysAr: 'يومياً (ما عدا الجمعة)', daysEn: 'Daily (excl. Fri)', hours: '08:00 – 14:00', available: true),
  'psych':  (daysAr: 'الاثنين، الأربعاء', daysEn: 'Mon, Wed', hours: '10:00 – 13:00', available: true),
  'gyne':   (daysAr: 'الأحد، الاثنين، الخميس', daysEn: 'Sun, Mon, Thu', hours: '09:00 – 12:00', available: true),
};

const Map<String, Color> _specialtyColor = {
  'cardio':  Color(0xFFE53E3E),
  'neuro':   Color(0xFF805AD5),
  'ortho':   Color(0xFF2B6CB0),
  'peds':    Color(0xFF38A169),
  'derm':    Color(0xFFD69E2E),
  'ent':     Color(0xFF3182CE),
  'ophthal': Color(0xFF319795),
  'gen':     Color(0xFF003B4B),
  'psych':   Color(0xFF9F7AEA),
  'gyne':    Color(0xFFD53F8C),
};

// ─────────────────────────────────────────────────────────────────────────────

class ClinicAppointmentsInquiryScreen extends ConsumerStatefulWidget {
  const ClinicAppointmentsInquiryScreen({super.key});

  @override
  ConsumerState<ClinicAppointmentsInquiryScreen> createState() =>
      _ClinicAppointmentsInquiryScreenState();
}

class _ClinicAppointmentsInquiryScreenState
    extends ConsumerState<ClinicAppointmentsInquiryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedSpecialtyId;

  List<Doctor> get _filtered => SeedData.doctors.where((d) {
        final matchSpec =
            _selectedSpecialtyId == null || d.specialtyId == _selectedSpecialtyId;
        final q = _searchQuery.toLowerCase();
        final matchSearch = q.isEmpty ||
            d.nameAr.toLowerCase().contains(q) ||
            d.nameEn.toLowerCase().contains(q) ||
            d.titleAr.toLowerCase().contains(q);
        return matchSpec && matchSearch;
      }).toList();

  int get _availableCount =>
      SeedData.doctors.where((d) => _scheduleMap[d.specialtyId]?.available == true).length;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final cs = Theme.of(context).colorScheme;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: cs.outlineVariant,
      appBar: const ScreenHeader(
        titleAr: 'استفسار مواعيد العيادات',
        titleEn: 'Clinic Appointments Inquiry',
      ),
      body: Column(
        children: [
          // ── Blue header banner ──────────────────────────────────────────
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
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBubble(
                      icon: Icons.local_hospital_outlined,
                      value: '${SeedData.specialties.length}',
                      label: isAr ? 'تخصص' : 'Specialties',
                    ),
                    _StatBubble(
                      icon: Icons.people_outline,
                      value: '${SeedData.doctors.length}',
                      label: isAr ? 'طبيب' : 'Doctors',
                    ),
                    _StatBubble(
                      icon: Icons.check_circle_outline,
                      value: '$_availableCount',
                      label: isAr ? 'متاح اليوم' : 'Available',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Search field
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: isAr ? 'ابحث عن اسم الطبيب…' : 'Search doctor name…',
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

          // ── Specialty filter chips ──────────────────────────────────────
          Container(
            color: cs.surface,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _FilterChip(
                    label: isAr ? 'الكل' : 'All',
                    icon: Icons.grid_view_rounded,
                    selected: _selectedSpecialtyId == null,
                    selectedColor: JuhColors.primary,
                    onTap: () => setState(() => _selectedSpecialtyId = null),
                  ),
                  ...SeedData.specialties.map((s) => _FilterChip(
                        label: isAr ? s.nameAr : s.nameEn,
                        emoji: s.icon,
                        selected: _selectedSpecialtyId == s.id,
                        selectedColor: _specialtyColor[s.id] ?? JuhColors.primary,
                        onTap: () => setState(() => _selectedSpecialtyId =
                            _selectedSpecialtyId == s.id ? null : s.id),
                      )),
                ],
              ),
            ),
          ),

          // ── Result count bar ────────────────────────────────────────────
          Container(
            color: cs.outlineVariant,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Row(
              children: [
                Icon(Icons.format_list_bulleted, size: 13, color: cs.onSurfaceVariant),
                const SizedBox(width: 5),
                Text(
                  isAr
                      ? 'إجمالي النتائج: ${filtered.length} طبيب'
                      : 'Results: ${filtered.length} doctor(s)',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // ── Doctor cards ────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 52, color: cs.outlineVariant),
                        const SizedBox(height: 12),
                        Text(
                          isAr ? 'لا توجد نتائج مطابقة' : 'No results found',
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _DoctorCard(
                      doctor: filtered[i],
                      isAr: isAr,
                      schedule: _scheduleMap[filtered[i].specialtyId],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _StatBubble extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatBubble({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10)),
        ],
      );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final IconData? icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.emoji,
    this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? selectedColor : cs.surface,
            borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
            border: Border.all(color: selected ? selectedColor : cs.outline),
            boxShadow: selected
                ? [BoxShadow(color: selectedColor.withValues(alpha: 0.25), blurRadius: 6)]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
              ] else if (icon != null) ...[
                Icon(icon, size: 13, color: selected ? Colors.white : cs.onSurface),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final bool isAr;
  final _Schedule? schedule;

  const _DoctorCard({required this.doctor, required this.isAr, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final specialty = SeedData.specialties.firstWhere(
      (s) => s.id == doctor.specialtyId,
      orElse: () => SeedData.specialties.first,
    );
    final color = _specialtyColor[doctor.specialtyId] ?? JuhColors.primary;
    final isAvailable = schedule?.available ?? true;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // ── Doctor info ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Specialty icon avatar
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Text(specialty.icon, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        isAr ? doctor.nameAr : doctor.nameEn,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      // Title
                      Text(
                        isAr ? doctor.titleAr : doctor.titleEn,
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 6),
                      // Specialty badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
                          border: Border.all(color: color.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          isAr ? specialty.nameAr : specialty.nameEn,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Availability badge
                _AvailabilityBadge(available: isAvailable, isAr: isAr),
              ],
            ),
          ),

          // ── Divider ──
          Divider(height: 1, color: cs.outlineVariant),

          // ── Schedule + stats row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              children: [
                if (schedule != null) ...[
                  _InfoRow(
                    icon: Icons.calendar_month_outlined,
                    text: isAr ? schedule!.daysAr : schedule!.daysEn,
                    isAr: isAr,
                    iconColor: JuhColors.primary,
                  ),
                  const SizedBox(height: 5),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    text: schedule!.hours,
                    isAr: isAr,
                    iconColor: JuhColors.info,
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    // Rating
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.star_rounded, size: 15, color: JuhColors.accent),
                      const SizedBox(width: 3),
                      Text(
                        doctor.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: JuhColors.accent),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '(${doctor.reviewCount})',
                        style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final bool available;
  final bool isAr;
  const _AvailabilityBadge({required this.available, required this.isAr});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: available ? JuhColors.successSoft : JuhColors.errorSoft,
          borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: available ? JuhColors.success : JuhColors.error,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              available
                  ? (isAr ? 'متاح' : 'Open')
                  : (isAr ? 'مشغول' : 'Busy'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: available ? JuhColors.success : JuhColors.error,
              ),
            ),
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isAr;
  final Color iconColor;
  const _InfoRow({required this.icon, required this.text, required this.isAr, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    );
  }
}

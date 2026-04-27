import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../data/seed_data.dart';
import '../../../models/doctor.dart';
import '../../../models/insurance.dart';
import '../../../models/specialty.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/progress_steps.dart';
import '../../../shared/widgets/screen_header.dart';

class BookingChooseScreen extends ConsumerStatefulWidget {
  final String who;
  const BookingChooseScreen({super.key, required this.who});

  @override
  ConsumerState<BookingChooseScreen> createState() => _BookingChooseScreenState();
}

class _BookingChooseScreenState extends ConsumerState<BookingChooseScreen> {
  int _step = 0; // 0=insurance, 1=specialty, 2=doctor
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).reset(widget.who);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final draft = ref.watch(bookingProvider);
    final query = _searchCtrl.text.toLowerCase();

    final stepLabels = isAr
        ? ['التأمين', 'التخصص', 'الطبيب']
        : ['Insurance', 'Specialty', 'Doctor'];

    return Scaffold(
      appBar: ScreenHeader(
        titleAr: 'احجز موعدك',
        titleEn: 'Book Appointment',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(JuhSizes.md, JuhSizes.md, JuhSizes.md, 0),
            child: ProgressSteps(current: _step + 1, total: 3, labels: stepLabels),
          ),
          const SizedBox(height: JuhSizes.md),
          if (_step == 1 || _step == 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: isAr ? 'بحث...' : 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
            ),
          const SizedBox(height: JuhSizes.sm),
          Expanded(
            child: _step == 0
                ? _InsuranceList(isAr: isAr, selected: draft.insuranceId, onSelect: (id) {
                    ref.read(bookingProvider.notifier).setInsurance(id);
                    setState(() => _step = 1);
                  })
                : _step == 1
                    ? _SpecialtyList(isAr: isAr, query: query, selected: draft.specId, onSelect: (id) {
                        ref.read(bookingProvider.notifier).setSpec(id);
                        setState(() { _step = 2; _searchCtrl.clear(); });
                      })
                    : _DoctorList(isAr: isAr, query: query, specId: draft.specId, selected: draft.docId, onSelect: (id) {
                        ref.read(bookingProvider.notifier).setDoc(id);
                      }),
          ),
          if (_step == 2 && draft.docId != null)
            Padding(
              padding: const EdgeInsets.all(JuhSizes.md),
              child: AppButton(
                label: isAr ? 'التالي: اختر الموعد' : 'Next: Choose Slot',
                onTap: () => context.push('/calendar?who=${widget.who}'),
                icon: Icons.arrow_forward,
              ),
            ),
          if (_step > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(JuhSizes.md, 0, JuhSizes.md, JuhSizes.md),
              child: AppButton.ghost(
                label: isAr ? 'رجوع' : 'Back',
                onTap: () => setState(() { _step--; _searchCtrl.clear(); }),
                icon: Icons.arrow_back,
              ),
            ),
        ],
      ),
    );
  }
}

class _InsuranceList extends StatelessWidget {
  final bool isAr;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _InsuranceList({required this.isAr, this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
      separatorBuilder: (_, __) => const SizedBox(height: JuhSizes.sm),
      itemCount: SeedData.insurances.length,
      itemBuilder: (ctx, i) {
        final ins = SeedData.insurances[i];
        return _SelectTile(
          leading: Text(ins.icon, style: const TextStyle(fontSize: 24)),
          title: isAr ? ins.nameAr : ins.nameEn,
          isSelected: selected == ins.id,
          onTap: () => onSelect(ins.id),
          isAr: isAr,
        );
      },
    );
  }
}

class _SpecialtyList extends StatelessWidget {
  final bool isAr;
  final String query;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _SpecialtyList({required this.isAr, required this.query, this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final filtered = SeedData.specialties.where((s) =>
        query.isEmpty ||
        s.nameAr.contains(query) ||
        s.nameEn.toLowerCase().contains(query)).toList();

    if (filtered.isEmpty) {
      return Center(child: Text(isAr ? 'لا توجد نتائج' : 'No results'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
      separatorBuilder: (_, __) => const SizedBox(height: JuhSizes.sm),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        final s = filtered[i];
        return _SelectTile(
          leading: Text(s.icon, style: const TextStyle(fontSize: 24)),
          title: isAr ? s.nameAr : s.nameEn,
          isSelected: selected == s.id,
          onTap: () => onSelect(s.id),
          isAr: isAr,
        );
      },
    );
  }
}

class _DoctorList extends StatelessWidget {
  final bool isAr;
  final String query;
  final String? specId;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _DoctorList({required this.isAr, required this.query, this.specId, this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final all = specId != null
        ? SeedData.doctors.where((d) => d.specialtyId == specId).toList()
        : SeedData.doctors;
    final filtered = all.where((d) =>
        query.isEmpty ||
        d.nameAr.contains(query) ||
        d.nameEn.toLowerCase().contains(query)).toList();

    if (filtered.isEmpty) {
      return Center(child: Text(isAr ? 'لا توجد نتائج' : 'No results'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
      separatorBuilder: (_, __) => const SizedBox(height: JuhSizes.sm),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        final d = filtered[i];
        return _DoctorTile(doc: d, isAr: isAr, isSelected: selected == d.id, onTap: () => onSelect(d.id));
      },
    );
  }
}

class _SelectTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isAr;
  const _SelectTile({required this.leading, required this.title, required this.isSelected, required this.onTap, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          color: isSelected ? JuhColors.primarySoft : context.cs.surface,
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          border: Border.all(color: isSelected ? JuhColors.primary : context.cs.outline, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: JuhSizes.md),
            Expanded(child: Text(title, style: context.tt.bodyLarge?.copyWith(fontWeight: FontWeight.w500))),
            if (isSelected) const Icon(Icons.check_circle, color: JuhColors.primary),
          ],
        ),
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final Doctor doc;
  final bool isAr;
  final bool isSelected;
  final VoidCallback onTap;
  const _DoctorTile({required this.doc, required this.isAr, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          color: isSelected ? JuhColors.primarySoft : context.cs.surface,
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          border: Border.all(color: isSelected ? JuhColors.primary : context.cs.outline, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isSelected ? JuhColors.primary : JuhColors.primarySoft,
              radius: 26,
              child: Text(
                (isAr ? doc.nameAr : doc.nameEn).replaceAll('د. ', '').replaceAll('Dr. ', '')[0],
                style: TextStyle(
                  color: isSelected ? Colors.white : JuhColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: JuhSizes.fontLg,
                ),
              ),
            ),
            const SizedBox(width: JuhSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isAr ? doc.nameAr : doc.nameEn, style: context.tt.titleSmall),
                  Text(isAr ? doc.titleAr : doc.titleEn,
                      style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text('${doc.rating}', style: const TextStyle(fontSize: JuhSizes.fontXs, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Text('(${doc.reviewCount})', style: TextStyle(fontSize: JuhSizes.fontXs, color: context.cs.onSurfaceVariant)),
                      const Spacer(),
                      Text(doc.consultFee, style: const TextStyle(fontSize: JuhSizes.fontSm, fontWeight: FontWeight.w700, color: JuhColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: JuhColors.primary),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../data/seed_data.dart';
import '../../../models/doctor.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/progress_steps.dart';
import '../../../shared/widgets/screen_header.dart';

class BookingChooseScreen extends ConsumerStatefulWidget {
  final String who;
  final String? initialInsuranceId;
  const BookingChooseScreen({
    super.key,
    required this.who,
    this.initialInsuranceId,
  });

  @override
  ConsumerState<BookingChooseScreen> createState() =>
      _BookingChooseScreenState();
}

class _BookingChooseScreenState extends ConsumerState<BookingChooseScreen> {
  int _step = 0; // 0=insurance, 1=specialty, 2=doctor
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(bookingProvider.notifier);
      notifier.reset(widget.who);
      if (widget.initialInsuranceId != null) {
        notifier.setInsurance(widget.initialInsuranceId!);
        if (mounted) {
          setState(() => _step = 1);
        }
      }
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

    final stepTitles = isAr
        ? ['اختر نوع التأمين', 'اختر التخصص الطبي', 'اختر طبيبك']
        : [
            'Choose Insurance Type',
            'Choose Medical Specialty',
            'Choose Your Doctor'
          ];

    return Scaffold(
      backgroundColor: context.juhBg,
      appBar: const ScreenHeader(
        titleAr: 'احجز موعدك',
        titleEn: 'Book Appointment',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                JuhSizes.md, JuhSizes.md, JuhSizes.md, 0),
            child:
                ProgressSteps(current: _step + 1, total: 3, labels: stepLabels),
          ),
          const SizedBox(height: JuhSizes.md),

          // Step title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                stepTitles[_step],
                style: TextStyle(
                  fontSize: JuhSizes.fontBase,
                  fontWeight: FontWeight.w700,
                  color: context.juhText,
                ),
              ),
            ),
          ),
          const SizedBox(height: JuhSizes.sm),

          // Search field (steps 1 and 2)
          if (_step == 1 || _step == 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  JuhSizes.md, 0, JuhSizes.md, JuhSizes.sm),
              child: TextField(
                controller: _searchCtrl,
                textAlign: isAr ? TextAlign.right : TextAlign.left,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: isAr ? 'بحث...' : 'Search...',
                  hintStyle: TextStyle(color: context.juhTextMuted),
                  filled: true,
                  fillColor: context.juhSurface,
                  prefixIcon:
                      Icon(Icons.search, color: context.juhTextSub),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              color: context.juhTextSub),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: JuhSizes.md, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
                    borderSide: BorderSide(color: context.juhBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
                    borderSide: BorderSide(color: context.juhBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
                    borderSide:
                        const BorderSide(color: JuhColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),

          Expanded(
            child: _step == 0
                ? _InsuranceList(
                    isAr: isAr,
                    selected: draft.insuranceId,
                    onSelect: (id) {
                      ref.read(bookingProvider.notifier).setInsurance(id);
                      setState(() => _step = 1);
                    },
                  )
                : _step == 1
                    ? _SpecialtyList(
                        isAr: isAr,
                        query: query,
                        selected: draft.specId,
                        onSelect: (id) {
                          ref.read(bookingProvider.notifier).setSpec(id);
                          setState(() {
                            _step = 2;
                            _searchCtrl.clear();
                          });
                        },
                      )
                    : _DoctorList(
                        isAr: isAr,
                        query: query,
                        specId: draft.specId,
                        selected: draft.docId,
                        onSelect: (id) {
                          ref.read(bookingProvider.notifier).setDoc(id);
                          setState(() {});
                        },
                      ),
          ),

          if (_step == 2 && draft.docId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  JuhSizes.md, 0, JuhSizes.md, JuhSizes.sm),
              child: AppButton(
                label: isAr ? 'التالي: اختر الموعد' : 'Next: Choose Slot',
                onTap: () => context.push('/calendar?who=${widget.who}'),
                icon: isAr ? Icons.arrow_back : Icons.arrow_forward,
              ),
            ),

          if (_step > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  JuhSizes.md, 0, JuhSizes.md, JuhSizes.md),
              child: AppButton.ghost(
                label: isAr ? 'رجوع' : 'Back',
                onTap: () => setState(() {
                  _step--;
                  _searchCtrl.clear();
                }),
                icon: isAr ? Icons.arrow_forward : Icons.arrow_back,
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
  const _InsuranceList(
      {required this.isAr, this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
      separatorBuilder: (_, __) => const SizedBox(height: JuhSizes.sm),
      itemCount: SeedData.insurances.length,
      itemBuilder: (ctx, i) {
        final ins = SeedData.insurances[i];
        return _SelectTile(
          isAr: isAr,
          leading: Text(ins.icon, style: const TextStyle(fontSize: 22)),
          title: isAr ? ins.nameAr : ins.nameEn,
          isSelected: selected == ins.id,
          onTap: () => onSelect(ins.id),
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
  const _SpecialtyList(
      {required this.isAr,
      required this.query,
      this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final filtered = SeedData.specialties
        .where((s) =>
            query.isEmpty ||
            s.nameAr.contains(query) ||
            s.nameEn.toLowerCase().contains(query))
        .toList();

    if (filtered.isEmpty) {
      return Center(
          child: Text(isAr ? 'لا توجد نتائج' : 'No results',
              style: TextStyle(color: context.juhTextSub)));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
      separatorBuilder: (_, __) => const SizedBox(height: JuhSizes.sm),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        final s = filtered[i];
        final docCount =
            SeedData.doctors.where((d) => d.specialtyId == s.id).length;
        final subtitle = isAr
            ? '$docCount طبيب متاح'
            : '$docCount doctor${docCount == 1 ? '' : 's'} available';
        return _SelectTile(
          isAr: isAr,
          leading: Text(s.icon, style: const TextStyle(fontSize: 22)),
          title: isAr ? s.nameAr : s.nameEn,
          subtitle: subtitle,
          isSelected: selected == s.id,
          onTap: () => onSelect(s.id),
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
  const _DoctorList(
      {required this.isAr,
      required this.query,
      this.specId,
      this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final all = specId != null
        ? SeedData.doctors.where((d) => d.specialtyId == specId).toList()
        : SeedData.doctors;
    final filtered = all
        .where((d) =>
            query.isEmpty ||
            d.nameAr.contains(query) ||
            d.nameEn.toLowerCase().contains(query))
        .toList();

    if (filtered.isEmpty) {
      return Center(
          child: Text(isAr ? 'لا توجد نتائج' : 'No results',
              style: TextStyle(color: context.juhTextSub)));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
      separatorBuilder: (_, __) => const SizedBox(height: JuhSizes.sm),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        final d = filtered[i];
        return _DoctorTile(
            doc: d,
            isAr: isAr,
            isSelected: selected == d.id,
            onTap: () => onSelect(d.id));
      },
    );
  }
}

class _SelectTile extends StatelessWidget {
  final bool isAr;
  final Widget leading;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectTile({
    required this.isAr,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: JuhColors.primary.withValues(alpha: 0.10),
        highlightColor: JuhColors.primary.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(JuhSizes.md),
          decoration: BoxDecoration(
            color: isSelected ? context.juhPrimarySoft : context.juhSurface,
            borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
            border: Border.all(
                color: isSelected ? JuhColors.primary : context.juhBorder,
                width: isSelected ? 1.5 : 1),
          ),
          child: Row(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              leading,
              const SizedBox(width: JuhSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: JuhSizes.fontBase,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? JuhColors.primaryInk
                            : context.juhText,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: JuhSizes.fontXs,
                          color: context.juhTextSub,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle,
                    color: JuhColors.primary, size: JuhSizes.iconLg),
            ],
          ),
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
  const _DoctorTile(
      {required this.doc,
      required this.isAr,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nameDisplay = isAr ? doc.nameAr : doc.nameEn;
    final initial = nameDisplay.replaceAll('د. ', '').replaceAll('Dr. ', '')[0];

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: JuhColors.primary.withValues(alpha: 0.10),
        highlightColor: JuhColors.primary.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(JuhSizes.md),
          decoration: BoxDecoration(
            color: isSelected ? context.juhPrimarySoft : context.juhSurface,
            borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
            border: Border.all(
                color: isSelected ? JuhColors.primary : context.juhBorder,
                width: isSelected ? 1.5 : 1),
          ),
          child: Row(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
            CircleAvatar(
              backgroundColor:
                  isSelected ? JuhColors.primary : context.juhPrimarySoft,
              radius: 26,
              child: Text(
                initial,
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    nameDisplay,
                    style: TextStyle(
                      fontSize: JuhSizes.fontBase,
                      fontWeight: FontWeight.w700,
                      color: context.juhText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAr ? doc.titleAr : doc.titleEn,
                    style: TextStyle(
                      fontSize: JuhSizes.fontXs,
                      color: context.juhTextSub,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      const Icon(Icons.star, size: 13, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        '${doc.rating}',
                        style: TextStyle(
                          fontSize: JuhSizes.fontXs,
                          fontWeight: FontWeight.w600,
                          color: context.juhText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${doc.reviewCount})',
                        style: TextStyle(
                          fontSize: JuhSizes.fontXs,
                          color: context.juhTextSub,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: JuhSizes.sm),
              const Icon(Icons.check_circle,
                  color: JuhColors.primary, size: JuhSizes.iconLg),
            ],
          ],
          ),
        ),
      ),
    );
  }
}

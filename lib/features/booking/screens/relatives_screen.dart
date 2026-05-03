import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/sizes.dart';
import '../../../data/seed_data.dart';
import '../../../models/relative.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../../../shared/widgets/screen_header.dart';

class RelativesScreen extends ConsumerWidget {
  final String preselectedWho;
  const RelativesScreen({super.key, this.preselectedWho = 'self'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final profile = ref.watch(profileProvider);
    final relatives = ref.watch(relativesProvider);
    final isOtherFlow = preselectedWho == 'other';

    final otherRelatives = relatives.where((r) => r.id != 'self').toList();
    final selfNationalId = relatives
        .firstWhere((r) => r.id == 'self', orElse: () => relatives.first)
        .nationalId;

    return Scaffold(
      backgroundColor: JuhColors.bg,
      appBar: ScreenHeader(
        titleAr: isOtherFlow ? 'حجز لمريض آخر' : 'من سيكون المريض؟',
        titleEn:
            isOtherFlow ? 'Book for Another Patient' : 'Who is the patient?',
      ),
      body: isOtherFlow
          ? _OtherPatientBookingForm(
              isAr: isAr,
              profileId: profile.id,
              priorPatients: otherRelatives,
            )
          : ListView(
              padding: const EdgeInsets.all(JuhSizes.md),
              children: [
                InfoBanner(
                  icon: Icons.people_outline,
                  text: isAr
                      ? 'يمكنك الحجز لنفسك أو لأحد أقاربك الذين تم إضافتهم إلى حسابك.'
                      : 'You can book for yourself or for a relative added to your account.',
                ),
                const SizedBox(height: JuhSizes.md),
                _PersonCard(
                  isAr: isAr,
                  avatarLetter: (isAr ? profile.nameAr : profile.nameEn)[0],
                  name: isAr
                      ? '${profile.nameAr} (أنت)'
                      : '${profile.nameEn} (You)',
                  subtitle: selfNationalId,
                  onTap: () => context.push('/booking?who=self'),
                ),
                if (otherRelatives.isNotEmpty) ...[
                  const SizedBox(height: JuhSizes.lg),
                  Align(
                    alignment:
                        isAr ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      isAr ? 'الأقارب' : 'Relatives',
                      style: const TextStyle(
                        fontSize: JuhSizes.fontSm,
                        fontWeight: FontWeight.w600,
                        color: JuhColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...otherRelatives.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: JuhSizes.sm),
                      child: _PersonCard(
                        isAr: isAr,
                        avatarLetter: (isAr ? r.nameAr : r.nameEn)[0],
                        name: isAr ? r.nameAr : r.nameEn,
                        subtitle: '${r.relationLabel(isAr)} • ${r.nationalId}',
                        onTap: () => context.push('/booking?who=${r.id}'),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: JuhSizes.sm),
                _AddRelativeRow(isAr: isAr),
                const SizedBox(height: JuhSizes.lg),
              ],
            ),
    );
  }
}

// ─────────────────────── Other patient booking form ────────────────────────

class _OtherPatientBookingForm extends ConsumerStatefulWidget {
  final bool isAr;
  final String profileId;
  final List<Relative> priorPatients;
  const _OtherPatientBookingForm({
    required this.isAr,
    required this.profileId,
    required this.priorPatients,
  });

  @override
  ConsumerState<_OtherPatientBookingForm> createState() =>
      _OtherPatientBookingFormState();
}

class _OtherPatientBookingFormState
    extends ConsumerState<_OtherPatientBookingForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nationalIdCtrl = TextEditingController();
  String? _selectedRelativeId;
  String? _selectedInsuranceId;

  String? _validateNationalId(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d+$').hasMatch(v)) {
      return widget.isAr
          ? 'الرقم يجب أن يحتوي على أرقام فقط'
          : 'ID must contain digits only';
    }
    if (v.length < 8 || v.length > 12) {
      return widget.isAr
          ? 'يجب أن يكون الرقم بين 8 و 12 خانة'
          : 'ID must be between 8 and 12 digits';
    }
    return null;
  }

  @override
  void dispose() {
    _nationalIdCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    final nationalId = _nationalIdCtrl.text.trim();
    final valid = _formKey.currentState?.validate() ?? true;
    if (!valid) return;

    if (_selectedRelativeId == null && nationalId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isAr
                ? 'اختر مريضاً من القائمة أو أدخل الرقم الوطني'
                : 'Choose a patient or enter a national ID',
          ),
        ),
      );
      return;
    }

    if (_selectedRelativeId == null && nationalId.isNotEmpty) {
      final nidError = _validateNationalId(nationalId);
      if (nidError != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(nidError)));
        return;
      }
    }

    if (_selectedInsuranceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isAr
                ? 'الرجاء اختيار نوع التأمين'
                : 'Please choose an insurance type',
          ),
        ),
      );
      return;
    }

    String whoId;
    if (_selectedRelativeId != null) {
      whoId = _selectedRelativeId!;
    } else {
      final existing =
          ref.read(relativesProvider).where((r) => r.nationalId == nationalId);
      if (existing.isNotEmpty) {
        whoId = existing.first.id;
      } else {
        whoId = 'np_$nationalId';
        ref.read(relativesProvider.notifier).add(
              Relative(
                id: whoId,
                ownerId: widget.profileId,
                nameAr: 'مريض رقم $nationalId',
                nameEn: 'Patient $nationalId',
                relation: 'spouse',
                nationalId: nationalId,
              ),
            );
      }
    }

    if (!mounted) return;
    context.push('/booking?who=$whoId&insurance=$_selectedInsuranceId');
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isAr;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            JuhSizes.md, JuhSizes.md, JuhSizes.md, JuhSizes.xl),
        children: [
          // ── Step 1: Prior patients ──────────────────────────────────────
          _StepHeader(
            number: '1',
            title: isAr
                ? 'اختر من المرضى السابقين'
                : 'Select a previous patient',
            isAr: isAr,
          ),
          const SizedBox(height: JuhSizes.sm),

          if (widget.priorPatients.isEmpty)
            _EmptyPatientsHint(isAr: isAr)
          else
            ...widget.priorPatients.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: JuhSizes.sm),
                child: _SelectablePatientCard(
                  isAr: isAr,
                  name: isAr ? r.nameAr : r.nameEn,
                  subtitle:
                      '${r.relationLabel(isAr)} • ${r.nationalId}',
                  selected: _selectedRelativeId == r.id,
                  onTap: () => setState(() {
                    _selectedRelativeId = r.id;
                    _nationalIdCtrl.clear();
                  }),
                ),
              ),
            ),

          // ── OR divider ──────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: JuhSizes.md),
            child: Row(
              children: [
                const Expanded(
                    child: Divider(color: JuhColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: JuhSizes.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: JuhColors.bg,
                      borderRadius: BorderRadius.circular(
                          JuhSizes.radiusFull),
                      border: Border.all(color: JuhColors.border),
                    ),
                    child: Text(
                      isAr ? 'أو' : 'OR',
                      style: const TextStyle(
                        fontSize: JuhSizes.fontXs,
                        fontWeight: FontWeight.w600,
                        color: JuhColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                    child: Divider(color: JuhColors.border)),
              ],
            ),
          ),

          // ── Step 2: National ID ─────────────────────────────────────────
          _StepHeader(
            number: '2',
            title: isAr ? 'أدخل الرقم الوطني' : 'Enter National ID',
            isAr: isAr,
          ),
          const SizedBox(height: JuhSizes.sm),

          TextFormField(
            controller: _nationalIdCtrl,
            keyboardType: TextInputType.number,
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            textDirection:
                TextDirection.ltr, // numbers always LTR
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validateNationalId,
            onChanged: (_) =>
                setState(() => _selectedRelativeId = null),
            style: const TextStyle(
              fontSize: JuhSizes.fontBase,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              color: JuhColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: JuhColors.surface,
              hintText: isAr
                  ? 'مثال: 98XXXXXXXX'
                  : 'e.g. 98XXXXXXXX',
              hintStyle: const TextStyle(
                color: JuhColors.textMuted,
                letterSpacing: 0,
                fontWeight: FontWeight.w400,
              ),
              helperText: isAr
                  ? 'رقم وثيقة الهوية الشخصية أو القيد المدني (8–12 خانة)'
                  : 'National / civil ID number (8–12 digits)',
              helperStyle: const TextStyle(
                fontSize: JuhSizes.fontXs,
                color: JuhColors.textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.badge_outlined,
                color: JuhColors.primary,
              ),
              suffixIcon: _nationalIdCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          color: JuhColors.textSecondary, size: 18),
                      onPressed: () =>
                          setState(() => _nationalIdCtrl.clear()),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: JuhSizes.md, vertical: 14),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(JuhSizes.radiusLg),
                borderSide:
                    const BorderSide(color: JuhColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(JuhSizes.radiusLg),
                borderSide:
                    const BorderSide(color: JuhColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(JuhSizes.radiusLg),
                borderSide: const BorderSide(
                    color: JuhColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(JuhSizes.radiusLg),
                borderSide: const BorderSide(
                    color: JuhColors.error, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(JuhSizes.radiusLg),
                borderSide: const BorderSide(
                    color: JuhColors.error, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: JuhSizes.lg),

          // ── Step 3: Insurance ───────────────────────────────────────────
          _StepHeader(
            number: '3',
            title: isAr ? 'نوع التأمين' : 'Insurance Type',
            isAr: isAr,
            required: true,
          ),
          const SizedBox(height: JuhSizes.sm),

          ...SeedData.insurances.map(
            (ins) => Padding(
              padding: const EdgeInsets.only(bottom: JuhSizes.sm),
              child: _InsuranceTile(
                isAr: isAr,
                icon: ins.icon,
                title: isAr ? ins.nameAr : ins.nameEn,
                selected: _selectedInsuranceId == ins.id,
                onTap: () =>
                    setState(() => _selectedInsuranceId = ins.id),
              ),
            ),
          ),

          const SizedBox(height: JuhSizes.lg),

          // ── Continue button ─────────────────────────────────────────────
          AppButton(
            label: isAr ? 'متابعة الحجز' : 'Continue Booking',
            onTap: _continue,
            icon: isAr ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Step header ─────────────────────────────────

class _StepHeader extends StatelessWidget {
  final String number;
  final String title;
  final bool isAr;
  final bool required;

  const _StepHeader({
    required this.number,
    required this.title,
    required this.isAr,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: JuhColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: JuhSizes.fontXs,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: JuhSizes.sm),
        Text(
          title,
          style: const TextStyle(
            fontSize: JuhSizes.fontBase,
            fontWeight: FontWeight.w700,
            color: JuhColors.textPrimary,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: JuhColors.error,
              fontWeight: FontWeight.bold,
              fontSize: JuhSizes.fontBase,
            ),
          ),
        ],
      ],
    );
  }
}

// ───────────────────────── Selectable patient card ─────────────────────────

class _SelectablePatientCard extends StatelessWidget {
  final bool isAr;
  final String name;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SelectablePatientCard({
    required this.isAr,
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          color: selected ? JuhColors.primarySoft : JuhColors.surface,
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          border: Border.all(
            color: selected ? JuhColors.primary : JuhColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? JuhColors.primary : JuhColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: TextStyle(
                    color: selected ? Colors.white : JuhColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: JuhSizes.fontMd,
                  ),
                ),
              ),
            ),
            const SizedBox(width: JuhSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: JuhSizes.fontBase,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? JuhColors.primaryInk
                          : JuhColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: JuhSizes.fontXs,
                      color: JuhColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: JuhSizes.sm),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: selected ? JuhColors.primary : JuhColors.border,
              size: JuhSizes.iconLg,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────── Insurance tile ───────────────────────────────

class _InsuranceTile extends StatelessWidget {
  final bool isAr;
  final String icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _InsuranceTile({
    required this.isAr,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: JuhSizes.md, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? JuhColors.primarySoft : JuhColors.surface,
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          border: Border.all(
            color: selected ? JuhColors.primary : JuhColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? JuhColors.primary.withValues(alpha: 0.12)
                    : JuhColors.bg,
                borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
                border: Border.all(
                  color: selected
                      ? JuhColors.primary.withValues(alpha: 0.3)
                      : JuhColors.border,
                ),
              ),
              child: Center(
                child:
                    Text(icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: JuhSizes.md),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: JuhSizes.fontBase,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? JuhColors.primaryInk
                      : JuhColors.textPrimary,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: selected ? JuhColors.primary : JuhColors.border,
              size: JuhSizes.iconLg,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Empty state hint ──────────────────────────────

class _EmptyPatientsHint extends StatelessWidget {
  final bool isAr;
  const _EmptyPatientsHint({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JuhSizes.md),
      decoration: BoxDecoration(
        color: JuhColors.surface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border.all(
            color: JuhColors.border,
            style: BorderStyle.solid),
      ),
      child: Row(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          const Icon(Icons.info_outline,
              color: JuhColors.textMuted, size: JuhSizes.iconMd),
          const SizedBox(width: JuhSizes.sm),
          Expanded(
            child: Text(
              isAr
                  ? 'لا توجد حالات سابقة. يمكنك إدخال الرقم الوطني أدناه.'
                  : 'No previous patients. Enter a national ID below.',
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                fontSize: JuhSizes.fontSm,
                color: JuhColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Person card ───────────────────────────────────

class _PersonCard extends StatelessWidget {
  final bool isAr;
  final String avatarLetter;
  final String name;
  final String subtitle;
  final VoidCallback onTap;

  const _PersonCard({
    required this.isAr,
    required this.avatarLetter,
    required this.name,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          border: Border.all(color: JuhColors.border),
        ),
        child: Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: JuhColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  avatarLetter,
                  style: const TextStyle(
                    color: JuhColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: JuhSizes.fontMd,
                  ),
                ),
              ),
            ),
            const SizedBox(width: JuhSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: JuhSizes.fontBase,
                      fontWeight: FontWeight.w700,
                      color: JuhColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: JuhSizes.fontXs,
                      color: JuhColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isAr ? Icons.chevron_left : Icons.chevron_right,
              color: JuhColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────── Add relative row ───────────────────────────────

class _AddRelativeRow extends StatelessWidget {
  final bool isAr;
  const _AddRelativeRow({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          border: Border.all(color: JuhColors.border),
        ),
        child: Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: JuhColors.primarySoft,
                borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
              ),
              child: const Icon(Icons.add, color: JuhColors.primary),
            ),
            const SizedBox(width: JuhSizes.md),
            Text(
              isAr ? 'إضافة قريب جديد' : 'Add New Relative',
              style: const TextStyle(
                fontSize: JuhSizes.fontBase,
                fontWeight: FontWeight.w600,
                color: JuhColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../data/seed_data.dart';
import '../../../models/appointment.dart';
import '../../../providers/appointments_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/alert_banner.dart';
import '../../../shared/widgets/screen_header.dart';

class ConfirmScreen extends ConsumerStatefulWidget {
  final String who;
  const ConfirmScreen({super.key, required this.who});

  @override
  ConsumerState<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  bool _confirmed = false;
  bool _loading = false;
  late final String _refCode;

  @override
  void initState() {
    super.initState();
    final n = 3100 + (DateTime.now().millisecondsSinceEpoch % 800);
    _refCode = 'JUH-$n-K7';
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final draft = ref.read(bookingProvider);
    final profile = ref.read(profileProvider);
    final relatives = ref.read(relativesProvider);

    final doc = SeedData.doctors.firstWhere((d) => d.id == draft.docId,
        orElse: () => SeedData.doctors.first);
    final spec = SeedData.specialties.firstWhere((s) => s.id == draft.specId,
        orElse: () => SeedData.specialties.first);
    final ins = SeedData.insurances.firstWhere((i) => i.id == draft.insuranceId,
        orElse: () => SeedData.insurances.first);

    final patient = widget.who == 'self'
        ? relatives.firstWhere((r) => r.id == 'self')
        : relatives.firstWhere((r) => r.id == widget.who, orElse: () => relatives.first);

    final isAr = ref.read(localeProvider).languageCode == 'ar';
    final dt = draft.dateTime!;

    ref.read(appointmentsProvider.notifier).add(Appointment(
      id: const Uuid().v4(),
      patientNameAr: patient.nameAr,
      patientNameEn: patient.nameEn,
      doctorNameAr: doc.nameAr,
      doctorNameEn: doc.nameEn,
      doctorTitleAr: doc.titleAr,
      doctorTitleEn: doc.titleEn,
      specialtyAr: spec.nameAr,
      specialtyEn: spec.nameEn,
      insuranceAr: ins.nameAr,
      insuranceEn: ins.nameEn,
      dateTime: dt,
      location: isAr ? 'عيادة ${spec.nameAr} — الدور الثالث' : '${spec.nameEn} Clinic — 3rd Floor',
      refCode: _refCode,
      status: ApptStatus.confirmed,
    ));

    setState(() { _loading = false; _confirmed = true; });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final draft = ref.watch(bookingProvider);

    if (_confirmed) return _SuccessView(isAr: isAr, refCode: _refCode);

    final doc = draft.docId != null
        ? SeedData.doctors.firstWhere((d) => d.id == draft.docId, orElse: () => SeedData.doctors.first)
        : null;
    final spec = draft.specId != null
        ? SeedData.specialties.firstWhere((s) => s.id == draft.specId, orElse: () => SeedData.specialties.first)
        : null;
    final ins = draft.insuranceId != null
        ? SeedData.insurances.firstWhere((i) => i.id == draft.insuranceId, orElse: () => SeedData.insurances.first)
        : null;

    final dt = draft.dateTime;
    final dateFmt = dt != null ? DateFormat(isAr ? 'EEEE، d MMMM yyyy' : 'EEEE, d MMMM yyyy', isAr ? 'ar' : 'en').format(dt) : '—';
    final timeFmt = dt != null ? DateFormat('hh:mm a').format(dt) : '—';

    return Scaffold(
      appBar: ScreenHeader(titleAr: 'تأكيد الحجز', titleEn: 'Confirm Booking'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(JuhSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AlertBanner(
              message: isAr
                  ? 'يرجى مراجعة تفاصيل موعدك قبل التأكيد'
                  : 'Please review your appointment details before confirming',
            ),
            const SizedBox(height: JuhSizes.md),
            _SummaryCard(
              isAr: isAr,
              rows: [
                (isAr ? 'المريض' : 'Patient', widget.who == 'self' ? (isAr ? 'أنا' : 'Self') : widget.who),
                if (ins != null) (isAr ? 'التأمين' : 'Insurance', isAr ? ins.nameAr : ins.nameEn),
                if (spec != null) (isAr ? 'التخصص' : 'Specialty', isAr ? spec.nameAr : spec.nameEn),
                if (doc != null) (isAr ? 'الطبيب' : 'Doctor', isAr ? doc.nameAr : doc.nameEn),
                (isAr ? 'التاريخ' : 'Date', dateFmt),
                (isAr ? 'الوقت' : 'Time', timeFmt),
                (isAr ? 'رسوم الاستشارة' : 'Consult Fee', doc?.consultFee ?? '—'),
                (isAr ? 'كود المرجع' : 'Reference', _refCode),
              ],
            ),
            const SizedBox(height: JuhSizes.lg),
            AppButton(
              label: isAr ? 'تأكيد الحجز' : 'Confirm Booking',
              onTap: _confirm,
              loading: _loading,
              icon: Icons.check,
            ),
            const SizedBox(height: JuhSizes.sm),
            AppButton.outline(
              label: isAr ? 'تعديل' : 'Edit',
              onTap: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final bool isAr;
  final List<(String, String)> rows;
  const _SummaryCard({required this.isAr, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border.all(color: context.cs.outline),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(row.$1, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
                    Flexible(
                      child: Text(
                        row.$2,
                        style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < rows.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final bool isAr;
  final String refCode;
  const _SuccessView({required this.isAr, required this.refCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(JuhSizes.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(color: JuhColors.successSoft, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_outline, color: JuhColors.success, size: 56),
                ),
              ),
              const SizedBox(height: JuhSizes.lg),
              Text(
                isAr ? 'تم تأكيد حجزك!' : 'Booking Confirmed!',
                style: context.tt.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: JuhSizes.sm),
              Text(
                isAr ? 'سيصلك تأكيد على بريدك الإلكتروني' : 'A confirmation has been sent to your email',
                style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: JuhSizes.lg),
              Container(
                padding: const EdgeInsets.all(JuhSizes.md),
                decoration: BoxDecoration(
                  color: JuhColors.primarySoft,
                  borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
                ),
                child: Column(
                  children: [
                    Text(isAr ? 'رقم المرجع' : 'Reference Number',
                        style: const TextStyle(color: JuhColors.primaryInk, fontSize: JuhSizes.fontSm)),
                    const SizedBox(height: 4),
                    Text(
                      refCode,
                      style: const TextStyle(
                        color: JuhColors.primary,
                        fontSize: JuhSizes.fontXl,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: isAr ? 'عرض مواعيدي' : 'View My Appointments',
                onTap: () => context.go('/appointments'),
                icon: Icons.calendar_month,
              ),
              const SizedBox(height: JuhSizes.sm),
              AppButton.ghost(
                label: isAr ? 'العودة للرئيسية' : 'Back to Home',
                onTap: () => context.go('/home'),
              ),
              const SizedBox(height: JuhSizes.md),
            ],
          ),
        ),
      ),
    );
  }
}

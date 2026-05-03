import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/colors.dart';
import '../../../core/sizes.dart';
import '../../../data/seed_data.dart';
import '../../../models/appointment.dart';
import '../../../providers/appointments_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/lang_toggle.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showBookingOptions(BuildContext context, bool isAr) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
              JuhSizes.md, JuhSizes.sm, JuhSizes.md, JuhSizes.lg),
          decoration: const BoxDecoration(
            color: JuhColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(JuhSizes.radiusXl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: JuhSizes.md),
                  decoration: BoxDecoration(
                    color: JuhColors.border,
                    borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
                  ),
                ),
              ),
              Row(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    margin: isAr
                        ? const EdgeInsets.only(left: JuhSizes.sm)
                        : const EdgeInsets.only(right: JuhSizes.sm),
                    decoration: BoxDecoration(
                      color: JuhColors.primary,
                      borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
                    ),
                  ),
                  Text(
                    isAr ? 'حجز موعد جديد' : 'New Appointment',
                    style: const TextStyle(
                      fontSize: JuhSizes.fontMd,
                      fontWeight: FontWeight.w700,
                      color: JuhColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: JuhSizes.md),
              _BookingOptionTile(
                title: isAr ? 'حجز لي' : 'Book for me',
                subtitle:
                    isAr ? 'متابعة مباشرة للحجز الشخصي' : 'Continue as self',
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/booking?who=self');
                },
              ),
              const SizedBox(height: JuhSizes.sm),
              _BookingOptionTile(
                title: isAr ? 'حجز لشخص آخر' : 'Book for someone else',
                subtitle:
                    isAr ? 'اختر من قائمة الأقارب' : 'Choose from relatives',
                icon: Icons.group_outlined,
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/relatives?who=other');
                },
              ),
              const SizedBox(height: JuhSizes.sm),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final profile = ref.watch(profileProvider);
    final allAppts = ref.watch(appointmentsProvider);
    final upcoming = allAppts
        .where((a) =>
            a.status == ApptStatus.confirmed &&
            a.dateTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final nextAppt = upcoming.isNotEmpty ? upcoming.first : null;
    final name = isAr ? profile.nameAr : profile.nameEn;
    final firstName = name.split(' ').first;
    final avatarLetter = name.isNotEmpty ? name[0] : '؟';

    return Scaffold(
      backgroundColor: JuhColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ──
          SliverToBoxAdapter(
            child: _HomeHeader(
              isAr: isAr,
              firstName: firstName,
              avatarLetter: avatarLetter,
              onNotificationTap: () {},
              onAvatarTap: () => context.push('/profile'),
            ),
          ),

          // ── Next appointment card ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  JuhSizes.md, JuhSizes.md, JuhSizes.md, JuhSizes.md),
              child: nextAppt != null
                  ? _NextApptCard(appt: nextAppt, isAr: isAr)
                  : _EmptyNextCard(isAr: isAr),
            ),
          ),

          // ── Quick actions ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  JuhSizes.md, 0, JuhSizes.md, JuhSizes.sm),
              child: _SectionHeader(
                isAr: isAr,
                title: isAr ? 'الخدمات' : 'Services',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.18,
              ),
              delegate: SliverChildListDelegate([
                _ActionCard(
                  isAr: isAr,
                  icon: Icons.add_circle_rounded,
                  iconColor: JuhColors.accent,
                  iconBg: JuhColors.accentSoft,
                  title: isAr ? 'حجز موعد جديد' : 'New Appointment',
                  subtitle: isAr
                      ? 'لي أو لشخص آخر'
                      : 'For me or someone else',
                  onTap: () => _showBookingOptions(context, isAr),
                ),
                _ActionCard(
                  isAr: isAr,
                  icon: Icons.calendar_month_rounded,
                  iconColor: JuhColors.primary,
                  iconBg: JuhColors.primarySoft,
                  title: isAr ? 'مواعيدي' : 'My Appointments',
                  subtitle: isAr
                      ? '${upcoming.length} موعد قادم'
                      : '${upcoming.length} upcoming',
                  onTap: () => context.push('/appointments'),
                ),
                _ActionCard(
                  isAr: isAr,
                  icon: Icons.medical_information_outlined,
                  iconColor: JuhColors.primaryMid,
                  iconBg: JuhColors.primarySoft,
                  title: isAr
                      ? 'استفسار مواعيد العيادات'
                      : 'Clinic Appointments',
                  subtitle: isAr
                      ? 'متابعة مواعيد العيادات'
                      : 'Track clinic slots',
                  onTap: () =>
                      context.push('/clinic-appointments-inquiry'),
                ),
                _ActionCard(
                  isAr: isAr,
                  icon: Icons.event_busy_rounded,
                  iconColor: const Color(0xFF6B4B8C),
                  iconBg: const Color(0xFFEDE5F5),
                  title: isAr ? 'اجازات الاطباء' : 'Doctors Leave',
                  subtitle: isAr
                      ? 'التحقق من اجازات الاطباء'
                      : 'Check doctors leaves',
                  onTap: () => context.push('/doctors-leave-inquiry'),
                ),
              ]),
            ),
          ),

          // ── Popular specialties ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  JuhSizes.md, JuhSizes.lg, JuhSizes.md, JuhSizes.sm),
              child: _SectionHeader(
                isAr: isAr,
                title: isAr ? 'أقسام شائعة' : 'Popular Specialties',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: JuhSizes.md),
                separatorBuilder: (_, __) =>
                    const SizedBox(width: JuhSizes.sm),
                itemCount: SeedData.specialties.length,
                itemBuilder: (ctx, i) {
                  final s = SeedData.specialties[i];
                  return GestureDetector(
                    onTap: () => context.push('/booking?who=self'),
                    child: _SpecialtyPill(
                      isAr: isAr,
                      icon: s.icon,
                      label: isAr
                          ? s.nameAr.split(' ').first
                          : s.nameEn.split(' ').first,
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: JuhSizes.xl)),
        ],
      ),
      bottomNavigationBar: _BottomNav(isAr: isAr),
    );
  }
}

// ─────────────────────────────── Header ────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final bool isAr;
  final String firstName;
  final String avatarLetter;
  final VoidCallback onNotificationTap;
  final VoidCallback onAvatarTap;

  const _HomeHeader({
    required this.isAr,
    required this.firstName,
    required this.avatarLetter,
    required this.onNotificationTap,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Gradient background
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [JuhColors.primary, JuhColors.primaryInk],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        // Decorative circles
        Positioned(
          top: topPad - 10,
          right: isAr ? null : -40,
          left: isAr ? -40 : null,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: isAr ? -25 : null,
          left: isAr ? null : -25,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
        // Content
        Padding(
          padding: EdgeInsets.fromLTRB(
            JuhSizes.md,
            topPad + JuhSizes.md,
            JuhSizes.md,
            JuhSizes.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                textDirection:
                    isAr ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(JuhSizes.radiusMd),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: JuhSizes.iconMd,
                      ),
                    ),
                  ),
                  const SizedBox(width: JuhSizes.sm),
                  const LangToggle(light: true),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: isAr
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'مرحباً،' : 'Hello,',
                        style: const TextStyle(
                          fontSize: JuhSizes.fontXs,
                          color: Colors.white60,
                        ),
                      ),
                      Text(
                        firstName,
                        style: const TextStyle(
                          fontSize: JuhSizes.fontBase,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          avatarLetter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: JuhSizes.fontBase,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: JuhSizes.md),
              Text(
                isAr ? 'مستشفى الجامعة الأردنية' : 'Jordan University Hospital',
                textAlign: isAr ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: JuhSizes.fontMd,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isAr ? 'رعاية متميزة، صحة مستدامة' : 'Exceptional Care, Trusted Health',
                textAlign: isAr ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: JuhSizes.fontSm,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Section header ────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final bool isAr;
  final String title;
  const _SectionHeader({required this.isAr, required this.title});

  @override
  Widget build(BuildContext context) {
    final accent = Container(
      width: 4,
      height: 18,
      decoration: BoxDecoration(
        color: JuhColors.primary,
        borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
      ),
    );
    return Row(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
        accent,
        const SizedBox(width: JuhSizes.sm),
        Text(
          title,
          style: const TextStyle(
            fontSize: JuhSizes.fontBase,
            fontWeight: FontWeight.w700,
            color: JuhColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────── Next appointment card ─────────────────────────────

class _NextApptCard extends StatelessWidget {
  final Appointment appt;
  final bool isAr;
  const _NextApptCard({required this.appt, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final dateFmt =
        DateFormat(isAr ? 'd MMMM' : 'MMM d', isAr ? 'ar' : 'en');
    final timeFmt = DateFormat('HH:mm');

    return GestureDetector(
      onTap: () => context.push('/appointments/${appt.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: JuhSizes.md, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [JuhColors.primary, JuhColors.primaryInk],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: JuhColors.primary.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment:
                    isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(JuhSizes.radiusFull),
                    ),
                    child: Text(
                      isAr ? 'موعدك القادم' : 'Next Appointment',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isAr ? appt.doctorNameAr : appt.doctorNameEn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: JuhSizes.fontBase,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    isAr ? appt.specialtyAr : appt.specialtyEn,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: JuhSizes.fontXs),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    textDirection:
                        isAr ? TextDirection.rtl : TextDirection.ltr,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: dateFmt.format(appt.dateTime),
                      ),
                      const SizedBox(width: 6),
                      _InfoChip(
                        icon: Icons.access_time_outlined,
                        label: timeFmt.format(appt.dateTime),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: JuhSizes.sm),
            // Arrow button
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAr ? Icons.chevron_left : Icons.chevron_right,
                color: Colors.white,
                size: JuhSizes.iconMd,
              ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: JuhSizes.iconSm),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: JuhSizes.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNextCard extends StatelessWidget {
  final bool isAr;
  const _EmptyNextCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: JuhSizes.md, vertical: 14),
      decoration: BoxDecoration(
        color: JuhColors.surface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border.all(color: JuhColors.border),
      ),
      child: Row(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: JuhColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: JuhColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: JuhSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'لا توجد مواعيد قادمة' : 'No upcoming appointments',
                  style: const TextStyle(
                    fontSize: JuhSizes.fontSm,
                    fontWeight: FontWeight.w600,
                    color: JuhColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAr
                      ? 'استخدم الإجراءات السريعة أدناه لحجز موعد'
                      : 'Use Quick Actions below to book an appointment',
                  style: const TextStyle(
                    fontSize: JuhSizes.fontXs,
                    color: JuhColors.textSecondary,
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

// ───────────────────────────── Action card ─────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isAr;
  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: JuhColors.surface,
          borderRadius: BorderRadius.circular(JuhSizes.radiusXl),
          border: Border.all(
              color: JuhColors.border.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              textDirection:
                  isAr ? TextDirection.rtl : TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius:
                        BorderRadius.circular(JuhSizes.radiusSm),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                Icon(
                  isAr ? Icons.chevron_left : Icons.chevron_right,
                  color: JuhColors.textMuted,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: JuhSizes.fontSm,
                fontWeight: FontWeight.w700,
                color: JuhColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: JuhSizes.fontXs,
                  color: JuhColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────── Booking option tile ─────────────────────────────

class _BookingOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _BookingOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          color: JuhColors.bg,
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          border: Border.all(color: JuhColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: JuhColors.primarySoft,
                borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
              ),
              child: Icon(icon, color: JuhColors.primary, size: JuhSizes.iconMd),
            ),
            const SizedBox(width: JuhSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: JuhSizes.fontSm,
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
            const Icon(Icons.chevron_right,
                color: JuhColors.textMuted, size: JuhSizes.iconMd),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────── Bottom nav ─────────────────────────────────

class _BottomNav extends StatelessWidget {
  final bool isAr;
  const _BottomNav({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: JuhColors.bg,
        border: Border(
          top: BorderSide(color: JuhColors.border, width: 1),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: JuhColors.bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            indicatorColor: JuhColors.primarySoft,
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: JuhColors.primary);
              }
              return const IconThemeData(color: JuhColors.textSecondary);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: JuhColors.primary,
                  fontSize: JuhSizes.fontXs,
                  fontWeight: FontWeight.w700,
                );
              }
              return const TextStyle(
                color: JuhColors.textSecondary,
                fontSize: JuhSizes.fontXs,
              );
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: 0,
          backgroundColor: JuhColors.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/appointments');
                break;
              case 2:
                context.go('/booking?who=self');
                break;
              case 3:
                context.go('/profile');
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: isAr ? 'الرئيسية' : 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: isAr ? 'مواعيدي' : 'Appointments',
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_circle_outline),
              selectedIcon: const Icon(Icons.add_circle),
              label: isAr ? 'حجز' : 'Book',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: isAr ? 'بياناتي' : 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Specialty pill ────────────────────────────────

class _SpecialtyPill extends StatelessWidget {
  final bool isAr;
  final String icon;
  final String label;
  const _SpecialtyPill({
    required this.isAr,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: JuhColors.surface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
        border: Border.all(color: JuhColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: JuhSizes.fontXs,
              fontWeight: FontWeight.w700,
              color: JuhColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

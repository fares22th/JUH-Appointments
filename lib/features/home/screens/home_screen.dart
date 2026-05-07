import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/nhost.dart';
import '../../../core/sizes.dart';
import '../../../data/seed_data.dart';
import '../../../models/appointment.dart';
import '../../../providers/appointments_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../shared/widgets/lang_toggle.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showBookingOptions(BuildContext context, bool isAr) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
              JuhSizes.md, JuhSizes.sm, JuhSizes.md, JuhSizes.lg),
          decoration: BoxDecoration(
            color: ctx.juhSurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(JuhSizes.radiusXl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: JuhSizes.md),
                  decoration: BoxDecoration(
                    color: ctx.juhBorder,
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
                    style: TextStyle(
                      fontSize: JuhSizes.fontMd,
                      fontWeight: FontWeight.w700,
                      color: ctx.juhText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: JuhSizes.md),
              _BookingOptionTile(
                isAr: isAr,
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
                isAr: isAr,
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
  Widget build(BuildContext context) {
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
      key: _scaffoldKey,
      backgroundColor: context.juhBg,
      drawer: _AppDrawer(isAr: isAr, name: name, avatarLetter: avatarLetter),
      body: CustomScrollView(
        slivers: [
          // ── Gradient header + floating appointment card ──
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Column(
                  children: [
                    _HomeHeader(
                      isAr: isAr,
                      firstName: firstName,
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                      onNotifTap: () => context.push('/appointments'),
                      notifCount: upcoming.length,
                    ),
                    Container(height: 110, color: context.juhBg),
                  ],
                ),
                Positioned(
                  bottom: 12,
                  left: JuhSizes.md,
                  right: JuhSizes.md,
                  child: nextAppt != null
                      ? _NextApptCard(appt: nextAppt, isAr: isAr)
                      : _EmptyNextCard(isAr: isAr),
                ),
              ],
            ),
          ),

          // ── Quick actions ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  JuhSizes.md, 0, JuhSizes.md, JuhSizes.sm),
              child: _SectionHeader(
                isAr: isAr,
                title: isAr ? 'خدماتك' : 'Your Services',
                action: Text(
                  isAr ? 'عرض الكل' : 'View All',
                  style: const TextStyle(
                    fontSize: JuhSizes.fontSm,
                    fontWeight: FontWeight.w600,
                    color: JuhColors.primary,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
              child: Column(
                children: [
                  _FeaturedBookingCard(
                    isAr: isAr,
                    onTap: () => _showBookingOptions(context, isAr),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ServiceCard(
                          isAr: isAr,
                          icon: Icons.event_available_rounded,
                          iconColor: JuhColors.primary,
                          cardBg: context.juhPrimarySoft,
                          title: isAr ? 'مواعيدي' : 'My Appointments',
                          subtitle: isAr
                              ? '${upcoming.length} موعد قادم'
                              : '${upcoming.length} upcoming',
                          onTap: () => context.push('/appointments'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ServiceCard(
                          isAr: isAr,
                          icon: Icons.personal_injury_rounded,
                          iconColor: JuhColors.success,
                          cardBg: context.juhSuccessSoft,
                          title: isAr ? 'إجازات الأطباء' : 'Doctors Leave',
                          subtitle: isAr ? 'التحقق من التوافر' : 'Check availability',
                          onTap: () => context.push('/doctors-leave-inquiry'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ServiceCardWide(
                    isAr: isAr,
                    icon: Icons.local_hospital_rounded,
                    iconColor: JuhColors.primaryMid,
                    cardBg: context.juhPrimarySoft,
                    title: isAr ? 'استفسار مواعيد العيادات' : 'Clinic Appointments',
                    subtitle: isAr ? 'متابعة مواعيد العيادات' : 'Track clinic slots',
                    onTap: () => context.push('/clinic-appointments-inquiry'),
                  ),
                ],
              ),
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
                  return Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push('/booking?who=self'),
                      splashColor: JuhColors.primary.withValues(alpha: 0.15),
                      highlightColor: Colors.transparent,
                      child: _SpecialtyPill(
                        isAr: isAr,
                        icon: s.icon,
                        label: isAr
                            ? s.nameAr.split(' ').first
                            : s.nameEn.split(' ').first,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: JuhSizes.xl)),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Header ────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final bool isAr;
  final String firstName;
  final VoidCallback onMenuTap;
  final VoidCallback onNotifTap;
  final int notifCount;

  const _HomeHeader({
    required this.isAr,
    required this.firstName,
    required this.onMenuTap,
    required this.onNotifTap,
    required this.notifCount,
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
            JuhSizes.xl + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                textDirection:
                    isAr ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onMenuTap,
                      splashColor: Colors.white.withValues(alpha: 0.25),
                      highlightColor: Colors.transparent,
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
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: JuhSizes.iconMd,
                        ),
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
                  const SizedBox(width: JuhSizes.sm),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        color: Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(JuhSizes.radiusMd),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: onNotifTap,
                          splashColor:
                              Colors.white.withValues(alpha: 0.25),
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                  JuhSizes.radiusMd),
                              border: Border.all(
                                color: Colors.white
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: JuhSizes.iconMd,
                            ),
                          ),
                        ),
                      ),
                      if (notifCount > 0)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: JuhColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: JuhColors.primary, width: 1.5),
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 16, minHeight: 16),
                            child: Text(
                              notifCount > 9 ? '9+' : '$notifCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: JuhSizes.md),
              Text(
                isAr ? 'مستشفى الجامعة الأردنية' : 'Jordan University Hospital',
                textAlign: isAr ? TextAlign.right : TextAlign.left,
                style: GoogleFonts.reemKufi(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
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
  final Widget? action;
  const _SectionHeader({required this.isAr, required this.title, this.action});

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
          style: TextStyle(
            fontSize: JuhSizes.fontBase,
            fontWeight: FontWeight.w700,
            color: context.juhText,
          ),
        ),
        const Spacer(),
        if (action != null) action!,
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
    final dateFmt = DateFormat(isAr ? 'd MMMM' : 'MMM d', isAr ? 'ar' : 'en');
    final timeFmt = DateFormat('HH:mm');

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/appointments/${appt.id}'),
        splashColor: JuhColors.primary.withValues(alpha: 0.06),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(JuhSizes.md),
          decoration: BoxDecoration(
            color: context.juhSurface,
            borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
            border: Border.all(color: context.juhBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.juhPrimarySoft,
                        borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
                      ),
                      child: Text(
                        isAr ? 'موعدك القادم' : 'Next Appointment',
                        style: const TextStyle(
                          color: JuhColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAr ? appt.doctorNameAr : appt.doctorNameEn,
                      style: TextStyle(
                        color: context.juhText,
                        fontSize: JuhSizes.fontMd,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr ? appt.specialtyAr : appt.specialtyEn,
                      style: TextStyle(
                        color: context.juhTextSub,
                        fontSize: JuhSizes.fontXs,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
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
              // Nav button
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.juhPrimarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAr ? Icons.chevron_left : Icons.chevron_right,
                  color: JuhColors.primary,
                  size: JuhSizes.iconMd,
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: context.juhBg,
        borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
        border: Border.all(color: context.juhBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: JuhColors.primary, size: JuhSizes.iconSm),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: context.juhText,
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
        color: context.juhSurface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border.all(color: context.juhBorder),
      ),
      child: Row(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.juhPrimarySoft,
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
                  CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'لا توجد مواعيد قادمة' : 'No upcoming appointments',
                  style: TextStyle(
                    fontSize: JuhSizes.fontSm,
                    fontWeight: FontWeight.w600,
                    color: context.juhText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAr
                      ? 'استخدم الإجراءات السريعة أدناه لحجز موعد'
                      : 'Use Quick Actions below to book an appointment',
                  style: TextStyle(
                    fontSize: JuhSizes.fontXs,
                    color: context.juhTextSub,
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

// ───────────────────────── Press effect wrapper ────────────────────────────

class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  const _Pressable({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.94 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: widget.borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          splashColor: Colors.black.withValues(alpha: 0.07),
          highlightColor: Colors.black.withValues(alpha: 0.04),
          child: widget.child,
        ),
      ),
    );
  }
}

// ───────────────────────── Featured booking card ───────────────────────────

class _FeaturedBookingCard extends StatelessWidget {
  final bool isAr;
  final VoidCallback onTap;
  const _FeaturedBookingCard({required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(JuhSizes.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [JuhColors.accent, JuhColors.accentInk],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
            borderRadius: BorderRadius.circular(JuhSizes.radiusXl),
            boxShadow: [
              BoxShadow(
                color: JuhColors.accent.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'حجز موعد جديد' : 'New Appointment',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: JuhSizes.fontMd,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isAr
                          ? 'احجز لك أو لأحد أقاربك'
                          : 'Book for you or a relative',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: JuhSizes.fontXs,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(JuhSizes.radiusFull),
                      ),
                      child: Text(
                        isAr ? 'ابدأ الآن ←' : 'Get Started →',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: JuhSizes.fontXs,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
    );
  }
}

// ───────────────────────────── Service card (small) ────────────────────────

class _ServiceCard extends StatelessWidget {
  final bool isAr;
  final IconData icon;
  final Color iconColor;
  final Color cardBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ServiceCard({
    required this.isAr,
    required this.icon,
    required this.iconColor,
    required this.cardBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(JuhSizes.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(JuhSizes.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: iconColor.withValues(alpha: 0.7),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: JuhSizes.sm),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontSize: JuhSizes.fontSm,
                fontWeight: FontWeight.w700,
                color: context.juhText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontSize: JuhSizes.fontXs,
                color: context.juhTextSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── Service card (wide) ─────────────────────────

class _ServiceCardWide extends StatelessWidget {
  final bool isAr;
  final IconData icon;
  final Color iconColor;
  final Color cardBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ServiceCardWide({
    required this.isAr,
    required this.icon,
    required this.iconColor,
    required this.cardBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(JuhSizes.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(JuhSizes.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: JuhSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: JuhSizes.fontSm,
                      fontWeight: FontWeight.w700,
                      color: context.juhText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: JuhSizes.fontXs,
                      color: context.juhTextSub,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_outward_rounded,
              color: iconColor.withValues(alpha: 0.7),
              size: 16,
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
  final bool isAr;
  const _BookingOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          color: context.juhBg,
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          border: Border.all(color: context.juhBorder),
        ),
        child: Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.juhPrimarySoft,
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
                    style: TextStyle(
                      fontSize: JuhSizes.fontSm,
                      fontWeight: FontWeight.w700,
                      color: context.juhText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: JuhSizes.fontXs,
                      color: context.juhTextSub,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isAr ? Icons.chevron_left : Icons.chevron_right,
              color: context.juhTextMuted,
              size: JuhSizes.iconMd,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────── App Drawer ───────────────────────────────────

class _AppDrawer extends ConsumerWidget {
  final bool isAr;
  final String name;
  final String avatarLetter;

  const _AppDrawer({
    required this.isAr,
    required this.name,
    required this.avatarLetter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    void go(String route) {
      Navigator.pop(context);
      context.go(route);
    }

    void push(String route) {
      Navigator.pop(context);
      context.push(route);
    }

    return Drawer(
      backgroundColor: context.juhSurface,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [JuhColors.primary, JuhColors.primaryInk],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2),
                    ),
                    child: Center(
                      child: Text(
                        avatarLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: JuhSizes.fontBase,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isAr ? 'مستشفى الجامعة الأردنية' : 'Jordan University Hospital',
                    style: GoogleFonts.reemKufi(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: JuhSizes.fontSm,
                    ),
                  ),
                ],
              ),
            ),

            // ── Navigation items ────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.home_rounded,
                    label: isAr ? 'الرئيسية' : 'Home',
                    onTap: () => go('/home'),
                  ),
                  _DrawerItem(
                    icon: Icons.event_available_rounded,
                    label: isAr ? 'مواعيدي' : 'My Appointments',
                    onTap: () => go('/appointments'),
                  ),
                  _DrawerItem(
                    icon: Icons.medical_services_rounded,
                    label: isAr ? 'حجز موعد جديد' : 'New Appointment',
                    onTap: () => push('/booking?who=self'),
                  ),
                  _DrawerItem(
                    icon: Icons.local_hospital_rounded,
                    label: isAr ? 'استفسار مواعيد العيادات' : 'Clinic Appointments',
                    onTap: () => push('/clinic-appointments-inquiry'),
                  ),
                  _DrawerItem(
                    icon: Icons.personal_injury_rounded,
                    label: isAr ? 'إجازات الأطباء' : 'Doctors Leave',
                    onTap: () => push('/doctors-leave-inquiry'),
                  ),

                  const Divider(height: 24, indent: 16, endIndent: 16),

                  _DrawerItem(
                    icon: Icons.person_rounded,
                    label: isAr ? 'بياناتي' : 'My Profile',
                    onTap: () => go('/profile'),
                  ),
                  _DrawerItem(
                    icon: Icons.email_outlined,
                    label: isAr ? 'البريد الوارد' : 'Inbox',
                    onTap: () => push('/email'),
                  ),

                  // Language toggle row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 2),
                    child: Row(
                      textDirection:
                          isAr ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.juhPrimarySoft,
                            borderRadius:
                                BorderRadius.circular(JuhSizes.radiusMd),
                          ),
                          child: const Icon(Icons.language_rounded,
                              color: JuhColors.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            isAr ? 'اللغة' : 'Language',
                            style: TextStyle(
                              fontSize: JuhSizes.fontSm,
                              fontWeight: FontWeight.w600,
                              color: context.juhText,
                            ),
                          ),
                        ),
                        const LangToggle(light: false),
                      ],
                    ),
                  ),

                  // Dark mode toggle row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 2),
                    child: Row(
                      textDirection:
                          isAr ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.juhPrimarySoft,
                            borderRadius:
                                BorderRadius.circular(JuhSizes.radiusMd),
                          ),
                          child: Icon(
                            isDark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: JuhColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            isAr ? 'الوضع الليلي' : 'Dark Mode',
                            style: TextStyle(
                              fontSize: JuhSizes.fontSm,
                              fontWeight: FontWeight.w600,
                              color: context.juhText,
                            ),
                          ),
                        ),
                        Switch(
                          value: isDark,
                          activeThumbColor: Colors.white,
                          activeTrackColor: JuhColors.primary,
                          onChanged: (_) => ref
                              .read(themeModeProvider.notifier)
                              .toggle(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Sign out ────────────────────────────────────
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: isAr ? 'تسجيل الخروج' : 'Sign Out',
              iconColor: JuhColors.error,
              labelColor: JuhColors.error,
              onTap: () async {
                Navigator.pop(context);
                try {
                  await nhostClient.auth
                      .signOut()
                      .timeout(const Duration(seconds: 6));
                } catch (_) {
                  // Network error or timeout — clear the local session directly
                  // so GoRouter redirect fires even without a server response.
                  // ignore: invalid_use_of_visible_for_testing_member
                  await nhostClient.auth.clearSession();
                }
                // GoRouter's authListenable handles the redirect automatically;
                // context.go is a safety-net for cases where the drawer context
                // is still mounted (it typically isn't after Navigator.pop).
                if (context.mounted) context.go('/welcome');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color? labelColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = JuhColors.primary,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: JuhSizes.fontSm,
          fontWeight: FontWeight.w600,
          color: labelColor ?? context.juhText,
        ),
      ),
      trailing: Icon(
        isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        color: context.juhTextMuted,
        size: 18,
      ),
      onTap: onTap,
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
        color: context.juhSurface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
        border: Border.all(color: context.juhBorder),
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
            style: TextStyle(
              fontSize: JuhSizes.fontXs,
              fontWeight: FontWeight.w700,
              color: context.juhText,
            ),
          ),
        ],
      ),
    );
  }
}

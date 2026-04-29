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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final profile = ref.watch(profileProvider);
    final upcoming = ref.read(appointmentsProvider.notifier).upcoming;
    final nextAppt = upcoming.isNotEmpty ? upcoming.first : null;
    final firstName = (isAr ? profile.nameAr : profile.nameEn).split(' ').first;
    final avatarLetter = (isAr ? profile.nameAr : profile.nameEn)[0];

    return Scaffold(
      backgroundColor: JuhColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: JuhSizes.md, vertical: 14),
                child: Row(
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    // Bell button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(JuhSizes.radiusMd),
                          border: Border.all(color: JuhColors.border),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: JuhColors.textSecondary,
                            size: JuhSizes.iconMd),
                      ),
                    ),
                    const SizedBox(width: JuhSizes.sm),
                    const LangToggle(),
                    const Spacer(),
                    // Greeting + name
                    Column(
                      crossAxisAlignment: isAr
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'مرحباً،' : 'Hello,',
                          style: const TextStyle(
                              fontSize: JuhSizes.fontXs,
                              color: JuhColors.textSecondary),
                        ),
                        Text(
                          firstName,
                          style: const TextStyle(
                            fontSize: JuhSizes.fontBase,
                            fontWeight: FontWeight.w700,
                            color: JuhColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    // Avatar (circular)
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: JuhColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            avatarLetter,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: JuhSizes.fontMd,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Next appointment card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    JuhSizes.md, 4, JuhSizes.md, JuhSizes.md),
                child: nextAppt != null
                    ? _NextApptCard(appt: nextAppt, isAr: isAr)
                    : _EmptyNextCard(isAr: isAr),
              ),
            ),

            // ── Quick actions header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    JuhSizes.md, 0, JuhSizes.md, JuhSizes.sm),
                child: Align(
                  alignment:
                      isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    isAr ? 'إجراءات سريعة' : 'Quick Actions',
                    style: const TextStyle(
                      fontSize: JuhSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      color: JuhColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // ── Quick actions grid ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _ActionCard(
                      isAr: isAr,
                      icon: Icons.add_circle_outline,
                      iconColor: JuhColors.primary,
                      iconBg: JuhColors.primarySoft,
                      title: isAr ? 'حجز موعد جديد' : 'New Appointment',
                      subtitle: isAr ? 'لي' : 'For me',
                      onTap: () => context.push('/relatives?who=self'),
                    ),
                    _ActionCard(
                      isAr: isAr,
                      icon: Icons.people_outline,
                      iconColor: const Color(0xFF7B1FA2),
                      iconBg: const Color(0xFFF3E5F5),
                      title: isAr ? 'حجز لقريب' : 'Book for Relative',
                      subtitle: isAr ? 'الأهل والأبناء' : 'Family members',
                      onTap: () => context.push('/relatives'),
                    ),
                    _ActionCard(
                      isAr: isAr,
                      icon: Icons.calendar_month_outlined,
                      iconColor: const Color(0xFF00796B),
                      iconBg: const Color(0xFFE0F2F1),
                      title: isAr ? 'مواعيدي' : 'My Appointments',
                      subtitle: isAr
                          ? '${upcoming.length} موعد قادم'
                          : '${upcoming.length} upcoming',
                      onTap: () => context.push('/appointments'),
                    ),
                    _ActionCard(
                      isAr: isAr,
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFFE65100),
                      iconBg: const Color(0xFFFFF3E0),
                      title: isAr ? 'بياناتي' : 'My Data',
                      subtitle: isAr ? 'تعديل التواصل' : 'Edit contact info',
                      onTap: () => context.push('/profile'),
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
                child: Align(
                  alignment:
                      isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    isAr ? 'أقسام شائعة' : 'Popular Specialties',
                    style: const TextStyle(
                      fontSize: JuhSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      color: JuhColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: JuhSizes.sm),
                  itemCount: SeedData.specialties.length,
                  itemBuilder: (ctx, i) {
                    final s = SeedData.specialties[i];
                    return GestureDetector(
                      onTap: () => context.push('/relatives?who=self'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(JuhSizes.radiusFull),
                          border: Border.all(color: JuhColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(s.icon, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              isAr
                                  ? s.nameAr.split(' ').first
                                  : s.nameEn.split(' ').first,
                              style: const TextStyle(
                                fontSize: JuhSizes.fontXs,
                                fontWeight: FontWeight.w600,
                                color: JuhColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: JuhSizes.lg)),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(isAr: isAr),
    );
  }
}

// ── Next appointment card ──
class _NextApptCard extends StatelessWidget {
  final Appointment appt;
  final bool isAr;
  const _NextApptCard({required this.appt, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat(isAr ? 'd MMMM' : 'MMM d', isAr ? 'ar' : 'en');
    final timeFmt = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.all(JuhSizes.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [JuhColors.primary, JuhColors.primaryInk],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(JuhSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: JuhColors.primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Decorative circles
          Positioned(
            top: -24,
            right: isAr ? null : -24,
            left: isAr ? -24 : null,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -32,
            right: isAr ? -32 : null,
            left: isAr ? null : -32,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment:
                isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
                ),
                child: Text(
                  isAr ? 'موعدك القادم' : 'Next Appointment',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: JuhSizes.fontXs,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isAr ? appt.doctorNameAr : appt.doctorNameEn,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: JuhSizes.fontXl,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isAr ? appt.specialtyAr : appt.specialtyEn,
                style: const TextStyle(
                    color: Colors.white70, fontSize: JuhSizes.fontSm),
              ),
              const SizedBox(height: 12),
              // Date & time chips
              Row(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: dateFmt.format(appt.dateTime),
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.access_time_outlined,
                    label: timeFmt.format(appt.dateTime),
                  ),
                ],
              ),
              const SizedBox(height: JuhSizes.md),
              // Buttons
              Row(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          context.push('/appointments/${appt.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: JuhColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(JuhSizes.radiusMd)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        isAr ? 'عرض التفاصيل' : 'View Details',
                        style: const TextStyle(
                            fontSize: JuhSizes.fontSm,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push('/appointments'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(JuhSizes.radiusMd)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        isAr ? 'كل المواعيد' : 'All Appointments',
                        style: const TextStyle(
                            fontSize: JuhSizes.fontSm,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.all(JuhSizes.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [JuhColors.primary, JuhColors.primaryInk],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(JuhSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: JuhColors.primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -20,
            right: isAr ? null : -20,
            left: isAr ? -20 : null,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment:
                isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'لا توجد مواعيد قادمة' : 'No upcoming appointments',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: JuhSizes.fontMd,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                isAr ? 'احجز موعدك الآن' : 'Book your appointment now',
                style: const TextStyle(
                    color: Colors.white70, fontSize: JuhSizes.fontSm),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () => context.push('/relatives?who=self'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: JuhColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(JuhSizes.radiusMd)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                ),
                child: Text(
                  isAr ? 'احجز موعداً' : 'Book Now',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
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
              style: const TextStyle(
                  fontSize: JuhSizes.fontXs, color: JuhColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final bool isAr;
  const _BottomNav({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      backgroundColor: Colors.white,
      selectedItemColor: JuhColors.primary,
      unselectedItemColor: JuhColors.textSecondary,
      selectedLabelStyle: const TextStyle(
          fontSize: JuhSizes.fontXs, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: JuhSizes.fontXs),
      elevation: 8,
      onTap: (i) {
        switch (i) {
          case 0:
            break;
          case 1:
            context.push('/appointments');
          case 2:
            context.push('/relatives?who=self');
          case 3:
            context.push('/profile');
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: isAr ? 'الرئيسية' : 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_month_outlined),
          activeIcon: const Icon(Icons.calendar_month),
          label: isAr ? 'مواعيدي' : 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.add_circle_outline),
          activeIcon: const Icon(Icons.add_circle),
          label: isAr ? 'حجز' : 'Book',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: isAr ? 'بياناتي' : 'Profile',
        ),
      ],
    );
  }
}

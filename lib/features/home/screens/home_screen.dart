import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../data/seed_data.dart';
import '../../../models/appointment.dart';
import '../../../providers/appointments_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/lang_toggle.dart';
import '../../../shared/widgets/status_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final profile = ref.watch(profileProvider);
    final upcoming = ref.read(appointmentsProvider.notifier).upcoming;
    final nextAppt = upcoming.isNotEmpty ? upcoming.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Directionality(
                  textDirection:
                      isAr ? TextDirection.rtl : TextDirection.ltr,
                  child: Row(
                    children: [
                    // Notification bell
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined,
                          color: Color(0xFF444444)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
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
                              fontSize: 11, color: Color(0xFF888888)),
                        ),
                        Text(
                          isAr ? profile.nameAr : profile.nameEn,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    // Avatar
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2DA8C8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'i',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
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
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: nextAppt != null
                    ? _NextApptCard(appt: nextAppt, isAr: isAr)
                    : _EmptyNextCard(isAr: isAr),
              ),
            ),

            // ── Quick actions grid ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _ActionCard(
                      icon: Icons.add,
                      iconColor: const Color(0xFF2DA8C8),
                      title: isAr ? 'حجز موعد جديد' : 'New Appointment',
                      subtitle: isAr ? 'لي' : 'For me',
                      onTap: () => context.push('/booking?who=self'),
                    ),
                    _ActionCard(
                      icon: Icons.people_outline,
                      iconColor: const Color(0xFF2DA8C8),
                      title: isAr ? 'حجز لقريب' : 'Book for Relative',
                      subtitle: isAr ? 'الأهل والأبناء' : 'Family members',
                      onTap: () => context.push('/relatives'),
                    ),
                    _ActionCard(
                      icon: Icons.calendar_month_outlined,
                      iconColor: const Color(0xFF2DA8C8),
                      title: isAr ? 'مواعيدي' : 'My Appointments',
                      subtitle: isAr
                          ? '${upcoming.length} موعد قادم'
                          : '${upcoming.length} upcoming',
                      onTap: () => context.push('/appointments'),
                    ),
                    _ActionCard(
                      icon: Icons.settings_outlined,
                      iconColor: const Color(0xFF2DA8C8),
                      title: isAr ? 'بياناتي' : 'My Data',
                      subtitle:
                          isAr ? 'تعديل التواصل' : 'Edit contact info',
                      onTap: () => context.push('/profile'),
                    ),
                  ],
                ),
              ),
            ),

            // ── Specialties section ──
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Align(
                  alignment:
                      isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    isAr ? 'أقسام طائفة' : 'Specialties',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: SeedData.specialties.length,
                  itemBuilder: (ctx, i) {
                    final s = SeedData.specialties[i];
                    return GestureDetector(
                      onTap: () =>
                          context.push('/booking?who=self'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: const Color(0xFFE0E0E0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(s.icon,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              isAr
                                  ? s.nameAr.split(' ')[0]
                                  : s.nameEn.split(' ')[0],
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF333333)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),

      // ── Bottom nav ──
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
    final dateFmt = DateFormat(
        isAr ? 'd MMMM' : 'MMM d', isAr ? 'ar' : 'en');
    final timeFmt = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2DA8C8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: isAr
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'موعدك القادم' : 'Next Appointment',
            style: const TextStyle(
                color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            isAr ? appt.doctorNameAr : appt.doctorNameEn,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            textDirection:
                isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                dateFmt.format(appt.dateTime),
                style: const TextStyle(
                    color: Colors.white, fontSize: 13),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_outlined,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                timeFmt.format(appt.dateTime),
                style: const TextStyle(
                    color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            textDirection:
                isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      context.push('/appointments/${appt.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2DA8C8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    isAr ? 'عرض التفاصيل' : 'View Details',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      context.push('/appointments'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                        color: Colors.white54, width: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    isAr ? 'كل المواعيد' : 'All Appointments',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty next appointment card ──
class _EmptyNextCard extends StatelessWidget {
  final bool isAr;
  const _EmptyNextCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2DA8C8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: isAr
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'لا توجد مواعيد قادمة' : 'No upcoming appointments',
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            isAr ? 'احجز موعدك الآن' : 'Book your appointment now',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => context.push('/booking?who=self'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2DA8C8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isAr ? 'حجز موعد' : 'Book Now'),
          ),
        ],
      ),
    );
  }
}

// ── Quick action card ──
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom navigation ──
class _BottomNav extends StatelessWidget {
  final bool isAr;
  const _BottomNav({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF2DA8C8),
      unselectedItemColor: const Color(0xFF888888),
      selectedLabelStyle: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      elevation: 8,
      onTap: (i) {
        switch (i) {
          case 0:
            break;
          case 1:
            context.push('/appointments');
            break;
          case 2:
            context.push('/booking?who=self');
            break;
          case 3:
            context.push('/profile');
            break;
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
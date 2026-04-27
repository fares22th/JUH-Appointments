import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/lang_toggle.dart';
import '../../../shared/widgets/app_button.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ── Blue header section ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2DA8C8),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lang toggle + logo row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const LangToggle(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'JUH',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Main headline
                    Text(
                      isAr ? 'احجز موعدك في\nدقائق معدودة' : 'Book Your Appointment\nin Minutes',
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isAr
                          ? 'خدمة حجز المواعيد الإلكترونية لمستشفى الجامعة الأردنية،\nتحقق فوري عبر دائرة الأحوال المدنية.'
                          : 'Electronic appointment booking for Jordan University Hospital.\nInstant verification via Civil Status.',
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // ── Buttons ──
                    ElevatedButton.icon(
                      onPressed: () => context.push('/signup'),
                      icon: const Icon(Icons.fingerprint, size: 20),
                      label: Text(isAr ? 'إنشاء حساب جديد' : 'Create Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A7A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => context.go('/home'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.transparent),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(isAr ? 'تسجيل الدخول' : 'Sign In'),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // ── Features card ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isAr ? 'ما يميز المنصة' : 'Why Choose Us',
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...[
                      (Icons.verified_user_outlined,
                          isAr ? 'تحقق أمن من الهوية' : 'Secure Identity Verification'),
                      (Icons.timer_outlined,
                          isAr ? 'حجز خلال 60 ثانية' : 'Book in 60 Seconds'),
                      (Icons.notifications_outlined,
                          isAr ? 'تذكير قبل الموعد بيوم' : 'Reminder 1 Day Before'),
                      (Icons.group_outlined,
                          isAr ? 'إدارة مواعيد العائلة' : 'Manage Family Appointments'),
                    ].map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          textDirection:
                              isAr ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Icon(item.$1,
                                color: const Color(0xFF2DA8C8), size: 22),
                            const SizedBox(width: 14),
                            Text(
                              item.$2,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
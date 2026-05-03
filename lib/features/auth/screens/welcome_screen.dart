import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/sizes.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/lang_toggle.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: JuhColors.primary,
      body: Column(
        children: [
          // ── Blue hero area ──
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: JuhSizes.md, vertical: JuhSizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const LangToggle(light: true),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(JuhSizes.radiusMd),
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

                    const Spacer(),

                    // Hero text
                    Text(
                      isAr
                          ? 'احجز موعدك في\nدقائق معدودة'
                          : 'Book Your Appointment\nin Minutes',
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: JuhSizes.fontXxl,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: JuhSizes.md),
                    Text(
                      isAr
                          ? 'خدمة حجز المواعيد الإلكترونية لمستشفى الجامعة الأردنية.\nتحقق فوري عبر دائرة الأحوال المدنية.'
                          : 'Electronic appointment booking for Jordan University Hospital.\nInstant verification via the Civil Status Department.',
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: JuhSizes.fontSm,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: JuhSizes.xl),
                  ],
                ),
              ),
            ),
          ),

          // ── White bottom sheet ──
          Container(
            decoration: const BoxDecoration(
              color: JuhColors.bg,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(JuhSizes.radiusXl)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(JuhSizes.md, 28, JuhSizes.md, JuhSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Primary CTA
                    SizedBox(
                      height: JuhSizes.btnHeight,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/signup'),
                        icon: const Icon(Icons.badge_outlined, size: 20),
                        label: Text(
                          isAr ? 'إنشاء حساب جديد' : 'Create Account',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: JuhColors.primaryInk,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(JuhSizes.radiusMd),
                          ),
                          textStyle: const TextStyle(
                            fontSize: JuhSizes.fontBase,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Login
                    SizedBox(
                      height: JuhSizes.btnHeight,
                      child: OutlinedButton(
                        onPressed: () => context.push('/login'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: JuhColors.primary,
                          side: const BorderSide(
                              color: JuhColors.border, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(JuhSizes.radiusMd),
                          ),
                          textStyle: const TextStyle(
                            fontSize: JuhSizes.fontBase,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(isAr ? 'تسجيل الدخول' : 'Sign In'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Features card
                    Container(
                      padding: const EdgeInsets.all(JuhSizes.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(JuhSizes.radiusLg),
                        border: Border.all(color: JuhColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isAr ? 'ما يميز المنصة' : 'Why Choose Us',
                            textAlign:
                                isAr ? TextAlign.right : TextAlign.left,
                            style: const TextStyle(
                              fontSize: JuhSizes.fontBase,
                              fontWeight: FontWeight.w700,
                              color: JuhColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: JuhSizes.md),
                          ...[
                            (Icons.verified_user_outlined,
                                isAr
                                    ? 'تحقق آمن من الهوية'
                                    : 'Secure Identity Verification'),
                            (Icons.timer_outlined,
                                isAr
                                    ? 'حجز خلال 60 ثانية'
                                    : 'Book in 60 Seconds'),
                            (Icons.notifications_outlined,
                                isAr
                                    ? 'تذكير قبل الموعد بيوم'
                                    : 'Reminder 1 Day Before'),
                            (Icons.group_outlined,
                                isAr
                                    ? 'إدارة مواعيد العائلة'
                                    : 'Manage Family Appointments'),
                          ].map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: JuhSizes.md),
                              child: Row(
                                textDirection:
                                    isAr ? TextDirection.rtl : TextDirection.ltr,
                                children: [
                                  Icon(item.$1,
                                      color: JuhColors.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.$2,
                                      style: const TextStyle(
                                        fontSize: JuhSizes.fontSm,
                                        fontWeight: FontWeight.w500,
                                        color: JuhColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

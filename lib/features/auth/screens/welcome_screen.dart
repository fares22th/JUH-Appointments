import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
          // ── Hero area ──
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: JuhSizes.md, vertical: JuhSizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Language toggle
                    Align(
                      alignment: Alignment.topLeft,
                      child: const LangToggle(light: true),
                    ),

                    // Logo + name centered
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/juh_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: JuhSizes.xl),

                          // Arabic name
                          Text(
                            'مستشفى الجامعة الأردنية',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.reemKufi(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // English name
                          Text(
                            'Jordan University Hospital',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.reemKufi(
                              color: Colors.white70,
                              fontSize: JuhSizes.fontBase,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: JuhSizes.sm),

                          // Divider line
                          Container(
                            width: 50,
                            height: 3,
                            decoration: BoxDecoration(
                              color: JuhColors.accent,
                              borderRadius: BorderRadius.circular(2),
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

          // ── Bottom sheet ──
          Container(
            decoration: const BoxDecoration(
              color: JuhColors.bg,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(JuhSizes.radiusXl)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    JuhSizes.md, 32, JuhSizes.md, JuhSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Welcome text
                    Text(
                      isAr ? 'مرحباً بك' : 'Welcome',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: JuhSizes.fontLg,
                        fontWeight: FontWeight.w800,
                        color: JuhColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAr
                          ? 'سجّل دخولك أو أنشئ حساباً للبدء'
                          : 'Sign in or create an account to get started',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: JuhSizes.fontSm,
                        color: JuhColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: JuhSizes.xl),

                    // Sign In — primary
                    SizedBox(
                      height: JuhSizes.btnHeight,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/login'),
                        icon: const Icon(Icons.login_outlined, size: 20),
                        label: Text(isAr ? 'تسجيل الدخول' : 'Sign In'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: JuhColors.primary,
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

                    const SizedBox(height: 12),

                    // Create Account — secondary
                    SizedBox(
                      height: JuhSizes.btnHeight,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/signup'),
                        icon: const Icon(Icons.badge_outlined, size: 20),
                        label: Text(
                            isAr ? 'إنشاء حساب جديد' : 'Create Account'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: JuhColors.primary,
                          side: const BorderSide(
                              color: JuhColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(JuhSizes.radiusMd),
                          ),
                          textStyle: const TextStyle(
                            fontSize: JuhSizes.fontBase,
                            fontWeight: FontWeight.w600,
                          ),
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

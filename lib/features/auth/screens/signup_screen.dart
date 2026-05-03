import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/sizes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../../../shared/widgets/screen_header.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _nationalIdCtrl = TextEditingController();
  final _familyIdCtrl = TextEditingController();
  bool _agreed = false;
  bool _loading = false;

  @override
  void dispose() {
    _nationalIdCtrl.dispose();
    _familyIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (!_agreed) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      ref.read(pendingSignupProvider.notifier).state = PendingSignup(
        nationalId: _nationalIdCtrl.text.trim(),
        civilRecord: _familyIdCtrl.text.trim(),
      );
      setState(() => _loading = false);
      context.push('/contact');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: JuhColors.bg,
      appBar: const ScreenHeader(
        titleAr: 'إنشاء حساب',
        titleEn: 'Create Account',
      ),
      body: Column(
        children: [
          const SegmentBar(step: 0, total: 2), // auth step 1/2
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(JuhSizes.md),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: JuhSizes.md),

                    InfoBanner(
                      icon: Icons.verified_user_outlined,
                      text: isAr
                          ? 'سيتم التحقق من بياناتك تلقائياً مع قاعدة بيانات دائرة الأحوال المدنية والجوازات.'
                          : 'Your data will be automatically verified with the Civil Status and Passports database.',
                    ),
                    const SizedBox(height: JuhSizes.lg),

                    FieldLabel(
                      label: isAr ? 'الرقم الوطني' : 'National ID',
                      required: true,
                      isAr: isAr,
                    ),
                    const SizedBox(height: 6),
                    JuhFormField(
                      controller: _nationalIdCtrl,
                      hint: '9876543210',
                      isAr: isAr,
                      keyboardType: TextInputType.number,
                      helperText: isAr
                          ? 'الرقم الوطني المكون من 10 أرقام'
                          : '10-digit National ID number',
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return isAr
                              ? 'الرقم الوطني مطلوب'
                              : 'National ID is required';
                        }
                        if (v.length < 10) {
                          return isAr ? 'رقم غير صحيح' : 'Invalid ID number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: JuhSizes.lg),

                    FieldLabel(
                      label: isAr ? 'رقم القيد المدني' : 'Civil Record Number',
                      required: true,
                      isAr: isAr,
                    ),
                    const SizedBox(height: 6),
                    JuhFormField(
                      controller: _familyIdCtrl,
                      hint: '45821',
                      isAr: isAr,
                      keyboardType: TextInputType.number,
                      helperText: isAr
                          ? 'الرقم الموجود على دفتر العائلة'
                          : 'Number found on the family booklet',
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return isAr
                              ? 'رقم القيد المدني مطلوب'
                              : 'Civil Record Number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: JuhSizes.lg),

                    // Terms checkbox
                    GestureDetector(
                      onTap: () => setState(() => _agreed = !_agreed),
                      child: Row(
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _agreed ? JuhColors.primary : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(JuhSizes.radiusSm),
                              border: Border.all(
                                color: _agreed
                                    ? JuhColors.primary
                                    : JuhColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: _agreed
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 14)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isAr
                                  ? 'أوافق على الشروط والأحكام وسياسة الخصوصية الخاصة بمستشفى الجامعة الأردنية.'
                                  : 'I agree to the Terms and Conditions and Privacy Policy of Jordan University Hospital.',
                              textAlign:
                                  isAr ? TextAlign.right : TextAlign.left,
                              style: const TextStyle(
                                fontSize: JuhSizes.fontSm,
                                color: JuhColors.textPrimary,
                                height: 1.5,
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

          Container(
            color: JuhColors.bg,
            padding: const EdgeInsets.fromLTRB(
                JuhSizes.md, JuhSizes.sm, JuhSizes.md, JuhSizes.lg),
            child: AppButton(
              label: isAr ? 'إنشاء حساب' : 'Create Account',
              onTap: _agreed ? _submit : null,
              loading: _loading,
            ),
          ),
        ],
      ),
    );
  }
}

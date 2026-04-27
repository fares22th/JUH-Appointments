import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
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
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _loading = false);
      context.push('/contact');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: ScreenHeader(
        titleAr: 'إنشاء حساب',
        titleEn: 'Create Account',
      ),
      body: Column(
        children: [
          // Progress indicator line
          LinearProgressIndicator(
            value: 0.33,
            backgroundColor: const Color(0xFFE0E0E0),
            color: const Color(0xFF2DA8C8),
            minHeight: 3,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(JuhSizes.md),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: JuhSizes.md),

                    // ── Info banner ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2DA8C8).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          const Icon(Icons.verified_user_outlined,
                              color: Color(0xFF2DA8C8), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isAr
                                  ? 'سيتم التحقق من بياناتك تلقائياً مع قاعدة بيانات دائرة الأحوال المدنية والجوازات.'
                                  : 'Your data will be automatically verified with the Civil Status and Passports database.',
                              textAlign:
                                  isAr ? TextAlign.right : TextAlign.left,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1A7A8A),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: JuhSizes.lg),

                    // ── National ID field ──
                    Align(
                      alignment:
                          isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isAr ? 'الرقم الوطني' : 'National ID',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('*',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nationalIdCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF2DA8C8), width: 1.5),
                        ),
                        hintText: isAr ? '9876543210' : '9876543210',
                      ),
                      validator: (v) {
                        if (v?.isEmpty ?? true) {
                          return isAr
                              ? 'الرقم الوطني مطلوب'
                              : 'National ID is required';
                        }
                        if (v!.length < 10) {
                          return isAr ? 'رقم غير صحيح' : 'Invalid ID number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment:
                          isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        isAr
                            ? 'الرقم الوطني المكون من 10 أرقام'
                            : '10-digit National ID number',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888)),
                      ),
                    ),

                    const SizedBox(height: JuhSizes.lg),

                    // ── Family/Civil ID field ──
                    Align(
                      alignment:
                          isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isAr ? 'رقم القيد المدني' : 'Civil Record Number',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('*',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _familyIdCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF2DA8C8), width: 1.5),
                        ),
                        hintText: isAr ? '45821' : '45821',
                      ),
                      validator: (v) {
                        if (v?.isEmpty ?? true) {
                          return isAr
                              ? 'رقم القيد المدني مطلوب'
                              : 'Civil Record Number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment:
                          isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        isAr
                            ? 'الرقم الموجود على دفتر العائلة'
                            : 'Number found on the family booklet',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888)),
                      ),
                    ),

                    const SizedBox(height: JuhSizes.lg),

                    // ── Terms checkbox ──
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
                              color: _agreed
                                  ? const Color(0xFF2DA8C8)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _agreed
                                    ? const Color(0xFF2DA8C8)
                                    : const Color(0xFFCCCCCC),
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
                                  fontSize: 13,
                                  color: Color(0xFF444444),
                                  height: 1.5),
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

          // ── Bottom button ──
          Container(
            color: const Color(0xFFF5F7FA),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: AppButton(
              label: isAr ? 'متابعة' : 'Continue',
              onTap: _agreed ? _submit : null,
              loading: _loading,
            ),
          ),
        ],
      ),
    );
  }
}
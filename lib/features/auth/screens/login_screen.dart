import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nhost_flutter_auth/nhost_flutter_auth.dart';
import '../../../core/colors.dart';
import '../../../core/nhost.dart';
import '../../../core/sizes.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/form_widgets.dart' show FieldLabel, JuhFormField;
import '../../../shared/widgets/screen_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _nationalIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _nationalIdCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final isAr = ref.read(localeProvider).languageCode == 'ar';
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      await nhostClient.auth.signInEmailPassword(
        email: '${_nationalIdCtrl.text.trim()}@juh.app',
        password: _passwordCtrl.text,
      );
      if (mounted) context.go('/login-welcome');
    } on ApiException catch (e) {
      final body = e.responseBody;
      final rawMsg = (body is Map ? body['message'] as String? : null) ?? '';
      final errorCode = (body is Map ? body['error'] as String? : null) ?? '';
      final String msg;
      if (errorCode == 'email-not-verified' ||
          rawMsg.toLowerCase().contains('not verified') ||
          rawMsg.toLowerCase().contains('verify')) {
        msg = isAr
            ? 'الحساب لم يُفعَّل بعد. تحقق من بريدك وافتح رابط التفعيل.'
            : 'Account not verified. Open the verification link sent to your email.';
      } else if (e.statusCode == 401 || e.statusCode == 403) {
        msg = isAr
            ? 'الرقم الوطني أو كلمة المرور غير صحيحة.'
            : 'Incorrect National ID or password.';
      } else {
        msg = rawMsg.isNotEmpty
            ? rawMsg
            : (isAr ? 'تعذّر تسجيل الدخول.' : 'Sign in failed.');
      }
      setState(() => _errorMsg = msg);
    } catch (_) {
      final isAr = ref.read(localeProvider).languageCode == 'ar';
      setState(() => _errorMsg = isAr
          ? 'حدث خطأ. تحقق من الاتصال وأعد المحاولة.'
          : 'An error occurred. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: JuhColors.bg,
      appBar: const ScreenHeader(
        titleAr: 'تسجيل الدخول',
        titleEn: 'Sign In',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(JuhSizes.md),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: JuhSizes.md),

                    // Notice box — matches JUH platform
                    Container(
                      padding: const EdgeInsets.all(JuhSizes.md),
                      decoration: BoxDecoration(
                        color: JuhColors.primary,
                        borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isAr
                                ? 'يُفضَّل استخدام رقم وثيقة الهوية الشخصية بدلاً من رقم القيد، للكبار الذين لديهم هوية شخصية، وذلك لأن رقم القيد يتغير بتغيير الحالة الاجتماعية مثل الزواج.'
                                : 'It is preferred to use the Personal ID number instead of the registration number for adults who have a personal ID, as the registration number changes with changes in civil status such as marriage.',
                            textAlign: isAr ? TextAlign.right : TextAlign.left,
                            style: const TextStyle(
                              color: Color(0xFFFFD54F),
                              fontSize: JuhSizes.fontSm,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: JuhSizes.sm),
                          Text(
                            isAr
                                ? 'الذين لا يوجد لديهم هوية شخصية يمكنهم استخدام رقم القيد للدخول.'
                                : 'Those without a personal ID can use their registration number to log in.',
                            textAlign: isAr ? TextAlign.right : TextAlign.left,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: JuhSizes.fontSm,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
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
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return isAr
                              ? 'الرقم الوطني مطلوب'
                              : 'National ID is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: JuhSizes.lg),

                    FieldLabel(
                      label: isAr ? 'كلمة المرور' : 'Password',
                      required: true,
                      isAr: isAr,
                    ),
                    const SizedBox(height: 6),
                    JuhFormField(
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      isAr: isAr,
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return isAr
                              ? 'كلمة المرور مطلوبة'
                              : 'Password is required';
                        }
                        return null;
                      },
                    ),

                    if (_errorMsg != null) ...[
                      const SizedBox(height: JuhSizes.md),
                      Container(
                        padding: const EdgeInsets.all(JuhSizes.sm),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F0),
                          borderRadius:
                              BorderRadius.circular(JuhSizes.radiusMd),
                          border:
                              Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection:
                              isAr ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFD32F2F), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMsg!,
                                textAlign:
                                    isAr ? TextAlign.right : TextAlign.left,
                                style: const TextStyle(
                                  fontSize: JuhSizes.fontSm,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: JuhSizes.lg),

                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: InkWell(
                        onTap: () => context.push('/signup'),
                        borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
                        splashColor: JuhColors.primary.withValues(alpha: 0.15),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text(
                            isAr
                                ? 'ليس لديك حساب؟ إنشاء حساب جديد'
                                : 'No account? Create one',
                            style: const TextStyle(
                              fontSize: JuhSizes.fontSm,
                              color: JuhColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
              label: isAr ? 'تسجيل الدخول' : 'Sign In',
              onTap: _submit,
              loading: _loading,
            ),
          ),
        ],
      ),
    );
  }
}

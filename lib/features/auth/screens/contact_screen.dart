import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nhost_flutter_auth/nhost_flutter_auth.dart';
import '../../../core/colors.dart';
import '../../../core/nhost.dart';
import '../../../core/sizes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../../../shared/widgets/screen_header.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _smsEnabled = true;
  bool _emailReminderEnabled = true;
  bool _loading = false;
  String? _errorMsg;
  bool _isSuccess = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final pending = ref.read(pendingSignupProvider);
    final isAr = ref.read(localeProvider).languageCode == 'ar';
    if (pending == null) {
      context.go('/signup');
      return;
    }
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      final nhostEmail = '${pending.nationalId}@juh.app';
      final result = await nhostClient.auth.signUp(
        email: nhostEmail,
        password: _passwordCtrl.text,
        displayName: _nameCtrl.text.trim(),
        metadata: {
          'nationalId': pending.nationalId,
          'civilRecord': pending.civilRecord,
          'phone': _phoneCtrl.text.trim(),
          'contactEmail': _emailCtrl.text.trim(),
          'smsReminder': _smsEnabled,
          'emailReminder': _emailReminderEnabled,
        },
      );
      ref.read(pendingSignupProvider.notifier).state = null;
      if (result.session != null) {
        await nhostClient.auth.signOut();
      }
      if (!mounted) return;
      context.go('/login');
    } on ApiException catch (e) {
      final body = e.responseBody;
      final msg = (body is Map ? body['message'] as String? : null);
      final code = (body is Map ? body['error'] as String? : null);
      setState(() {
        _isSuccess = false;
        _errorMsg = _friendlyError(msg, code, e.statusCode, isAr);
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _errorMsg = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String? msg, String? code, int statusCode, bool isAr) {
    final m = msg?.toLowerCase() ?? '';
    if (m.contains('already') || m.contains('exists') ||
        code == 'email-already-in-use' || statusCode == 409) {
      return isAr
          ? 'هذا الرقم الوطني مسجّل مسبقاً. جرّب تسجيل الدخول.'
          : 'This National ID is already registered. Try signing in.';
    }
    // Show the raw Nhost message so we can diagnose unexpected errors
    if (msg != null && msg.isNotEmpty) return msg;
    return isAr
        ? 'تعذّر إنشاء الحساب ($statusCode). تحقق من البيانات.'
        : 'Could not create account ($statusCode). Check your details.';
  }

  Widget _sectionLabel(String text, bool isAr) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: JuhSizes.fontSm,
            fontWeight: FontWeight.w700,
            color: JuhColors.textSecondary,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: JuhColors.bg,
      appBar: const ScreenHeader(
        titleAr: 'بيانات الحساب',
        titleEn: 'Account Details',
      ),
      body: Column(
        children: [
          const SegmentBar(step: 1, total: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(JuhSizes.md),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: JuhSizes.md),

                    // ── Personal info ──────────────────────────────────
                    _sectionLabel(
                        isAr ? 'المعلومات الشخصية' : 'Personal Info', isAr),
                    const SizedBox(height: 10),

                    FieldLabel(
                        label: isAr ? 'الاسم الكامل' : 'Full Name',
                        required: true,
                        isAr: isAr),
                    const SizedBox(height: 6),
                    JuhFormField(
                      controller: _nameCtrl,
                      hint: isAr ? 'أحمد عبدالله العلي' : 'Ahmad Al-Ali',
                      isAr: isAr,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return isAr ? 'الاسم مطلوب' : 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: JuhSizes.lg),

                    // ── Contact ────────────────────────────────────────
                    _sectionLabel(
                        isAr ? 'بيانات التواصل' : 'Contact Details', isAr),
                    const SizedBox(height: 10),

                    FieldLabel(
                        label: isAr ? 'رقم الجوال' : 'Mobile Number',
                        required: true,
                        isAr: isAr),
                    const SizedBox(height: 6),
                    JuhFormField(
                      controller: _phoneCtrl,
                      hint: '0791234567',
                      isAr: isAr,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return isAr ? 'رقم الجوال مطلوب' : 'Phone required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: JuhSizes.md),

                    FieldLabel(
                        label: isAr ? 'البريد الإلكتروني' : 'Email Address',
                        required: true,
                        isAr: isAr),
                    const SizedBox(height: 6),
                    JuhFormField(
                      controller: _emailCtrl,
                      hint: 'a.alali@example.jo',
                      isAr: isAr,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return isAr ? 'البريد مطلوب' : 'Email required';
                        }
                        if (!v.contains('@')) {
                          return isAr ? 'بريد غير صحيح' : 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: JuhSizes.lg),

                    // ── Password ───────────────────────────────────────
                    _sectionLabel(
                        isAr ? 'كلمة المرور' : 'Password', isAr),
                    const SizedBox(height: 10),

                    FieldLabel(
                        label: isAr ? 'كلمة المرور' : 'Password',
                        required: true,
                        isAr: isAr),
                    const SizedBox(height: 6),
                    JuhFormField(
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      isAr: isAr,
                      obscureText: true,
                      helperText: isAr
                          ? 'لا تقل عن 8 أحرف'
                          : 'At least 8 characters',
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return isAr
                              ? 'كلمة المرور مطلوبة'
                              : 'Password required';
                        }
                        if (v.length < 8) {
                          return isAr
                              ? 'كلمة المرور قصيرة جداً'
                              : 'Password too short';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: JuhSizes.md),

                    FieldLabel(
                        label: isAr ? 'تأكيد كلمة المرور' : 'Confirm Password',
                        required: true,
                        isAr: isAr),
                    const SizedBox(height: 6),
                    JuhFormField(
                      controller: _confirmCtrl,
                      hint: '••••••••',
                      isAr: isAr,
                      obscureText: true,
                      validator: (v) {
                        if (v != _passwordCtrl.text) {
                          return isAr
                              ? 'كلمتا المرور غير متطابقتين'
                              : 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: JuhSizes.lg),

                    // ── Reminders ──────────────────────────────────────
                    _sectionLabel(isAr ? 'التذكيرات' : 'Reminders', isAr),
                    const SizedBox(height: 10),

                    _ReminderTile(
                      isAr: isAr,
                      icon: Icons.phone_outlined,
                      label: isAr
                          ? 'رسالة نصية قبل الموعد بيوم'
                          : 'SMS reminder 1 day before',
                      value: _smsEnabled,
                      onChanged: (v) => setState(() => _smsEnabled = v),
                    ),
                    const SizedBox(height: 10),
                    _ReminderTile(
                      isAr: isAr,
                      icon: Icons.email_outlined,
                      label: isAr
                          ? 'بريد تأكيد + بريد تذكير'
                          : 'Confirmation + reminder email',
                      value: _emailReminderEnabled,
                      onChanged: (v) =>
                          setState(() => _emailReminderEnabled = v),
                    ),

                    // ── Error / success banner ─────────────────────────
                    if (_errorMsg != null) ...[
                      const SizedBox(height: JuhSizes.md),
                      Container(
                        padding: const EdgeInsets.all(JuhSizes.sm),
                        decoration: BoxDecoration(
                          color: _isSuccess
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF0F0),
                          borderRadius:
                              BorderRadius.circular(JuhSizes.radiusMd),
                          border: Border.all(
                            color: _isSuccess
                                ? const Color(0xFFA5D6A7)
                                : const Color(0xFFFFCDD2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection:
                              isAr ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Icon(
                              _isSuccess
                                  ? Icons.mark_email_unread_outlined
                                  : Icons.error_outline,
                              color: _isSuccess
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFD32F2F),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMsg!,
                                textAlign:
                                    isAr ? TextAlign.right : TextAlign.left,
                                style: TextStyle(
                                  fontSize: JuhSizes.fontSm,
                                  color: _isSuccess
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFD32F2F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: JuhSizes.xl),
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
              label: isAr ? 'إنشاء الحساب' : 'Create Account',
              onTap: _submit,
              loading: _loading,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final bool isAr;
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ReminderTile({
    required this.isAr,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: JuhSizes.md, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
        border: Border.all(color: JuhColors.border),
      ),
      child: Row(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: JuhColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: JuhColors.border,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: JuhSizes.sm),
          Expanded(
            child: Text(
              label,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                fontSize: JuhSizes.fontSm,
                fontWeight: FontWeight.w500,
                color: JuhColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: JuhSizes.sm),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuhColors.primarySoft,
              borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
            ),
            child: Icon(icon, color: JuhColors.primary, size: 18),
          ),
        ],
      ),
    );
  }
}

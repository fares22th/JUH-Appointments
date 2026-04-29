import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/sizes.dart';
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
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _smsEnabled = true;
  bool _emailReminderEnabled = true;
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _loading = false);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: JuhColors.bg,
      appBar: const ScreenHeader(
        titleAr: 'بيانات التواصل',
        titleEn: 'Contact Details',
      ),
      body: Column(
        children: [
          const SegmentBar(step: 1, total: 2), // auth step 2/2
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(JuhSizes.md),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: JuhSizes.md),

                    // Identity verified card
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: JuhSizes.md, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(JuhSizes.radiusMd),
                        border: Border.all(color: JuhColors.border),
                      ),
                      child: Row(
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isAr
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr
                                      ? 'أحمد عبدالله العلي'
                                      : 'Ahmad Abdullah Al-Ali',
                                  style: const TextStyle(
                                    fontSize: JuhSizes.fontBase,
                                    fontWeight: FontWeight.w700,
                                    color: JuhColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isAr
                                      ? 'تم التحقق من الهوية بنجاح'
                                      : 'Identity verified successfully',
                                  style: const TextStyle(
                                    fontSize: JuhSizes.fontSm,
                                    color: JuhColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: JuhSizes.sm),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: JuhColors.successSoft,
                              borderRadius: BorderRadius.circular(
                                  JuhSizes.radiusFull),
                            ),
                            child: const Icon(Icons.check,
                                color: JuhColors.success, size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: JuhSizes.lg),

                    // Section label
                    Align(
                      alignment: isAr
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        isAr ? 'وسائل التواصل' : 'Contact Methods',
                        style: const TextStyle(
                          fontSize: JuhSizes.fontSm,
                          fontWeight: FontWeight.w600,
                          color: JuhColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    FieldLabel(
                      label: isAr ? 'رقم الهاتف المحمول' : 'Mobile Number',
                      required: true,
                      isAr: isAr,
                    ),
                    const SizedBox(height: 6),
                    JuhFormField(
                      controller: _phoneCtrl,
                      hint: '0791234567',
                      isAr: isAr,
                      keyboardType: TextInputType.phone,
                      helperText: isAr
                          ? 'سيتم استخدامه لإرسال رسالة تأكيد الموعد'
                          : 'Used to send appointment confirmation',
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return isAr
                              ? 'رقم الهاتف مطلوب'
                              : 'Phone is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: JuhSizes.md),

                    FieldLabel(
                      label: isAr ? 'البريد الإلكتروني' : 'Email Address',
                      required: true,
                      isAr: isAr,
                    ),
                    const SizedBox(height: 6),
                    JuhFormField(
                      controller: _emailCtrl,
                      hint: 'a.alali@example.jo',
                      isAr: isAr,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return isAr ? 'البريد مطلوب' : 'Email is required';
                        }
                        if (!v.contains('@')) {
                          return isAr ? 'بريد غير صحيح' : 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: JuhSizes.lg),

                    // Reminders section
                    Align(
                      alignment: isAr
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        isAr ? 'التذكيرات' : 'Reminders',
                        style: const TextStyle(
                          fontSize: JuhSizes.fontSm,
                          fontWeight: FontWeight.w600,
                          color: JuhColors.textSecondary,
                        ),
                      ),
                    ),
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
              label: isAr ? 'حفظ ومتابعة' : 'Save & Continue',
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
      padding: const EdgeInsets.symmetric(
          horizontal: JuhSizes.md, vertical: 12),
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

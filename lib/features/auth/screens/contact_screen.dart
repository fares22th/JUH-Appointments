import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
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
  bool _smsSmsEnabled = true;
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: ScreenHeader(
        titleAr: 'بيانات التواصل',
        titleEn: 'Contact Info',
      ),
      body: Column(
        children: [
          // Progress bar – step 2 of 3
          LinearProgressIndicator(
            value: 0.66,
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

                    // ── Identity verified card ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
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
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isAr
                                      ? 'تم التحقق من الهوية بنجاح'
                                      : 'Identity verified successfully',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF888888),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2DA8C8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: JuhSizes.lg),

                    // ── Section label: contact ──
                    Align(
                      alignment:
                          isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        isAr ? 'وسائل التواصل' : 'Contact Methods',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Phone field ──
                    Align(
                      alignment:
                          isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          const Text('*',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          Text(
                            isAr ? 'رقم الهاتف المحمول' : 'Mobile Number',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '0791234567',
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
                      ),
                      validator: (v) {
                        if (v?.isEmpty ?? true) {
                          return isAr
                              ? 'رقم الهاتف مطلوب'
                              : 'Phone is required';
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
                            ? 'سيتم استخدامه لإرسال رسالة تأكيد الموعد'
                            : 'Used to send appointment confirmation',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888)),
                      ),
                    ),

                    const SizedBox(height: JuhSizes.md),

                    // ── Email field ──
                    Align(
                      alignment:
                          isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          const Text('*',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          Text(
                            isAr ? 'البريد الإلكتروني' : 'Email Address',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'a.alali@example.jo',
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
                      ),
                      validator: (v) {
                        if (v?.isEmpty ?? true) {
                          return isAr ? 'البريد مطلوب' : 'Email is required';
                        }
                        if (!v!.contains('@')) {
                          return isAr ? 'بريد غير صحيح' : 'Invalid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: JuhSizes.lg),

                    // ── Reminders section ──
                    Align(
                      alignment:
                          isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        isAr ? 'التذكيرات' : 'Reminders',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // SMS reminder toggle
                    _ReminderTile(
                      isAr: isAr,
                      icon: Icons.phone_outlined,
                      label: isAr
                          ? 'رسالة نصية قبل الموعد بيوم'
                          : 'SMS reminder 1 day before',
                      value: _smsSmsEnabled,
                      onChanged: (v) => setState(() => _smsSmsEnabled = v),
                    ),
                    const SizedBox(height: 10),

                    // Email reminder toggle
                    _ReminderTile(
                      isAr: isAr,
                      icon: Icons.email_outlined,
                      label:
                          isAr ? 'بريد تأكيد + بريد تذكير' : 'Confirmation + reminder email',
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

          // ── Bottom button ──
          Container(
            color: const Color(0xFFF5F7FA),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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

// ── Reusable reminder toggle tile ──
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF2DA8C8),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFCCCCCC),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2DA8C8), size: 18),
          ),
        ],
      ),
    );
  }
}
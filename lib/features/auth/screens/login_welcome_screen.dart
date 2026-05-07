import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../core/colors.dart';
import '../../../core/nhost.dart';
import '../../../core/sizes.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';

class LoginWelcomeScreen extends ConsumerStatefulWidget {
  const LoginWelcomeScreen({super.key});

  @override
  ConsumerState<LoginWelcomeScreen> createState() => _LoginWelcomeScreenState();
}

class _LoginWelcomeScreenState extends ConsumerState<LoginWelcomeScreen> {
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  bool _editPhone = false;
  bool _editEmail = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final meta = nhostClient.auth.currentUser?.metadata ?? {};
    _phoneCtrl = TextEditingController(text: meta['phone'] as String? ?? '');
    _emailCtrl = TextEditingController(text: meta['contactEmail'] as String? ?? '');
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveField() async {
    final token = nhostClient.auth.accessToken;
    final userId = nhostClient.auth.currentUser?.id;
    if (token == null || userId == null) return;

    setState(() => _saving = true);
    try {
      final response = await http.post(
        Uri.parse(
            'https://hdlupyawqibeobhzjlhm.hasura.eu-central-1.nhost.run/v1/graphql'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'query': r'''
            mutation UpdateContactInfo($id: uuid!, $phone: String, $contactEmail: String) {
              update_profiles_by_pk(
                pk_columns: {id: $id}
                _set: {phone: $phone, contact_email: $contactEmail}
              ) { id }
            }
          ''',
          'variables': {
            'id': userId,
            'phone': _phoneCtrl.text.trim(),
            'contactEmail': _emailCtrl.text.trim(),
          },
        }),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body.containsKey('errors') && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text((body['errors'] as List).first['message'])),
        );
        return;
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    setState(() {
      _editPhone = false;
      _editEmail = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final user = nhostClient.auth.currentUser;
    final meta = user?.metadata ?? {};

    final name = (user?.displayName.isNotEmpty == true)
        ? user!.displayName
        : (isAr ? 'مستخدم' : 'User');
    final nationalId = (meta['nationalId'] as String?) ?? '—';

    final bool hasEdits = _editPhone || _editEmail;

    return Scaffold(
      backgroundColor: JuhColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(JuhSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // ── Avatar ──────────────────────────────────────────────
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: JuhColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: JuhColors.primary,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: JuhSizes.md),

              Text(
                isAr ? 'مرحباً بك!' : 'Welcome back!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: JuhSizes.fontXxl,
                  fontWeight: FontWeight.w800,
                  color: JuhColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isAr ? 'تم تسجيل الدخول بنجاح' : 'You have signed in successfully',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: JuhSizes.fontSm,
                  color: JuhColors.textSecondary,
                ),
              ),

              const SizedBox(height: JuhSizes.xl),

              // ── Info card ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(JuhSizes.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(JuhSizes.radiusXl),
                  border: Border.all(color: JuhColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _StaticRow(
                      isAr: isAr,
                      icon: Icons.person_outline,
                      label: isAr ? 'الاسم' : 'Name',
                      value: name,
                    ),
                    const _RowDivider(),
                    _StaticRow(
                      isAr: isAr,
                      icon: Icons.badge_outlined,
                      label: isAr ? 'الرقم الوطني' : 'National ID',
                      value: nationalId,
                    ),
                    const _RowDivider(),

                    // ── Editable: phone ──────────────────────────────
                    _EditableRow(
                      isAr: isAr,
                      icon: Icons.phone_outlined,
                      label: isAr ? 'الجوال' : 'Phone',
                      controller: _phoneCtrl,
                      isEditing: _editPhone,
                      keyboardType: TextInputType.phone,
                      onEdit: () => setState(() {
                        _editPhone = true;
                        _editEmail = false;
                      }),
                      onCancel: () => setState(() => _editPhone = false),
                    ),
                    const _RowDivider(),

                    // ── Editable: email ──────────────────────────────
                    _EditableRow(
                      isAr: isAr,
                      icon: Icons.email_outlined,
                      label: isAr ? 'البريد الإلكتروني' : 'Email',
                      controller: _emailCtrl,
                      isEditing: _editEmail,
                      keyboardType: TextInputType.emailAddress,
                      onEdit: () => setState(() {
                        _editEmail = true;
                        _editPhone = false;
                      }),
                      onCancel: () => setState(() => _editEmail = false),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: JuhSizes.md),

              // ── Note banner ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: JuhSizes.md, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFFF9A825), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'الرجاء التأكد من معلومات التواصل، حيث سيتم إرسال رسائل نصية للتذكير بالموعد قبله بيوم.'
                            : 'Please verify your contact info. SMS reminders will be sent one day before your appointment.',
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          fontSize: JuhSizes.fontXs,
                          color: Color(0xFF795548),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Buttons ──────────────────────────────────────────────
              if (hasEdits) ...[
                AppButton(
                  label: isAr ? 'حفظ التعديلات' : 'Save Changes',
                  onTap: _saveField,
                  loading: _saving,
                ),
                const SizedBox(height: JuhSizes.sm),
                AppButton.outline(
                  label: isAr ? 'الاستمرار للرئيسية' : 'Continue to Home',
                  onTap: () => context.go('/home'),
                ),
              ] else ...[
                AppButton(
                  label: isAr ? 'الاستمرار للرئيسية' : 'Continue to Home',
                  onTap: () => context.go('/home'),
                ),
              ],
              const SizedBox(height: JuhSizes.sm),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Static info row ───────────────────────────────────────────────────────────

class _StaticRow extends StatelessWidget {
  final bool isAr;
  final IconData icon;
  final String label;
  final String value;

  const _StaticRow({
    required this.isAr,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuhColors.primarySoft,
              borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
            ),
            child: Icon(icon, color: JuhColors.primary, size: 18),
          ),
          const SizedBox(width: JuhSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: JuhSizes.fontXs,
                        color: JuhColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: JuhSizes.fontSm,
                        fontWeight: FontWeight.w600,
                        color: JuhColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Editable info row ─────────────────────────────────────────────────────────

class _EditableRow extends StatelessWidget {
  final bool isAr;
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final TextInputType keyboardType;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const _EditableRow({
    required this.isAr,
    required this.icon,
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.keyboardType,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEditing
                  ? JuhColors.primary.withValues(alpha: 0.12)
                  : JuhColors.primarySoft,
              borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
            ),
            child: Icon(icon,
                color: isEditing ? JuhColors.primary : JuhColors.primary,
                size: 18),
          ),
          const SizedBox(width: JuhSizes.sm),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: JuhSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      color: JuhColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(JuhSizes.radiusSm),
                        borderSide:
                            const BorderSide(color: JuhColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(JuhSizes.radiusSm),
                        borderSide: const BorderSide(
                            color: JuhColors.primary, width: 1.5),
                      ),
                      labelText: label,
                      labelStyle: const TextStyle(
                          fontSize: JuhSizes.fontXs,
                          color: JuhColors.textSecondary),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontSize: JuhSizes.fontXs,
                              color: JuhColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        controller.text.isEmpty ? '—' : controller.text,
                        style: const TextStyle(
                            fontSize: JuhSizes.fontSm,
                            fontWeight: FontWeight.w600,
                            color: JuhColors.textPrimary),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 4),
          if (isEditing)
            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close, size: 20, color: JuhColors.textSecondary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            )
          else
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18, color: JuhColors.primary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: label,
            ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: JuhColors.border);
}

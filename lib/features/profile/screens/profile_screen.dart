import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/nhost.dart';
import '../../../core/sizes.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../../../shared/widgets/screen_header.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _editingContact = false;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _phoneCtrl = TextEditingController(text: profile.phone);
    _emailCtrl = TextEditingController(text: profile.email);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(profileProvider.notifier).update(
          phone: _phoneCtrl.text,
          email: _emailCtrl.text,
        );
    setState(() => _editingContact = false);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final profile = ref.watch(profileProvider);
    final relatives = ref.watch(relativesProvider);
    final cs = Theme.of(context).colorScheme;

    final name = isAr ? profile.nameAr : profile.nameEn;
    final initial = name[0];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const ScreenHeader(
        titleAr: 'بياناتي',
        titleEn: 'My Profile',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(JuhSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Profile card ──
            Container(
              padding: const EdgeInsets.all(JuhSizes.md),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: JuhColors.primary,
                      borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: JuhSizes.sm),

                  Text(
                    name,
                    style: TextStyle(
                      fontSize: JuhSizes.fontLg,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Verified chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: JuhColors.successSoft,
                      borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified,
                            color: JuhColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          isAr ? 'موثّق' : 'Verified',
                          style: const TextStyle(
                            color: JuhColors.success,
                            fontSize: JuhSizes.fontXs,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    profile.nationalId,
                    style: TextStyle(
                        fontSize: JuhSizes.fontXs, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuhSizes.lg),

            // ── Contact section ──
            _SectionHeader(
              isAr: isAr,
              title: isAr ? 'بيانات التواصل' : 'Contact Details',
              action: !_editingContact
                  ? InkWell(
                      onTap: () => setState(() => _editingContact = true),
                      borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
                      splashColor: JuhColors.primary.withValues(alpha: 0.15),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          isAr ? 'تعديل' : 'Edit',
                          style: const TextStyle(
                            color: JuhColors.primary,
                            fontSize: JuhSizes.fontSm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 10),

            if (_editingContact) ...[
              FieldLabel(label: isAr ? 'رقم الجوال' : 'Phone', isAr: isAr),
              const SizedBox(height: 6),
              JuhFormField(
                controller: _phoneCtrl,
                hint: '+962 79 123 4567',
                isAr: isAr,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: JuhSizes.md),
              FieldLabel(
                  label: isAr ? 'البريد الإلكتروني' : 'Email', isAr: isAr),
              const SizedBox(height: 6),
              JuhFormField(
                controller: _emailCtrl,
                hint: 'user@example.com',
                isAr: isAr,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: JuhSizes.md),
              Row(
                children: [
                  Expanded(
                      child: AppButton(
                          label: isAr ? 'حفظ' : 'Save', onTap: _save)),
                  const SizedBox(width: JuhSizes.sm),
                  Expanded(
                      child: AppButton.outline(
                          label: isAr ? 'إلغاء' : 'Cancel',
                          onTap: () =>
                              setState(() => _editingContact = false))),
                ],
              ),
            ] else ...[
              _ContactCard(
                isAr: isAr,
                rows: [
                  (
                    Icons.phone_outlined,
                    isAr ? 'الجوال' : 'Phone',
                    profile.phone
                  ),
                  (
                    Icons.email_outlined,
                    isAr ? 'البريد' : 'Email',
                    profile.email
                  ),
                  (
                    Icons.badge_outlined,
                    isAr ? 'الرقم الوطني' : 'National ID',
                    profile.nationalId
                  ),
                ],
              ),
            ],

            const SizedBox(height: JuhSizes.lg),

            // ── Relatives section ──
            _SectionHeader(
              isAr: isAr,
              title: isAr
                  ? 'الأقارب (${relatives.length})'
                  : 'Relatives (${relatives.length})',
              action: InkWell(
                onTap: () => context.push('/relatives'),
                borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
                splashColor: JuhColors.primary.withValues(alpha: 0.15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    isAr ? 'إدارة' : 'Manage',
                    style: const TextStyle(
                      color: JuhColors.primary,
                      fontSize: JuhSizes.fontSm,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: relatives.asMap().entries.map((e) {
                  final i = e.key;
                  final r = e.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: JuhSizes.md, vertical: 12),
                        child: Row(
                          textDirection:
                              isAr ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: JuhColors.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  (isAr ? r.nameAr : r.nameEn)[0],
                                  style: const TextStyle(
                                    color: JuhColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: JuhSizes.fontSm,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: JuhSizes.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: isAr
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? r.nameAr : r.nameEn,
                                    style: TextStyle(
                                      fontSize: JuhSizes.fontSm,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '${r.relationLabel(isAr)} • ${r.nationalId}',
                                    style: TextStyle(
                                      fontSize: JuhSizes.fontXs,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < relatives.length - 1)
                        Divider(height: 1, color: cs.outlineVariant),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: JuhSizes.lg),
            AppButton.outline(
              label: isAr ? 'تسجيل الخروج' : 'Sign Out',
              onTap: () async {
                await nhostClient.auth.signOut();
                if (context.mounted) context.go('/welcome');
              },
              icon: Icons.logout,
            ),
            const SizedBox(height: JuhSizes.md),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final bool isAr;
  final String title;
  final Widget? action;
  const _SectionHeader({required this.isAr, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: JuhSizes.fontSm,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final bool isAr;
  final List<(IconData, String, String)> rows;
  const _ContactCard({required this.isAr, required this.rows});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: JuhSizes.md, vertical: 12),
                child: Row(
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: JuhColors.primarySoft,
                        borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
                      ),
                      child: Icon(row.$1,
                          color: JuhColors.primary, size: JuhSizes.iconMd),
                    ),
                    const SizedBox(width: JuhSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isAr
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.$2,
                            style: TextStyle(
                              fontSize: JuhSizes.fontXs,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            row.$3,
                            style: TextStyle(
                              fontSize: JuhSizes.fontSm,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                Divider(height: 1, color: cs.outlineVariant),
            ],
          );
        }).toList(),
      ),
    );
  }
}

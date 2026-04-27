import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/screen_header.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _editing = false;
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
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final profile = ref.watch(profileProvider);
    final relatives = ref.watch(relativesProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: ScreenHeader(
        titleAr: 'بياناتي',
        titleEn: 'My Profile',
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(JuhSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: JuhColors.primary,
                    child: Text(
                      (isAr ? profile.nameAr : profile.nameEn)[0],
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: JuhSizes.sm),
                  Text(isAr ? profile.nameAr : profile.nameEn, style: context.tt.headlineSmall),
                  Text(profile.nationalId, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: JuhSizes.lg),

            // Editable fields
            if (_editing) ...[
              Text(isAr ? 'تعديل بيانات التواصل' : 'Edit Contact Info', style: context.tt.titleSmall),
              const SizedBox(height: JuhSizes.sm),
              TextFormField(
                controller: _phoneCtrl,
                decoration: InputDecoration(
                  labelText: isAr ? 'رقم الجوال' : 'Phone',
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: JuhSizes.md),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: isAr ? 'البريد الإلكتروني' : 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: JuhSizes.md),
              Row(
                children: [
                  Expanded(child: AppButton(label: isAr ? 'حفظ' : 'Save', onTap: _save)),
                  const SizedBox(width: JuhSizes.sm),
                  Expanded(child: AppButton.outline(label: isAr ? 'إلغاء' : 'Cancel', onTap: () => setState(() => _editing = false))),
                ],
              ),
            ] else ...[
              _InfoCard(rows: [
                (Icons.phone_outlined, isAr ? 'رقم الجوال' : 'Phone', profile.phone),
                (Icons.email_outlined, isAr ? 'البريد الإلكتروني' : 'Email', profile.email),
                (Icons.badge_outlined, isAr ? 'الرقم الوطني' : 'National ID', profile.nationalId),
              ]),
            ],

            const SizedBox(height: JuhSizes.lg),

            // Settings
            Text(isAr ? 'الإعدادات' : 'Settings', style: context.tt.titleSmall),
            const SizedBox(height: JuhSizes.sm),
            _SettingCard(children: [
              SwitchListTile(
                value: isDark,
                onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                title: Text(isAr ? 'الوضع الليلي' : 'Dark Mode'),
                secondary: const Icon(Icons.dark_mode_outlined),
                activeColor: JuhColors.primary,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: Text(isAr ? 'أفراد الأسرة (${relatives.length})' : 'Family Members (${relatives.length})'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(isAr ? 'الرسائل والتذكيرات' : 'Email & Reminders'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/email'),
              ),
            ]),
            const SizedBox(height: JuhSizes.lg),
            AppButton.outline(
              label: isAr ? 'تسجيل الخروج' : 'Sign Out',
              onTap: () => context.go('/'),
              icon: Icons.logout,
            ),
            const SizedBox(height: JuhSizes.md),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<(IconData, String, String)> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border.all(color: context.cs.outline),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final row = e.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(row.$1, color: JuhColors.primary),
                title: Text(row.$2, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
                subtitle: Text(row.$3, style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              ),
              if (e.key < rows.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
        border: Border.all(color: context.cs.outline),
      ),
      child: Column(children: children),
    );
  }
}

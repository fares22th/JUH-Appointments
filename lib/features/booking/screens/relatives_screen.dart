import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/sizes.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../../../shared/widgets/screen_header.dart';

class RelativesScreen extends ConsumerWidget {
  final String preselectedWho;
  const RelativesScreen({super.key, this.preselectedWho = 'self'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final profile = ref.watch(profileProvider);
    final relatives = ref.watch(relativesProvider);

    final otherRelatives = relatives.where((r) => r.id != 'self').toList();
    final selfNationalId = relatives
        .firstWhere((r) => r.id == 'self',
            orElse: () => relatives.first)
        .nationalId;

    return Scaffold(
      backgroundColor: JuhColors.bg,
      appBar: const ScreenHeader(
        titleAr: 'من سيكون المريض؟',
        titleEn: 'Who is the patient?',
      ),
      body: ListView(
        padding: const EdgeInsets.all(JuhSizes.md),
        children: [
          InfoBanner(
            icon: Icons.people_outline,
            text: isAr
                ? 'يمكنك الحجز لنفسك أو لأحد أقاربك الذين تم إضافتهم إلى حسابك.'
                : 'You can book for yourself or for a relative added to your account.',
          ),
          const SizedBox(height: JuhSizes.md),

          _PersonCard(
            isAr: isAr,
            avatarLetter: (isAr ? profile.nameAr : profile.nameEn)[0],
            name: isAr
                ? '${profile.nameAr} (أنت)'
                : '${profile.nameEn} (You)',
            subtitle: selfNationalId,
            onTap: () => context.push('/booking?who=self'),
          ),

          if (otherRelatives.isNotEmpty) ...[
            const SizedBox(height: JuhSizes.lg),
            Align(
              alignment:
                  isAr ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                isAr ? 'الأقارب' : 'Relatives',
                style: const TextStyle(
                  fontSize: JuhSizes.fontSm,
                  fontWeight: FontWeight.w600,
                  color: JuhColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...otherRelatives.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: JuhSizes.sm),
                child: _PersonCard(
                  isAr: isAr,
                  avatarLetter: (isAr ? r.nameAr : r.nameEn)[0],
                  name: isAr ? r.nameAr : r.nameEn,
                  subtitle: '${r.relationLabel(isAr)} • ${r.nationalId}',
                  onTap: () => context.push('/booking?who=${r.id}'),
                ),
              ),
            ),
          ],

          const SizedBox(height: JuhSizes.sm),
          _AddRelativeRow(isAr: isAr),
          const SizedBox(height: JuhSizes.lg),
        ],
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final bool isAr;
  final String avatarLetter;
  final String name;
  final String subtitle;
  final VoidCallback onTap;

  const _PersonCard({
    required this.isAr,
    required this.avatarLetter,
    required this.name,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          border: Border.all(color: JuhColors.border),
        ),
        child: Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: JuhColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  avatarLetter,
                  style: const TextStyle(
                    color: JuhColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: JuhSizes.fontMd,
                  ),
                ),
              ),
            ),
            const SizedBox(width: JuhSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: isAr
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: JuhSizes.fontBase,
                      fontWeight: FontWeight.w700,
                      color: JuhColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: JuhSizes.fontXs,
                      color: JuhColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isAr ? Icons.chevron_left : Icons.chevron_right,
              color: JuhColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRelativeRow extends StatelessWidget {
  final bool isAr;
  const _AddRelativeRow({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(JuhSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          border: Border.all(color: JuhColors.border),
        ),
        child: Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: JuhColors.primarySoft,
                borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
              ),
              child: const Icon(Icons.add, color: JuhColors.primary),
            ),
            const SizedBox(width: JuhSizes.md),
            Text(
              isAr ? 'إضافة قريب جديد' : 'Add New Relative',
              style: const TextStyle(
                fontSize: JuhSizes.fontBase,
                fontWeight: FontWeight.w600,
                color: JuhColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

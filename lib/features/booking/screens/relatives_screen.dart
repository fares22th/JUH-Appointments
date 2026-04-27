import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
import '../../../core/sizes.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/screen_header.dart';

class RelativesScreen extends ConsumerStatefulWidget {
  final String preselectedWho;
  const RelativesScreen({super.key, this.preselectedWho = 'self'});

  @override
  ConsumerState<RelativesScreen> createState() => _RelativesScreenState();
}

class _RelativesScreenState extends ConsumerState<RelativesScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.preselectedWho;
  }

  @override
  Widget build(BuildContext context, ) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final relatives = ref.watch(relativesProvider);

    return Scaffold(
      appBar: ScreenHeader(
        titleAr: 'من سيحضر الموعد؟',
        titleEn: 'Who is the appointment for?',
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(JuhSizes.md),
              separatorBuilder: (_, __) => const SizedBox(height: JuhSizes.sm),
              itemCount: relatives.length,
              itemBuilder: (ctx, i) {
                final r = relatives[i];
                final isSelected = _selected == r.id;
                return GestureDetector(
                  onTap: () => setState(() => _selected = r.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(JuhSizes.md),
                    decoration: BoxDecoration(
                      color: isSelected ? JuhColors.primarySoft : context.cs.surface,
                      borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
                      border: Border.all(
                        color: isSelected ? JuhColors.primary : context.cs.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? JuhColors.primary : context.cs.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (isAr ? r.nameAr : r.nameEn)[0],
                              style: TextStyle(
                                color: isSelected ? Colors.white : context.cs.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: JuhSizes.fontLg,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: JuhSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? r.nameAr : r.nameEn,
                                style: context.tt.titleSmall?.copyWith(
                                  color: isSelected ? JuhColors.primaryInk : null,
                                ),
                              ),
                              Text(
                                r.relationLabel(isAr),
                                style: context.tt.bodySmall?.copyWith(
                                  color: isSelected ? JuhColors.primary : context.cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: JuhColors.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(JuhSizes.md),
            child: AppButton(
              label: isAr ? 'التالي: اختر التأمين والطبيب' : 'Next: Choose Insurance & Doctor',
              onTap: () => context.push('/booking?who=$_selected'),
              icon: Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }
}

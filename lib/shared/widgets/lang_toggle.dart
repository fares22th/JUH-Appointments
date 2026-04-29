import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/colors.dart';
import '../../core/sizes.dart';
import '../../providers/locale_provider.dart';

class LangToggle extends ConsumerWidget {
  final bool light;
  const LangToggle({super.key, this.light = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';

    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: light
              ? Colors.white.withValues(alpha: 0.2)
              : JuhColors.primarySoft,
          borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EN',
              style: TextStyle(
                color: light
                    ? (isAr ? Colors.white54 : Colors.white)
                    : (isAr ? JuhColors.textMuted : JuhColors.primary),
                fontWeight:
                    isAr ? FontWeight.w400 : FontWeight.w700,
                fontSize: JuhSizes.fontXs,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '|',
                style: TextStyle(
                  color: light ? Colors.white38 : JuhColors.border,
                  fontSize: JuhSizes.fontXs,
                ),
              ),
            ),
            Text(
              'AR',
              style: TextStyle(
                color: light
                    ? (isAr ? Colors.white : Colors.white54)
                    : (isAr ? JuhColors.primary : JuhColors.textMuted),
                fontWeight:
                    isAr ? FontWeight.w700 : FontWeight.w400,
                fontSize: JuhSizes.fontXs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

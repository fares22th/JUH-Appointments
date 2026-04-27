import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/colors.dart';
import '../../core/sizes.dart';
import '../../providers/locale_provider.dart';

class LangToggle extends ConsumerWidget {
  const LangToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';

    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: JuhColors.primarySoft,
          borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
        ),
        child: Text(
          isAr ? 'EN' : 'AR',
          style: const TextStyle(
            color: JuhColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: JuhSizes.fontSm,
          ),
        ),
      ),
    );
  }
}

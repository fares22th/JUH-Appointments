import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sizes.dart';
import '../../providers/locale_provider.dart';
import 'lang_toggle.dart';

class ScreenHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String titleAr;
  final String titleEn;
  final bool showBack;
  final bool showLang;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const ScreenHeader({
    super.key,
    required this.titleAr,
    required this.titleEn,
    this.showBack = true,
    this.showLang = true,
    this.actions,
    this.leading,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(JuhSizes.appBarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final title = isAr ? titleAr : titleEn;

    return AppBar(
      automaticallyImplyLeading: false,
      leading: leading ??
          (showBack
              ? IconButton(
                  icon: Icon(
                    isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                    size: JuhSizes.iconMd,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              : null),
      title: Text(title),
      centerTitle: true,
      bottom: bottom,
      actions: [
        if (showLang) const LangToggle(),
        ...?actions,
        const SizedBox(width: JuhSizes.sm),
      ],
    );
  }
}

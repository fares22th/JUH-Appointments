import 'package:flutter/material.dart';
import '../../core/sizes.dart';

enum AppBtnVariant { primary, outline, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppBtnVariant variant;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppBtnVariant.primary,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
  });

  const AppButton.outline({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
  }) : variant = AppBtnVariant.outline;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
  }) : variant = AppBtnVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final child = loading
        ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: JuhSizes.iconMd),
                const SizedBox(width: JuhSizes.sm),
              ],
              Text(label),
            ],
          );

    switch (variant) {
      case AppBtnVariant.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(onPressed: loading ? null : onTap, child: child),
        );
      case AppBtnVariant.outline:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: OutlinedButton(onPressed: loading ? null : onTap, child: child),
        );
      case AppBtnVariant.ghost:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: loading ? null : onTap,
            style: TextButton.styleFrom(
              foregroundColor: cs.onSurface,
              minimumSize: const Size(0, JuhSizes.btnHeight),
            ),
            child: child,
          ),
        );
    }
  }
}

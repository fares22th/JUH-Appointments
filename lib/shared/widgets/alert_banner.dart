import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/sizes.dart';

enum AlertType { info, success, warning, error }

class AlertBanner extends StatelessWidget {
  final String message;
  final AlertType type;
  final IconData? icon;

  const AlertBanner({
    super.key,
    required this.message,
    this.type = AlertType.info,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, defaultIcon) = switch (type) {
      AlertType.info => (JuhColors.infoSoft, JuhColors.info, Icons.info_outline),
      AlertType.success => (JuhColors.successSoft, JuhColors.success, Icons.check_circle_outline),
      AlertType.warning => (JuhColors.warningSoft, JuhColors.warning, Icons.warning_amber_outlined),
      AlertType.error => (JuhColors.errorSoft, JuhColors.error, Icons.error_outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md, vertical: JuhSizes.sm + 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: fg, size: JuhSizes.iconMd),
          const SizedBox(width: JuhSizes.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: fg,
                fontSize: JuhSizes.fontSm,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

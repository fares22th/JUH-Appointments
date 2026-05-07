import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import 'colors.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  // ── Dark-mode aware semantic colors ──────────────────────────────────────

  /// Page / scaffold background
  Color get juhBg => isDark ? JuhColors.bgDark : JuhColors.bg;

  /// Card / sheet surface
  Color get juhSurface => isDark ? JuhColors.surfaceDark : JuhColors.surface;

  /// Primary text
  Color get juhText => isDark ? JuhColors.textPrimaryDark : JuhColors.textPrimary;

  /// Secondary / label text
  Color get juhTextSub => isDark ? JuhColors.textSecondaryDark : JuhColors.textSecondary;

  /// Muted / hint text
  Color get juhTextMuted =>
      isDark ? JuhColors.textSecondaryDark.withValues(alpha: 0.65) : JuhColors.textMuted;

  /// Divider / container border
  Color get juhBorder => isDark ? JuhColors.borderDark : JuhColors.border;

  /// Subtle border (card outline)
  Color get juhBorderLight =>
      isDark ? const Color(0xFF193344) : const Color(0xFFEBF3F6);

  // Soft tinted icon-container backgrounds
  Color get juhPrimarySoft =>
      isDark ? JuhColors.primary.withValues(alpha: 0.18) : JuhColors.primarySoft;
  Color get juhAccentSoft =>
      isDark ? JuhColors.accent.withValues(alpha: 0.18) : JuhColors.accentSoft;
  Color get juhSuccessSoft =>
      isDark ? JuhColors.success.withValues(alpha: 0.18) : JuhColors.successSoft;
  Color get juhWarningSoft =>
      isDark ? JuhColors.warning.withValues(alpha: 0.18) : JuhColors.warningSoft;
  Color get juhErrorSoft =>
      isDark ? JuhColors.error.withValues(alpha: 0.18) : JuhColors.errorSoft;

  String t(String ar, String en) {
    // Read locale from inherited widget — this extension is used in widgets that
    // have a ProviderScope ancestor, so we grab it via ProviderScope.containerOf.
    try {
      final container = ProviderScope.containerOf(this, listen: false);
      final locale = container.read(localeProvider);
      return locale.languageCode == 'ar' ? ar : en;
    } catch (_) {
      return ar;
    }
  }

  bool get isAr {
    try {
      final container = ProviderScope.containerOf(this, listen: false);
      return container.read(localeProvider).languageCode == 'ar';
    } catch (_) {
      return true;
    }
  }
}

extension StringX on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

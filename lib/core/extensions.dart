import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;

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

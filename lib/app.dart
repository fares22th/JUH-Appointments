import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nhost_flutter_auth/nhost_flutter_auth.dart';
import 'core/nhost.dart';
import 'core/theme.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/router.dart';

class JuhApp extends ConsumerWidget {
  const JuhApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return NhostAuthProvider(
      auth: nhostClient.auth,
      child: MaterialApp.router(
        title: 'JUH Appointments',
        debugShowCheckedModeBanner: false,
        theme: JuhTheme.light(),
        darkTheme: JuhTheme.dark(),
        themeMode: themeMode,
        locale: locale,
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: appRouter,
      ),
    );
  }
}

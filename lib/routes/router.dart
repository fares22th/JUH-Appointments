import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/contact_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/booking/screens/relatives_screen.dart';
import '../features/booking/screens/booking_choose_screen.dart';
import '../features/booking/screens/calendar_screen.dart';
import '../features/booking/screens/confirm_screen.dart';
import '../features/appointments/screens/appt_list_screen.dart';
import '../features/appointments/screens/appt_detail_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/email_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
  routes: [
    GoRoute(path: '/', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
    GoRoute(path: '/contact', builder: (_, __) => const ContactScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/relatives',
      builder: (ctx, state) {
        final who = state.uri.queryParameters['who'] ?? 'self';
        return RelativesScreen(preselectedWho: who);
      },
    ),
    GoRoute(
      path: '/booking',
      builder: (ctx, state) {
        final who = state.uri.queryParameters['who'] ?? 'self';
        return BookingChooseScreen(who: who);
      },
    ),
    GoRoute(
      path: '/calendar',
      builder: (ctx, state) {
        final who = state.uri.queryParameters['who'] ?? 'self';
        return CalendarScreen(who: who);
      },
    ),
    GoRoute(
      path: '/confirm',
      builder: (ctx, state) {
        final who = state.uri.queryParameters['who'] ?? 'self';
        return ConfirmScreen(who: who);
      },
    ),
    GoRoute(path: '/appointments', builder: (_, __) => const ApptListScreen()),
    GoRoute(
      path: '/appointments/:id',
      builder: (ctx, state) {
        final id = state.pathParameters['id'] ?? '';
        return ApptDetailScreen(apptId: id);
      },
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/email', builder: (_, __) => const EmailScreen()),
  ],
  errorBuilder: (ctx, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.error}')),
  ),
);

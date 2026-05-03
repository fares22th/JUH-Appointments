import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nhost_flutter_auth/nhost_flutter_auth.dart';
import '../core/nhost.dart';
import '../providers/auth_provider.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/login_welcome_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/contact_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/booking/screens/relatives_screen.dart';
import '../features/booking/screens/booking_choose_screen.dart';
import '../features/booking/screens/calendar_screen.dart';
import '../features/booking/screens/confirm_screen.dart';
import '../features/appointments/screens/appt_list_screen.dart';
import '../features/appointments/screens/appt_detail_screen.dart';
import '../features/inquiries/screens/clinic_appointments_inquiry_screen.dart';
import '../features/inquiries/screens/doctors_leave_inquiry_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/email_screen.dart';

const _authRoutes = {'/welcome', '/login', '/signup', '/contact'};

final appRouter = GoRouter(
  initialLocation: '/welcome',
  debugLogDiagnostics: false,
  refreshListenable: authListenable,
  redirect: (context, state) {
    final isSignedIn =
        nhostClient.auth.authenticationState == AuthenticationState.signedIn;
    final isInProgress =
        nhostClient.auth.authenticationState == AuthenticationState.inProgress;

    if (isInProgress) return null;

    final loc = state.matchedLocation;
    final isAuthRoute = _authRoutes.contains(loc);

    if (!isSignedIn && !isAuthRoute) return '/welcome';
    if (isSignedIn && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/login-welcome', builder: (_, __) => const LoginWelcomeScreen()),
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
        final insuranceId = state.uri.queryParameters['insurance'];
        return BookingChooseScreen(who: who, initialInsuranceId: insuranceId);
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
      path: '/clinic-appointments-inquiry',
      builder: (_, __) => const ClinicAppointmentsInquiryScreen(),
    ),
    GoRoute(
      path: '/doctors-leave-inquiry',
      builder: (_, __) => const DoctorsLeaveInquiryScreen(),
    ),
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

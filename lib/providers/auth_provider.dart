import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nhost_flutter_auth/nhost_flutter_auth.dart';
import 'package:nhost_sdk/nhost_sdk.dart' show User;
import '../core/nhost.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    nhostClient.auth.addAuthStateChangedCallback(_onChange);
  }

  void _onChange(AuthenticationState _) => notifyListeners();

  bool get isSignedIn =>
      nhostClient.auth.authenticationState == AuthenticationState.signedIn;

  User? get currentUser => nhostClient.auth.currentUser;
}

final authProvider = ChangeNotifierProvider<AuthNotifier>((_) => AuthNotifier());

// Temporary data passed from SignUpScreen → ContactScreen
class PendingSignup {
  final String nationalId;
  final String civilRecord;
  const PendingSignup({required this.nationalId, required this.civilRecord});
}

final pendingSignupProvider = StateProvider<PendingSignup?>((ref) => null);

// GoRouter refreshListenable — notifies router when auth state changes
final authListenable = AuthNotifier();

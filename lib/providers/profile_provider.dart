import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/nhost.dart';
import '../models/profile.dart';
import '../models/relative.dart';
import '../data/seed_data.dart';
import 'auth_provider.dart';

Profile _profileFromNhost() {
  final user = nhostClient.auth.currentUser;
  if (user == null) {
    return Profile(
      id: 'guest',
      nameAr: 'مستخدم',
      nameEn: 'User',
      nationalId: '',
      phone: '',
      email: '',
      createdAt: DateTime.now(),
    );
  }
  final meta = user.metadata ?? {};
  final name = user.displayName.isNotEmpty ? user.displayName : 'مستخدم';
  return Profile(
    id: user.id,
    nameAr: name,
    nameEn: name,
    nationalId: (meta['nationalId'] as String?) ?? '',
    phone: (meta['phone'] as String?) ?? '',
    email: (meta['contactEmail'] as String?) ?? '',
    createdAt: user.createdAt,
  );
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, Profile>((ref) {
  // Rebuild whenever auth state changes so profile reflects current user
  ref.watch(authProvider);
  return ProfileNotifier(_profileFromNhost());
});

class ProfileNotifier extends StateNotifier<Profile> {
  ProfileNotifier(Profile initial) : super(initial);

  void update({String? phone, String? email}) {
    state = state.copyWith(phone: phone, email: email);
  }
}

final relativesProvider =
    StateNotifierProvider<RelativesNotifier, List<Relative>>((ref) {
  final profile = ref.watch(profileProvider);
  return RelativesNotifier(profile.id);
});

class RelativesNotifier extends StateNotifier<List<Relative>> {
  RelativesNotifier(String userId) : super(SeedData.defaultRelatives(userId));

  void add(Relative r) => state = [...state, r];
  void remove(String id) => state = state.where((r) => r.id != id).toList();
}

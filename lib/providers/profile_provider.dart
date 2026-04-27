import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../models/relative.dart';
import '../data/seed_data.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, Profile>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<Profile> {
  ProfileNotifier()
      : super(Profile(
          id: 'demo-user',
          nameAr: 'فارس أحمد',
          nameEn: 'Faris Ahmed',
          nationalId: '9876543210',
          phone: '+962 79 123 4567',
          email: 'faris.ahmed@example.com',
          createdAt: DateTime(2024, 1, 15),
        ));

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

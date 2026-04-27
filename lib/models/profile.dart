import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final String nationalId;
  final String phone;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nationalId,
    required this.phone,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
  });

  Profile copyWith({
    String? phone,
    String? email,
    String? avatarUrl,
  }) =>
      Profile(
        id: id,
        nameAr: nameAr,
        nameEn: nameEn,
        nationalId: nationalId,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, nameAr, nameEn, nationalId, phone, email, avatarUrl];
}

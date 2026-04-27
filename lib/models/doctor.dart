import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  final String id;
  final String specialtyId;
  final String nameAr;
  final String nameEn;
  final String titleAr;
  final String titleEn;
  final String? avatarUrl;
  final double rating;
  final int reviewCount;
  final String consultFee;

  const Doctor({
    required this.id,
    required this.specialtyId,
    required this.nameAr,
    required this.nameEn,
    required this.titleAr,
    required this.titleEn,
    this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.consultFee,
  });

  @override
  List<Object?> get props => [id, specialtyId, nameAr, nameEn];
}

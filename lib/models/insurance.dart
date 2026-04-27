import 'package:equatable/equatable.dart';

class InsuranceType extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final String icon;

  const InsuranceType({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, nameAr, nameEn];
}

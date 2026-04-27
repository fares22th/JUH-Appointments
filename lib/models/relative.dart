import 'package:equatable/equatable.dart';

class Relative extends Equatable {
  final String id;
  final String ownerId;
  final String nameAr;
  final String nameEn;
  final String relation; // 'self' | 'father' | 'mother' | 'son' | 'daughter' | 'spouse'
  final String nationalId;
  final DateTime? dob;

  const Relative({
    required this.id,
    required this.ownerId,
    required this.nameAr,
    required this.nameEn,
    required this.relation,
    required this.nationalId,
    this.dob,
  });

  String relationLabel(bool isAr) {
    const map = {
      'self': ('أنا', 'Self'),
      'father': ('الأب', 'Father'),
      'mother': ('الأم', 'Mother'),
      'son': ('الابن', 'Son'),
      'daughter': ('الابنة', 'Daughter'),
      'spouse': ('الزوج/ة', 'Spouse'),
    };
    final r = map[relation] ?? (relation, relation);
    return isAr ? r.$1 : r.$2;
  }

  @override
  List<Object?> get props => [id, ownerId, nameAr, nameEn, relation, nationalId];
}

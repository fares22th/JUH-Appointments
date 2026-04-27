import 'package:equatable/equatable.dart';

enum ApptStatus { confirmed, cancelled, pending, completed }

class Appointment extends Equatable {
  final String id;
  final String patientNameAr;
  final String patientNameEn;
  final String doctorNameAr;
  final String doctorNameEn;
  final String doctorTitleAr;
  final String doctorTitleEn;
  final String specialtyAr;
  final String specialtyEn;
  final String insuranceAr;
  final String insuranceEn;
  final DateTime dateTime;
  final String location;
  final String refCode;
  final ApptStatus status;
  final String? notes;

  const Appointment({
    required this.id,
    required this.patientNameAr,
    required this.patientNameEn,
    required this.doctorNameAr,
    required this.doctorNameEn,
    required this.doctorTitleAr,
    required this.doctorTitleEn,
    required this.specialtyAr,
    required this.specialtyEn,
    required this.insuranceAr,
    required this.insuranceEn,
    required this.dateTime,
    required this.location,
    required this.refCode,
    required this.status,
    this.notes,
  });

  Appointment copyWith({ApptStatus? status, String? notes}) => Appointment(
        id: id,
        patientNameAr: patientNameAr,
        patientNameEn: patientNameEn,
        doctorNameAr: doctorNameAr,
        doctorNameEn: doctorNameEn,
        doctorTitleAr: doctorTitleAr,
        doctorTitleEn: doctorTitleEn,
        specialtyAr: specialtyAr,
        specialtyEn: specialtyEn,
        insuranceAr: insuranceAr,
        insuranceEn: insuranceEn,
        dateTime: dateTime,
        location: location,
        refCode: refCode,
        status: status ?? this.status,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [id, status, dateTime];
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../data/seed_data.dart';

final appointmentsProvider =
    StateNotifierProvider<AppointmentsNotifier, List<Appointment>>((ref) {
  return AppointmentsNotifier();
});

class AppointmentsNotifier extends StateNotifier<List<Appointment>> {
  AppointmentsNotifier() : super(SeedData.seedAppointments('demo-user'));

  void add(Appointment a) => state = [a, ...state];

  void cancel(String id) {
    state = state
        .map((a) => a.id == id ? a.copyWith(status: ApptStatus.cancelled) : a)
        .toList();
  }

  List<Appointment> get upcoming => state
      .where((a) =>
          a.status == ApptStatus.confirmed &&
          a.dateTime.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<Appointment> get past => state
      .where((a) =>
          a.status == ApptStatus.completed ||
          a.status == ApptStatus.cancelled ||
          (a.status == ApptStatus.confirmed &&
              a.dateTime.isBefore(DateTime.now())))
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
}

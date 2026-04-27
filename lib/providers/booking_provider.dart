import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_draft.dart';

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingDraft>((ref) {
  return BookingNotifier();
});

class BookingNotifier extends StateNotifier<BookingDraft> {
  BookingNotifier() : super(const BookingDraft.empty());

  void reset([String? who]) =>
      state = BookingDraft(who: who ?? state.who);

  void setInsurance(String id) =>
      state = state.copyWith(insuranceId: id, specId: null, docId: null);

  void setSpec(String id) =>
      state = state.copyWith(specId: id, docId: null);

  void setDoc(String id) => state = state.copyWith(docId: id);

  void setSlot({required int day, required int month, required int year, required String slot}) =>
      state = state.copyWith(day: day, month: month, year: year, slot: slot);

  void setWho(String who) => state = state.copyWith(who: who);
}

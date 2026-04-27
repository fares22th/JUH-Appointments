import 'package:equatable/equatable.dart';

class BookingDraft extends Equatable {
  final String? insuranceId;
  final String? specId;
  final String? docId;
  final int? day;
  final int? month;
  final int? year;
  final String? slot;
  final String? who; // relative id or 'self'

  const BookingDraft({
    this.insuranceId,
    this.specId,
    this.docId,
    this.day,
    this.month,
    this.year,
    this.slot,
    this.who,
  });

  const BookingDraft.empty() : this();

  BookingDraft copyWith({
    String? insuranceId,
    String? specId,
    String? docId,
    int? day,
    int? month,
    int? year,
    String? slot,
    String? who,
  }) =>
      BookingDraft(
        insuranceId: insuranceId ?? this.insuranceId,
        specId: specId ?? this.specId,
        docId: docId ?? this.docId,
        day: day ?? this.day,
        month: month ?? this.month,
        year: year ?? this.year,
        slot: slot ?? this.slot,
        who: who ?? this.who,
      );

  bool get hasInsurance => insuranceId != null;
  bool get hasSpec => specId != null;
  bool get hasDoc => docId != null;
  bool get hasSlot => day != null && month != null && year != null && slot != null;

  DateTime? get dateTime {
    if (!hasSlot) return null;
    final parts = slot!.split(':');
    return DateTime(year!, month!, day!, int.parse(parts[0]), int.parse(parts[1]));
  }

  @override
  List<Object?> get props => [insuranceId, specId, docId, day, month, year, slot, who];
}

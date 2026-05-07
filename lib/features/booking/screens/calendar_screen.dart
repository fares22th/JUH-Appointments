import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/colors.dart';
import '../../../core/sizes.dart';
import '../../../data/seed_data.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/screen_header.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final String who;
  const CalendarScreen({super.key, required this.who});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusMonth;
  DateTime? _selectedDay;
  String? _selectedSlot;

  bool _isBooked(DateTime day, String slot) {
    return day.day.isEven && SeedData.availableSlots.indexOf(slot).isEven;
  }

  @override
  void initState() {
    super.initState();
    _focusMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _prevMonth() => setState(
      () => _focusMonth = DateTime(_focusMonth.year, _focusMonth.month - 1));
  void _nextMonth() => setState(
      () => _focusMonth = DateTime(_focusMonth.year, _focusMonth.month + 1));

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final draft = ref.watch(bookingProvider);

    // Look up selected doctor for the doctor card
    final doctor = draft.docId != null
        ? SeedData.doctors.where((d) => d.id == draft.docId).firstOrNull
        : null;

    final monthName =
        DateFormat('MMMM yyyy', isAr ? 'ar' : 'en').format(_focusMonth);
    final firstDay = DateTime(_focusMonth.year, _focusMonth.month, 1);
    final daysInMonth =
        DateTime(_focusMonth.year, _focusMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // Sun=0

    final dayHeaders = isAr
        ? ['أح', 'إث', 'ث', 'أر', 'خ', 'ج', 'س']
        : ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Scaffold(
      backgroundColor: JuhColors.bg,
      appBar: const ScreenHeader(
          titleAr: 'اختر الموعد', titleEn: 'Choose Appointment'),
      body: Column(
        children: [
          // Doctor summary card
          if (doctor != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  JuhSizes.md, JuhSizes.sm, JuhSizes.md, 0),
              child: Container(
                padding: const EdgeInsets.all(JuhSizes.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
                  border: Border.all(color: JuhColors.border),
                ),
                child: Row(
                  textDirection:
                      isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    CircleAvatar(
                      backgroundColor: JuhColors.primarySoft,
                      radius: 22,
                      child: Text(
                        (isAr ? doctor.nameAr : doctor.nameEn)
                            .replaceAll('د. ', '')
                            .replaceAll('Dr. ', '')[0],
                        style: const TextStyle(
                          color: JuhColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: JuhSizes.fontMd,
                        ),
                      ),
                    ),
                    const SizedBox(width: JuhSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isAr
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? doctor.nameAr : doctor.nameEn,
                            style: const TextStyle(
                              fontSize: JuhSizes.fontBase,
                              fontWeight: FontWeight.w700,
                              color: JuhColors.textPrimary,
                            ),
                          ),
                          Text(
                            isAr ? doctor.titleAr : doctor.titleEn,
                            style: const TextStyle(
                              fontSize: JuhSizes.fontXs,
                              color: JuhColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(4),
                      splashColor: JuhColors.primary.withValues(alpha: 0.15),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          isAr ? 'تغيير' : 'Change',
                          style: const TextStyle(
                            fontSize: JuhSizes.fontSm,
                            fontWeight: FontWeight.w600,
                            color: JuhColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: JuhSizes.sm),

          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: JuhSizes.md, vertical: JuhSizes.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: JuhColors.textPrimary),
                  onPressed: _prevMonth,
                ),
                Text(
                  monthName,
                  style: const TextStyle(
                    fontSize: JuhSizes.fontBase,
                    fontWeight: FontWeight.w700,
                    color: JuhColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right,
                      color: JuhColors.textPrimary),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // Day-of-week headers
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: JuhSizes.md),
            child: Row(
              children: dayHeaders
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: JuhSizes.fontXs,
                            fontWeight: FontWeight.w600,
                            color: JuhColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: JuhSizes.xs),

          // Calendar grid
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: JuhSizes.md),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: startWeekday + daysInMonth,
              itemBuilder: (ctx, idx) {
                if (idx < startWeekday) return const SizedBox();
                final day = idx - startWeekday + 1;
                final date = DateTime(
                    _focusMonth.year, _focusMonth.month, day);
                final now = DateTime.now();
                final isToday = date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;
                final isPast = date
                    .isBefore(now.subtract(const Duration(days: 1)));
                final isFriday = date.weekday == DateTime.friday;
                final isDisabled = isPast || isFriday;
                final isSelected = _selectedDay?.day == day &&
                    _selectedDay?.month == _focusMonth.month &&
                    _selectedDay?.year == _focusMonth.year;

                // Available dot: not disabled and at least one slot not booked
                final hasAvailable = !isDisabled &&
                    SeedData.availableSlots
                        .any((s) => !_isBooked(date, s));

                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: isDisabled
                        ? null
                        : () => setState(() {
                              _selectedDay = date;
                              _selectedSlot = null;
                            }),
                    splashColor: JuhColors.primary.withValues(alpha: 0.20),
                    highlightColor: JuhColors.primary.withValues(alpha: 0.10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? JuhColors.primary
                                : isToday
                                    ? JuhColors.primarySoft
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                                JuhSizes.radiusSm),
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              style: TextStyle(
                                fontSize: JuhSizes.fontSm,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isDisabled
                                    ? JuhColors.border
                                    : isSelected
                                        ? Colors.white
                                        : isToday
                                            ? JuhColors.primary
                                            : JuhColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        if (hasAvailable && !isSelected)
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: const BoxDecoration(
                              color: JuhColors.success,
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          const SizedBox(height: 7),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1, color: JuhColors.border),
          const SizedBox(height: JuhSizes.sm),

          // Time slots
          Expanded(
            child: _selectedDay == null
                ? Center(
                    child: Text(
                      isAr
                          ? 'اختر يوماً من التقويم'
                          : 'Select a day from the calendar',
                      style: const TextStyle(
                        color: JuhColors.textSecondary,
                        fontSize: JuhSizes.fontSm,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            JuhSizes.md, 0, JuhSizes.md, JuhSizes.sm),
                        child: Text(
                          isAr ? 'المواعيد المتاحة' : 'Available Slots',
                          style: const TextStyle(
                            fontSize: JuhSizes.fontSm,
                            fontWeight: FontWeight.w600,
                            color: JuhColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: JuhSizes.md),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: SeedData.availableSlots.length,
                          itemBuilder: (ctx, i) {
                            final slot = SeedData.availableSlots[i];
                            final booked =
                                _isBooked(_selectedDay!, slot);
                            final isSlotSelected =
                                _selectedSlot == slot;

                            return Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: booked
                                    ? null
                                    : () => setState(
                                        () => _selectedSlot = slot),
                                splashColor: JuhColors.primary.withValues(alpha: 0.20),
                                highlightColor: JuhColors.primary.withValues(alpha: 0.10),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  decoration: BoxDecoration(
                                    color: booked
                                        ? JuhColors.bg
                                        : isSlotSelected
                                            ? JuhColors.primary
                                            : JuhColors.primarySoft,
                                    borderRadius: BorderRadius.circular(
                                        JuhSizes.radiusSm),
                                    border: Border.all(
                                      color: booked
                                          ? JuhColors.border
                                          : isSlotSelected
                                              ? JuhColors.primary
                                              : JuhColors.primary
                                                  .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: booked
                                        ? Text(
                                            slot,
                                            style: const TextStyle(
                                              fontSize: JuhSizes.fontSm,
                                              color: JuhColors.border,
                                              decoration: TextDecoration.lineThrough,
                                              decorationColor: JuhColors.border,
                                            ),
                                          )
                                        : Text(
                                            slot,
                                            style: TextStyle(
                                              fontSize: JuhSizes.fontSm,
                                              fontWeight: FontWeight.w600,
                                              color: isSlotSelected
                                                  ? Colors.white
                                                  : JuhColors.primary,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),

          if (_selectedDay != null && _selectedSlot != null)
            Padding(
              padding: const EdgeInsets.all(JuhSizes.md),
              child: AppButton(
                label: isAr
                    ? 'التالي: تأكيد الحجز'
                    : 'Next: Confirm Booking',
                onTap: () {
                  ref.read(bookingProvider.notifier).setSlot(
                        day: _selectedDay!.day,
                        month: _selectedDay!.month,
                        year: _selectedDay!.year,
                        slot: _selectedSlot!,
                      );
                  context.push('/confirm?who=${widget.who}');
                },
                icon: Icons.arrow_forward,
              ),
            ),
        ],
      ),
    );
  }
}

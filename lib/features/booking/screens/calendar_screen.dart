import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/colors.dart';
import '../../../core/extensions.dart';
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

  // Simulate booked slots (every other slot on even days)
  bool _isBooked(DateTime day, String slot) {
    return day.day.isEven && SeedData.availableSlots.indexOf(slot).isEven;
  }

  @override
  void initState() {
    super.initState();
    _focusMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _prevMonth() => setState(() => _focusMonth = DateTime(_focusMonth.year, _focusMonth.month - 1));
  void _nextMonth() => setState(() => _focusMonth = DateTime(_focusMonth.year, _focusMonth.month + 1));

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final draft = ref.watch(bookingProvider);

    final monthName = DateFormat('MMMM yyyy', isAr ? 'ar' : 'en').format(_focusMonth);
    final firstDay = DateTime(_focusMonth.year, _focusMonth.month, 1);
    final daysInMonth = DateTime(_focusMonth.year, _focusMonth.month + 1, 0).day;
    final startWeekday = (firstDay.weekday % 7); // Sun=0

    final dayHeaders = isAr
        ? ['أح', 'إث', 'ث', 'أر', 'خ', 'ج', 'س']
        : ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Scaffold(
      appBar: ScreenHeader(titleAr: 'اختر الموعد', titleEn: 'Choose Slot'),
      body: Column(
        children: [
          // Month nav
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md, vertical: JuhSizes.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevMonth),
                Text(monthName, style: context.tt.titleMedium),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth),
              ],
            ),
          ),
          // Day headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
            child: Row(
              children: dayHeaders
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: TextStyle(
                                  fontSize: JuhSizes.fontXs,
                                  fontWeight: FontWeight.w600,
                                  color: context.cs.onSurfaceVariant)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: JuhSizes.xs),
          // Calendar grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: startWeekday + daysInMonth,
              itemBuilder: (ctx, idx) {
                if (idx < startWeekday) return const SizedBox();
                final day = idx - startWeekday + 1;
                final date = DateTime(_focusMonth.year, _focusMonth.month, day);
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;
                final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                final isFriday = date.weekday == DateTime.friday;
                final isDisabled = isPast || isFriday;
                final isSelected = _selectedDay?.day == day &&
                    _selectedDay?.month == _focusMonth.month &&
                    _selectedDay?.year == _focusMonth.year;

                return GestureDetector(
                  onTap: isDisabled ? null : () => setState(() { _selectedDay = date; _selectedSlot = null; }),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? JuhColors.primary
                          : isToday
                              ? JuhColors.primarySoft
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: JuhSizes.fontSm,
                          fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                          color: isDisabled
                              ? context.cs.outline
                              : isSelected
                                  ? Colors.white
                                  : isToday
                                      ? JuhColors.primary
                                      : context.cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: JuhSizes.md),
          // Slots
          Expanded(
            child: _selectedDay == null
                ? Center(
                    child: Text(
                      isAr ? 'اختر يوماً من التقويم' : 'Select a day from the calendar',
                      style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(JuhSizes.md, 0, JuhSizes.md, JuhSizes.sm),
                        child: Text(
                          isAr ? 'المواعيد المتاحة' : 'Available slots',
                          style: context.tt.titleSmall,
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: SeedData.availableSlots.length,
                          itemBuilder: (ctx, i) {
                            final slot = SeedData.availableSlots[i];
                            final booked = _isBooked(_selectedDay!, slot);
                            final isSelected = _selectedSlot == slot;

                            return GestureDetector(
                              onTap: booked ? null : () => setState(() => _selectedSlot = slot),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: booked
                                      ? context.cs.surfaceContainerHighest
                                      : isSelected
                                          ? JuhColors.primary
                                          : JuhColors.primarySoft,
                                  borderRadius: BorderRadius.circular(JuhSizes.radiusSm),
                                  border: isSelected ? null : Border.all(color: booked ? context.cs.outline : JuhColors.primary.withValues(alpha: 0.3)),
                                ),
                                child: Center(
                                  child: Text(
                                    slot,
                                    style: TextStyle(
                                      fontSize: JuhSizes.fontSm,
                                      fontWeight: FontWeight.w600,
                                      color: booked
                                          ? context.cs.onSurfaceVariant
                                          : isSelected
                                              ? Colors.white
                                              : JuhColors.primary,
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
                label: isAr ? 'التالي: تأكيد الحجز' : 'Next: Confirm Booking',
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

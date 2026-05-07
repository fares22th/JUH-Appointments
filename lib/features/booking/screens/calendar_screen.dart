import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

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

  bool _isBooked(DateTime day, String slot) {
    return day.day.isEven && SeedData.availableSlots.indexOf(slot).isEven;
  }

  @override
  void initState() {
    super.initState();
    _focusMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _prevMonth() {
    setState(() {
      _focusMonth = DateTime(_focusMonth.year, _focusMonth.month - 1);
      _selectedDay = null;
      _selectedSlot = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _focusMonth = DateTime(_focusMonth.year, _focusMonth.month + 1);
      _selectedDay = null;
      _selectedSlot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final draft = ref.watch(bookingProvider);

    final doctor = draft.docId != null
        ? SeedData.doctors.where((d) => d.id == draft.docId).firstOrNull
        : null;

    final monthName =
        DateFormat('MMMM yyyy', isAr ? 'ar' : 'en').format(_focusMonth);

    final firstDay = DateTime(_focusMonth.year, _focusMonth.month, 1);
    final daysInMonth =
        DateTime(_focusMonth.year, _focusMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    final dayHeaders = isAr
        ? ['أح', 'إث', 'ث', 'أر', 'خ', 'ج', 'س']
        : ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Scaffold(
      backgroundColor: context.juhBg,
      appBar: const ScreenHeader(
        titleAr: 'اختر الموعد',
        titleEn: 'Choose Appointment',
      ),

      // الزر صار هنا حتى لا يكسر الشاشة عند ظهوره
      bottomNavigationBar: _selectedDay != null && _selectedSlot != null
          ? SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  JuhSizes.md,
                  JuhSizes.sm,
                  JuhSizes.md,
                  JuhSizes.md,
                ),
                decoration: BoxDecoration(
                  color: context.juhBg,
                  border: Border(
                    top: BorderSide(color: context.juhBorder),
                  ),
                ),
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
                  icon: isAr ? Icons.arrow_back : Icons.arrow_forward,
                ),
              ),
            )
          : null,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: _selectedDay != null && _selectedSlot != null ? 90 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (doctor != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    JuhSizes.md,
                    JuhSizes.sm,
                    JuhSizes.md,
                    JuhSizes.sm,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.juhSurface,
                      borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
                      border: Border.all(color: context.juhBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      textDirection:
                          isAr ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        CircleAvatar(
                          backgroundColor: context.juhPrimarySoft,
                          radius: 21,
                          child: Text(
                            (isAr ? doctor.nameAr : doctor.nameEn)
                                .replaceAll('د. ', '')
                                .replaceAll('Dr. ', '')[0],
                            style: const TextStyle(
                              color: JuhColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: JuhSizes.fontMd,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? doctor.nameAr : doctor.nameEn,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: JuhSizes.fontBase,
                                  fontWeight: FontWeight.w700,
                                  color: context.juhText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAr ? doctor.titleAr : doctor.titleEn,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: JuhSizes.fontXs,
                                  color: context.juhTextSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => context.pop(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Text(
                              isAr ? 'تغيير' : 'Change',
                              style: const TextStyle(
                                fontSize: JuhSizes.fontSm,
                                fontWeight: FontWeight.w700,
                                color: JuhColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.juhSurface,
                    borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
                    border: Border.all(color: context.juhBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _monthButton(
                            icon:
                                isAr ? Icons.chevron_right : Icons.chevron_left,
                            onTap: _prevMonth,
                            context: context,
                          ),
                          Text(
                            monthName,
                            style: TextStyle(
                              fontSize: JuhSizes.fontBase,
                              fontWeight: FontWeight.w800,
                              color: context.juhText,
                            ),
                          ),
                          _monthButton(
                            icon:
                                isAr ? Icons.chevron_left : Icons.chevron_right,
                            onTap: _nextMonth,
                            context: context,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: dayHeaders
                            .map(
                              (d) => Expanded(
                                child: Center(
                                  child: Text(
                                    d,
                                    style: TextStyle(
                                      fontSize: JuhSizes.fontXs,
                                      fontWeight: FontWeight.w700,
                                      color: context.juhTextSub,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 0.95,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: startWeekday + daysInMonth,
                        itemBuilder: (ctx, idx) {
                          if (idx < startWeekday) return const SizedBox();

                          final day = idx - startWeekday + 1;
                          final date = DateTime(
                            _focusMonth.year,
                            _focusMonth.month,
                            day,
                          );

                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final currentDate =
                              DateTime(date.year, date.month, date.day);

                          final isToday = currentDate == today;
                          final isPast = currentDate.isBefore(today);
                          final isFriday = date.weekday == DateTime.friday;
                          final isDisabled = isPast || isFriday;

                          final isSelected = _selectedDay?.day == day &&
                              _selectedDay?.month == _focusMonth.month &&
                              _selectedDay?.year == _focusMonth.year;

                          final hasAvailable = !isDisabled &&
                              SeedData.availableSlots
                                  .any((s) => !_isBooked(date, s));

                          return InkWell(
                            borderRadius:
                                BorderRadius.circular(JuhSizes.radiusSm),
                            onTap: isDisabled
                                ? null
                                : () {
                                    setState(() {
                                      _selectedDay = date;
                                      _selectedSlot = null;
                                    });
                                  },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  width: 31,
                                  height: 31,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? JuhColors.primary
                                        : isToday
                                            ? context.juhPrimarySoft
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? JuhColors.primary
                                          : isToday
                                              ? JuhColors.primary
                                                  .withValues(alpha: 0.35)
                                              : Colors.transparent,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$day',
                                      style: TextStyle(
                                        fontSize: JuhSizes.fontSm,
                                        fontWeight: isSelected || isToday
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                        color: isDisabled
                                            ? context.juhBorder
                                            : isSelected
                                                ? Colors.white
                                                : isToday
                                                    ? JuhColors.primary
                                                    : context.juhText,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  width: hasAvailable && !isSelected ? 5 : 0,
                                  height: hasAvailable && !isSelected ? 5 : 0,
                                  decoration: const BoxDecoration(
                                    color: JuhColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: JuhSizes.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
                child: Text(
                  isAr ? 'المواعيد المتاحة' : 'Available Slots',
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: JuhSizes.fontSm,
                    fontWeight: FontWeight.w700,
                    color: context.juhTextSub,
                  ),
                ),
              ),
              const SizedBox(height: JuhSizes.sm),
              if (_selectedDay == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: context.juhSurface,
                      borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
                      border: Border.all(color: context.juhBorder),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          color: context.juhTextSub.withValues(alpha: 0.75),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAr
                              ? 'اختر يوماً من التقويم لعرض المواعيد'
                              : 'Select a day from the calendar to show slots',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.juhTextSub,
                            fontSize: JuhSizes.fontSm,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: SeedData.availableSlots.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3.4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (ctx, i) {
                      final slot = SeedData.availableSlots[i];
                      final booked = _isBooked(_selectedDay!, slot);
                      final isSlotSelected = _selectedSlot == slot;

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: booked
                            ? null
                            : () {
                                setState(() {
                                  _selectedSlot = slot;
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: booked
                                ? context.juhSurface
                                : isSlotSelected
                                    ? JuhColors.primary
                                    : context.juhSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: booked
                                  ? context.juhBorder
                                  : isSlotSelected
                                      ? JuhColors.primary
                                      : JuhColors.primary
                                          .withValues(alpha: 0.35),
                            ),
                            boxShadow: [
                              if (!booked)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.035),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 15,
                                color: booked
                                    ? context.juhBorder
                                    : isSlotSelected
                                        ? Colors.white
                                        : JuhColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  slot,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: JuhSizes.fontSm,
                                    fontWeight: FontWeight.w700,
                                    color: booked
                                        ? context.juhBorder
                                        : isSlotSelected
                                            ? Colors.white
                                            : JuhColors.primary,
                                    decoration: booked
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: context.juhBorder,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _monthButton({
    required IconData icon,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.juhPrimarySoft,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          color: JuhColors.primary,
          size: 22,
        ),
      ),
    );
  }
}

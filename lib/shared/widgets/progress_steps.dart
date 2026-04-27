import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/sizes.dart';

class ProgressSteps extends StatelessWidget {
  final int current; // 1-based
  final int total;
  final List<String> labels;

  const ProgressSteps({
    super.key,
    required this.current,
    required this.total,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final step = i + 1;
        final isDone = step < current;
        final isActive = step == current;
        final color = (isDone || isActive) ? JuhColors.primary : JuhColors.border;
        final textColor = isActive
            ? JuhColors.primary
            : isDone
                ? JuhColors.primaryInk
                : JuhColors.textMuted;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isDone ? JuhColors.primary : JuhColors.border,
                      ),
                    ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDone ? JuhColors.primary : isActive ? JuhColors.primarySoft : Colors.transparent,
                      border: Border.all(color: color, width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : Text(
                              '$step',
                              style: TextStyle(
                                fontSize: JuhSizes.fontXs,
                                fontWeight: FontWeight.w700,
                                color: isActive ? JuhColors.primary : JuhColors.textMuted,
                              ),
                            ),
                    ),
                  ),
                  if (i < total - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: (step < current) ? JuhColors.primary : JuhColors.border,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              if (i < labels.length)
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: JuhSizes.fontXs,
                    color: textColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        );
      }),
    );
  }
}

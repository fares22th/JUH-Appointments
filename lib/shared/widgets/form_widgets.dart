import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/sizes.dart';

/// Segmented horizontal progress bar for multi-step flows.
/// [step] is 0-indexed: steps < step are done (green), step == step is active (blue).
class SegmentBar extends StatelessWidget {
  final int step;
  final int total;
  const SegmentBar({super.key, required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: JuhSizes.md),
      child: Row(
        children: List.generate(total * 2 - 1, (i) {
          if (i.isOdd) return const SizedBox(width: 4);
          final idx = i ~/ 2;
          final Color c = idx < step
              ? JuhColors.success
              : idx == step
                  ? JuhColors.primary
                  : JuhColors.border;
          return Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Blue info banner with icon + text.
class InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  const InfoBanner({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: JuhSizes.md, vertical: 12),
      decoration: BoxDecoration(
        color: JuhColors.primarySoft,
        borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
        border: Border.all(color: JuhColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Icon(icon, color: JuhColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                fontSize: JuhSizes.fontSm,
                color: JuhColors.primaryInk,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Form field label with optional required asterisk.
class FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  final bool isAr;
  const FieldLabel({
    super.key,
    required this.label,
    required this.isAr,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
        if (required)
          const Text('*',
              style: TextStyle(
                  color: JuhColors.error, fontWeight: FontWeight.bold)),
        if (required) const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: JuhSizes.fontSm,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Styled text form field.
class JuhFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isAr;
  final TextInputType keyboardType;
  final String? helperText;
  final String? Function(String?)? validator;
  final bool obscureText;

  const JuhFormField({
    super.key,
    required this.controller,
    required this.hint,
    required this.isAr,
    this.keyboardType = TextInputType.text,
    this.helperText,
    this.validator,
    this.obscureText = false,
  });

  @override
  State<JuhFormField> createState() => _JuhFormFieldState();
}

class _JuhFormFieldState extends State<JuhFormField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isObscure = widget.obscureText && _hidden;

    return Column(
      crossAxisAlignment: widget.isAr
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: isObscure,
          textAlign: widget.isAr ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
              fontSize: JuhSizes.fontMd, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: cs.surface,
            hintText: widget.hint,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: JuhSizes.md, vertical: 14),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
              borderSide: BorderSide(color: cs.outlineVariant, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
              borderSide: BorderSide(color: cs.outlineVariant, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
              borderSide:
                  const BorderSide(color: JuhColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
              borderSide: const BorderSide(color: JuhColors.error, width: 1),
            ),
          ),
          validator: widget.validator,
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 5),
          Text(
            widget.helperText!,
            textAlign: widget.isAr ? TextAlign.right : TextAlign.left,
            style: TextStyle(
                fontSize: JuhSizes.fontXs, color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

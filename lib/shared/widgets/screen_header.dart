import 'package:flutter/material.dart';
import 'package:cruzo/core/theme/dls/dls.dart';

/// Page-level header — title, subtitle, optional primary action button.
/// Matches the JSX page header pattern (h2 + muted subtitle + btn primary).
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h2),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.darkFg2),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          FilledButton.icon(
            onPressed: onAction,
            icon: Icon(actionIcon ?? Icons.add_rounded, size: 17),
            label: Text(actionLabel!),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.darkBg2,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }
}

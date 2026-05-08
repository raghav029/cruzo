import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CruzoCard extends StatelessWidget {
  const CruzoCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.action,
    this.flush = false,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? action;
  final bool flush;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CardHead(title: title, subtitle: subtitle, action: action),
          const Divider(height: 1, thickness: 1, color: AppColors.darkLine),
          flush
              ? child
              : Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
        ],
      ),
    );
  }
}

class _CardHead extends StatelessWidget {
  const _CardHead({required this.title, this.subtitle, this.action});

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.h4),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

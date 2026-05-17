import 'package:flutter/material.dart';
import 'package:cruzo/core/theme/dls/dls.dart';
import 'sparkline.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final String? delta;
  final bool? deltaUp;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;
  final List<double>? sparkData;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.subtitle,
    this.delta,
    this.deltaUp,
    this.onTap,
    this.sparkData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBg2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkLine),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 16, color: color),
                ),
                const Spacer(),
                if (delta != null)
                  _DeltaChip(delta: delta!, up: deltaUp ?? true),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.darkFg2,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.darkFg0,
                letterSpacing: -0.5,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(color: AppColors.darkFg2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (sparkData != null && sparkData!.length >= 2) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 28,
                child: Sparkline(
                  data: sparkData!,
                  color: color,
                  height: 28,
                  width: double.infinity,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final String delta;
  final bool up;

  const _DeltaChip({required this.delta, required this.up});

  @override
  Widget build(BuildContext context) {
    final color = up ? AppColors.good : AppColors.bad;
    final bg = up ? AppColors.goodBg : AppColors.badBg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            delta,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

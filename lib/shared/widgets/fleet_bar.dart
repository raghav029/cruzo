import 'package:flutter/material.dart';
import 'package:cruzo/core/theme/dls/dls.dart';

class FleetBarSegment {
  final String label;
  final int count;
  final Color color;

  const FleetBarSegment({
    required this.label,
    required this.count,
    required this.color,
  });
}

class FleetBar extends StatelessWidget {
  final String label;
  final int total;
  final List<FleetBarSegment> segments;

  const FleetBar({
    super.key,
    required this.label,
    required this.total,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.darkFg2,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$total total',
              style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                ...segments.map((s) {
                  final frac = total == 0 ? 0.0 : s.count / total;
                  return Expanded(
                    flex: (frac * 1000).round().toInt(),
                    child: ColoredBox(color: s.color),
                  );
                }),
                Expanded(
                  flex: total == 0
                      ? 1000
                      : (1000 - segments.fold(0, (p, s) => p + ((s.count / total) * 1000).round()))
                          .clamp(0, 1000)
                          .toInt(),
                  child: ColoredBox(color: AppColors.darkBg3),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          children: segments.map((s) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: s.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  s.label,
                  style: AppTextStyles.caption.copyWith(color: AppColors.darkFg2),
                ),
                const SizedBox(width: 4),
                Text(
                  '${s.count}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.darkFg0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

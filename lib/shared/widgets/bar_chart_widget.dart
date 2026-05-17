import 'package:flutter/material.dart';
import 'package:cruzo/core/theme/dls/dls.dart';

class BarChartData {
  final String label;
  final double value;
  const BarChartData({required this.label, required this.value});
}

class BarChartWidget extends StatelessWidget {
  final List<BarChartData> data;
  final double height;
  final Color color;

  const BarChartWidget({
    super.key,
    required this.data,
    this.height = 160,
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height);
    final max = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final safeMax = max == 0 ? 1.0 : max;

    return SizedBox(
      height: height + 20, // +20 for labels
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < data.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _Bar(
                item: data[i],
                fraction: data[i].value / safeMax,
                color: color,
                maxHeight: height,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final BarChartData item;
  final double fraction;
  final Color color;
  final double maxHeight;

  const _Bar({
    required this.item,
    required this.fraction,
    required this.color,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final barH = (fraction * maxHeight).clamp(2.0, maxHeight);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: maxHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: barH,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color, color.withAlpha(128)],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 9.5,
            color: AppColors.darkFg3,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}

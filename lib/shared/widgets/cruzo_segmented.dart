import 'package:flutter/material.dart';
import 'package:cruzo/core/theme/dls/dls.dart';

class CruzoSegmented extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const CruzoSegmented({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < labels.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: i == selected ? AppColors.darkBg0 : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                  boxShadow: i == selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(51),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: i == selected ? AppColors.darkFg0 : AppColors.darkFg3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

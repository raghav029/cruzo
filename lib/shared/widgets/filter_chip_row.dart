import 'package:flutter/material.dart';
import 'package:cruzo/core/theme/dls/dls.dart';

/// Generic horizontal scrollable filter chip row.
/// [filters] is a list of (label, value) tuples. value=null means "All".
class FilterChipRow<T> extends StatelessWidget {
  final T? selected;
  final List<(String, T?)> filters;
  final void Function(T?) onTap;

  const FilterChipRow({
    super.key,
    required this.selected,
    required this.filters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadH),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final (label, value) = filters[i];
          final active = selected == value;
          return GestureDetector(
            onTap: () => onTap(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.darkBg2,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: active ? AppColors.accent : AppColors.darkLine,
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: active ? Colors.black : AppColors.darkFg2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.grey900);
  static const h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.grey900);
  static const h3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.grey900);
  static const h4 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.grey900);
  static const bodyLg = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.grey700);
  static const body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.grey700);
  static const bodySm = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.grey500);
  static const label = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.grey600);
  static const caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.grey400);
}

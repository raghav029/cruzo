import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const h1 = TextStyle(
      fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.darkFg0,
      letterSpacing: -0.3);
  static const h2 = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.darkFg0,
      letterSpacing: -0.2);
  static const h3 = TextStyle(
      fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkFg0,
      letterSpacing: -0.1);
  static const h4 = TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkFg0);
  static const bodyLg = TextStyle(
      fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.darkFg1);
  static const body = TextStyle(
      fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.darkFg1);
  static const bodySm = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.darkFg2);
  static const label = TextStyle(
      fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.darkFg1);
  static const caption = TextStyle(
      fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.darkFg3);
  static const mono = TextStyle(
      fontSize: 12.5, color: AppColors.darkFg1, letterSpacing: 0.1);
  static const monoSm = TextStyle(
      fontSize: 11, color: AppColors.darkFg2, letterSpacing: 0.1);
  static const kpiValue = TextStyle(
      fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.darkFg0,
      letterSpacing: -0.5);
  static const kpiLabel = TextStyle(
      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkFg3,
      letterSpacing: 0.6);
  static const tableHeader = TextStyle(
      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkFg3,
      letterSpacing: 0.4);
  static const tableCell = TextStyle(
      fontSize: 12.5, fontWeight: FontWeight.w400, color: AppColors.darkFg1);
}

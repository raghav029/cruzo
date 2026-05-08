import 'package:flutter/material.dart';

// Cruzo DLS — Shadow / Elevation Tokens
// Source: cursor_design/styles.css  --shadow-1 / --shadow-2

abstract final class AppShadows {
  // Dark theme
  // --shadow-1: 0 1px 0 oklch(1 0 0 / 0.04) inset, 0 1px 2px oklch(0 0 0 / 0.4)
  static const List<BoxShadow> shadow1Dark = [
    BoxShadow(
      color: Color(0x0AFFFFFF), // inset highlight
      offset: Offset(0, 1),
      blurRadius: 0,
      spreadRadius: 0,
      blurStyle: BlurStyle.inner,
    ),
    BoxShadow(
      color: Color(0x66000000), // 0.4 opacity
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  // --shadow-2: 0 1px 0 oklch(1 0 0 / 0.05) inset, 0 8px 24px oklch(0 0 0 / 0.5)
  static const List<BoxShadow> shadow2Dark = [
    BoxShadow(
      color: Color(0x0DFFFFFF),
      offset: Offset(0, 1),
      blurRadius: 0,
      spreadRadius: 0,
      blurStyle: BlurStyle.inner,
    ),
    BoxShadow(
      color: Color(0x80000000), // 0.5 opacity
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  // Light theme
  // --shadow-1: 0 1px 2px oklch(0 0 0 / 0.04)
  static const List<BoxShadow> shadow1Light = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  // --shadow-2: 0 8px 24px oklch(0 0 0 / 0.08)
  static const List<BoxShadow> shadow2Light = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  // Accent glow: used on brand-mark, selected states
  // 0 0 0 2px color-mix(in oklab, accent 25%, transparent)
  static List<BoxShadow> accentGlow({double spread = 2}) => [
    BoxShadow(
      color: Color(0x402DD4BF), // accent ~25%
      offset: Offset.zero,
      blurRadius: 0,
      spreadRadius: spread,
    ),
  ];

  // Accent halo for brand-mark:
  // 0 0 0 1px oklch(1 0 0 / 0.06), 0 6px 16px color-mix(accent 30%)
  static const List<BoxShadow> brandMark = [
    BoxShadow(
      color: Color(0x0FFFFFFF),
      offset: Offset.zero,
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Color(0x4D2DD4BF), // accent 30%
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];
}

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Cruzo DLS — Typography
// Source: cursor_design/styles.css  base=13px, lineHeight=1.45
// Fonts: Inter (sans) · JetBrains Mono (mono)
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppTypography {
  static const String fontFamily     = 'Inter';
  static const String monoFontFamily = 'JetBrains Mono';

  // ── Page / section headings ─────────────────────────────────────────────────
  // Used for topbar title (.topbar h1 = 15px w600) and brand name (15px w700)
  static const pageTitle = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.01 * 15);

  // Card head h3  (.card-head h3 = 13px w600)
  static const sectionTitle = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.005 * 13);

  // ── KPI / metric ────────────────────────────────────────────────────────────
  // .kpi-value = 26px w700, tabular nums
  static const kpiValue = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 26,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // .kpi-label = 11px w600 uppercase 0.06em
  static const kpiLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.06 * 11,
  );

  // .kpi-foot = 11.5px
  static const kpiFoot = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w400);

  // ── Body copy ───────────────────────────────────────────────────────────────
  // Base body = 13px  (.table td, nav-item, search input)
  static const body = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);

  // .card-head .sub = 11.5px
  static const bodySm = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w400);

  // ── Labels ──────────────────────────────────────────────────────────────────
  // .btn = 12.5px w500  |  .name in user-chip = 12.5px w500
  static const label = TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500);

  // nav-label / th = 10.5–11px w600 uppercase 0.04–0.06em
  static const labelXs = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.06 * 11,
  );

  // .crumbs = 12px, .role in user-chip = 10.5px
  static const caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w400);
  static const captionSm = TextStyle(fontSize: 10.5, fontWeight: FontWeight.w400);

  // ── Table ───────────────────────────────────────────────────────────────────
  // th = 11px w500 uppercase 0.04em
  static const tableHeader = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.04 * 11,
  );

  // td = 12.5px w400
  static const tableCell = TextStyle(fontSize: 12.5, fontWeight: FontWeight.w400);

  // td.strong = 12.5px w500
  static const tableCellStrong = TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500);

  // td.id = mono 11.5px  (font-family mono)
  static const tableId = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    fontFamily: monoFontFamily,
    letterSpacing: 0.02,
  );

  // ── Monospace ────────────────────────────────────────────────────────────────
  // .otp = mono 12px 0.18em
  static const mono = TextStyle(
    fontSize: 12.5,
    fontFamily: monoFontFamily,
    letterSpacing: 0.1,
  );

  static const monoSm = TextStyle(
    fontSize: 11,
    fontFamily: monoFontFamily,
    letterSpacing: 0.04,
  );

  static const otp = TextStyle(
    fontSize: 12,
    fontFamily: monoFontFamily,
    letterSpacing: 0.18 * 12,
    fontWeight: FontWeight.w500,
  );

  // ── Brand / nav ──────────────────────────────────────────────────────────────
  // .brand-name = 15px w700  |  .brand-name small = 10.5px w500 uppercase
  static const brandName = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.01 * 15);
  static const brandSub = TextStyle(
    fontSize: 10.5, fontWeight: FontWeight.w500, letterSpacing: 0.04 * 10.5);

  // nav-item = 13px  (inherits body)
  static const navItem = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
}

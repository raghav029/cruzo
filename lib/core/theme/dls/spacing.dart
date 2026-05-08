// Cruzo DLS — Spacing Scale
// 4px grid. Values derived from cursor_design/styles.css padding/gap/margin usage.

abstract final class AppSpacing {
  static const double p2  = 2.0;   // micro (badge padding-v, otp padding-v)
  static const double p4  = 4.0;   // xs  (nav-item margin, dot gap)
  static const double p5  = 5.0;   // tag gap, field gap
  static const double p6  = 6.0;   // tag padding-h, badge padding-h, brand gap
  static const double p7  = 7.0;   // btn padding-v, input padding-v
  static const double p8  = 8.0;   // sm  (otp padding-h, search padding-h)
  static const double p10 = 10.0;  // nav-item padding, input padding-h
  static const double p12 = 12.0;  // btn padding-h, card padding sm, trip-card
  static const double p14 = 14.0;  // btn padding-h (default), table cell padding-h
  static const double p16 = 16.0;  // md  (kpi/card-pad padding, sidebar h-pad)
  static const double p18 = 18.0;  // card-pad, card-head padding-h
  static const double p20 = 20.0;  // topbar icon gap area
  static const double p24 = 24.0;  // lg  (page padding-h, topbar padding-h)
  static const double p28 = 28.0;  // page padding-h (wider)
  static const double p32 = 32.0;  // xl
  static const double p48 = 48.0;  // empty-state padding

  // Semantic aliases
  static const double none = 0;
  static const double xs   = p4;
  static const double sm   = p8;
  static const double md   = p16;
  static const double lg   = p24;
  static const double xl   = p32;
  static const double xxl  = p48;

  // Component-specific
  static const double pagePadH   = p28; // .page padding: 24px 28px
  static const double pagePadV   = p24;
  static const double cardPadH   = p18; // .card-pad padding: 16px 18px
  static const double cardPadV   = p16;
  static const double topbarH    = p56; // topbar height
  static const double sidebarW   = 248.0; // .app sidebar width
  static const double p56        = 56.0;
}

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Cruzo DLS — Color Tokens
// Source of truth: cursor_design/styles.css (dark-first, hue 250 neutrals)
// Accent: teal hue 185  |  Base font size: 13px
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppColors {
  // ── Accent / Brand ─────────────────────────────────────────────────────────
  // oklch(0.78 0.14 185) / oklch(0.85 0.15 185) / oklch(0.55 0.10 185)
  static const accent       = Color(0xFF2DD4BF);
  static const accentStrong = Color(0xFF5EEBD8);
  static const accentDim    = Color(0xFF1A8A7E);
  static const accentBg     = Color(0x262DD4BF); // ~15% opacity on dark
  static const accentFg     = Color(0xFF0D2421); // text on accent button

  // ── Dark theme backgrounds (--bg-0 … --bg-3) ───────────────────────────────
  // oklch(0.16…) → oklch(0.26…)  hue 250
  static const darkBg0        = Color(0xFF0E1019); // sidebar / outermost shell
  static const darkBg1        = Color(0xFF121520); // main content bg
  static const darkBg2        = Color(0xFF191C2C); // cards / elevated surfaces
  static const darkBg3        = Color(0xFF21253A); // inputs / hover / pressed

  // ── Dark theme borders ──────────────────────────────────────────────────────
  static const darkLine       = Color(0xFF2B2F48); // --line
  static const darkLineStrong = Color(0xFF3A3F5C); // --line-strong

  // ── Dark theme text (--fg-0 … --fg-3) ──────────────────────────────────────
  static const darkFg0 = Color(0xFFF0F3FC); // primary text
  static const darkFg1 = Color(0xFFCDD5EE); // secondary text
  static const darkFg2 = Color(0xFF8A9CC0); // muted
  static const darkFg3 = Color(0xFF566080); // very muted / placeholders

  // ── Light theme backgrounds ─────────────────────────────────────────────────
  static const lightBg0        = Color(0xFFF9FAFD);
  static const lightBg1        = Color(0xFFF3F5FB);
  static const lightBg2        = Color(0xFFEBEEF7);
  static const lightBg3        = Color(0xFFE0E4F0);
  static const lightLine       = Color(0xFFD8DCF0);
  static const lightLineStrong = Color(0xFFBCC4DC);

  // ── Light theme text ────────────────────────────────────────────────────────
  static const lightFg0 = Color(0xFF1D2137);
  static const lightFg1 = Color(0xFF3A4060);
  static const lightFg2 = Color(0xFF5C657E);
  static const lightFg3 = Color(0xFF7D879C);

  // ── Semantic (shared across themes) ────────────────────────────────────────
  // CSS: --good / --warn / --bad / --info / --violet
  static const good     = Color(0xFF34D399); // oklch(0.78 0.14 155)
  static const goodBg   = Color(0x2234D399); // ~13% fill
  static const warn     = Color(0xFFFBBF24); // oklch(0.82 0.14 75)
  static const warnBg   = Color(0x22FBBF24);
  static const bad      = Color(0xFFF87171); // oklch(0.72 0.16 25)
  static const badBg    = Color(0x22F87171);
  static const info     = Color(0xFF60A5FA); // oklch(0.78 0.12 240)
  static const infoBg   = Color(0x2260A5FA);
  static const violet   = Color(0xFFA78BFA); // oklch(0.74 0.13 295)
  static const violetBg = Color(0x22A78BFA);

  // ── Aliases — semantic tokens (dark-first) ──────────────────────────────────
  static const primary       = accent;
  static const primaryLight  = accentBg;
  static const primaryDark   = accentDim;

  static const background    = darkBg1;
  static const surface       = darkBg2;
  static const surfaceRaised = darkBg3;

  static const border        = darkLine;
  static const borderStrong  = darkLineStrong;

  static const textPrimary   = darkFg0;
  static const textSecondary = darkFg1;
  static const textMuted     = darkFg2;
  static const textSubtle    = darkFg3;

  static const sidebarBg         = darkBg0;
  static const sidebarActive      = darkBg3;
  static const sidebarText        = darkFg2;
  static const sidebarTextActive  = darkFg0;
  static const sidebarAccent      = accent;

  static const cardBorder  = darkLine;
  static const divider     = darkLine;

  // Semantic aliases matching existing code
  static const success       = good;
  static const successLight  = goodBg;
  static const successBg     = goodBg;
  static const warning       = warn;
  static const warningLight  = warnBg;
  static const warningBg     = warnBg;
  static const error         = bad;
  static const errorLight    = badBg;
  static const errorBg       = badBg;
  static const infoLight     = infoBg;

  // Kept for legacy widgets still using light greys
  static const white       = Color(0xFFFFFFFF);
  static const black       = Color(0xFF000000);
  static const transparent = Color(0x00000000);

  // Neutral scale (legacy — prefer dark/light bg tokens above)
  static const grey50  = Color(0xFFF9FAFB);
  static const grey100 = Color(0xFFF3F4F6);
  static const grey200 = Color(0xFFE5E7EB);
  static const grey300 = Color(0xFFD1D5DB);
  static const grey400 = Color(0xFF9CA3AF);
  static const grey500 = Color(0xFF6B7280);
  static const grey600 = Color(0xFF4B5563);
  static const grey700 = Color(0xFF374151);
  static const grey800 = Color(0xFF1F2937);
  static const grey900 = Color(0xFF111827);

  // Shadow convenience
  static const cardShadow = Color(0x40000000);
}

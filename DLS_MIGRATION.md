# Cruzo DLS Migration

Source of truth: `test1/cursor_design/styles.css`

## What Changed (Foundation — Done)

| File | Change |
|---|---|
| `dls/colors.dart` | Rewrote. Canonical `AppColors` with dark+light tokens matching CSS oklch values |
| `dls/typography.dart` | Rewrote. Inter 13px base, JetBrains Mono, exact CSS scale (not Material defaults) |
| `dls/radii.dart` | Fixed. sm=6, md=10, lg=14, pill=999 (was 8/12/16) |
| `dls/spacing.dart` | Expanded. Full 4px-grid matching CSS padding/gap values |
| `dls/shadows.dart` | New. shadow1Dark/shadow2Dark, shadow1Light/shadow2Light, brandMark glow |
| `dls/dls.dart` | New. Barrel — `import 'package:cruzo/core/theme/dls/dls.dart'` |
| `app_colors.dart` | Now re-exports `dls/colors.dart`. All existing imports unchanged |

## Screen Migration Checklist

Screens still using light-mode patterns (white cards, grey borders):

- [ ] `login_screen.dart` — white card (`AppColors.white`) on dark bg → use `AppColors.darkBg2`
  - Container `color: AppColors.white` → `color: AppColors.darkBg2`
  - `border: Border.all(color: AppColors.grey200)` → `color: AppColors.darkLine`
- [ ] Any screen using `AppColors.grey*` directly → map to dark tokens

## Token Mapping (CSS → Dart)

```
--bg-0        → AppColors.darkBg0      sidebar
--bg-1        → AppColors.darkBg1      main content
--bg-2        → AppColors.darkBg2      cards
--bg-3        → AppColors.darkBg3      inputs, hover
--line        → AppColors.darkLine
--line-strong → AppColors.darkLineStrong
--fg-0        → AppColors.darkFg0      primary text
--fg-1        → AppColors.darkFg1      secondary
--fg-2        → AppColors.darkFg2      muted
--fg-3        → AppColors.darkFg3      placeholder
--accent      → AppColors.accent       #2DD4BF
--good        → AppColors.good
--warn        → AppColors.warn
--bad         → AppColors.bad
--info        → AppColors.info
--violet      → AppColors.violet
--radius-sm   → AppRadii.sm = 6
--radius      → AppRadii.md = 10
--radius-lg   → AppRadii.lg = 14
```

## DLS Import Pattern (new code)

```dart
import 'package:cruzo/core/theme/dls/dls.dart';

// Use:
AppColors.darkBg2      // backgrounds
AppColors.accent       // brand color
AppTypography.body     // 13px w400
AppTypography.kpiValue // 26px w700
AppRadii.sm            // 6.0
AppSpacing.cardPadH    // 18.0
AppShadows.shadow1Dark // BoxShadow list
```

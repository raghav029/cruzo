# SDUI (Server-Driven UI) — Slice Merchant

## Overview

BE-driven screens receive styling, layout, and content from the API. Use the project's parsing utilities from `lib/app/core_ui/sdui/common_utils/` — never parse hex strings or font tokens manually.

---

## Color Parsing

```dart
import 'package:slice_merchant/app/core_ui/sdui/common_utils/color.dart';
```

| Function | Input | Output | Use when |
|----------|-------|--------|----------|
| `sduiParseHexColor(dynamic color)` | `#RRGGBB` or `#RRGGBBAA` string | `Color?` | API returns a hex string |
| `sduiResolveColor(Object? color, BuildContext context)` | `Color` or hex string | `Color?` | Value may be a Color or a string; returns `null` if unparseable |

`#RRGGBBAA` is automatically converted to Flutter's `#AARRGGBB` format.

```dart
// Parse a hex string from the API
Color? parsed = sduiParseHexColor(apiResponse.backgroundColor);

// Resolve with DLS fallback
Color resolved = sduiResolveColor(apiResponse.textColor, context)
    ?? context.dls.textPrimary;
```

---

## Typography Parsing

```dart
import 'package:slice_merchant/app/core_ui/sdui/common_utils/typography.dart';
```

| Function | Input | Output |
|----------|-------|--------|
| `DLSTextStyle.fromString(String token)` | Named DLS style (`'header2'`, `'bodyNormal'`, `'caption'`) | `TextStyle?` |
| `sduiFontSizeForToken(String token)` | Size token (`'xxxxl'`…`'xxxs'`) | `double?` |
| `sduiParseFontWeight(String weight)` | `'light'`, `'regular'`, `'medium'`, `'semibold'`, `'bold'` | `FontWeight` |
| `sduiHeightFactorForSize(String token)` | Size token | `double?` (for `TextStyle.height`) |

**Size token scale:** `xxxxl` → `xxxl` → `xxl` → `xl` → `lg` → `md` → `sm` → `xs` → `xxs` → `xxxs`

---

## Full Resolution Patterns

### Color

```dart
Color resolveColor(BuildContext context, {String? token, String? hex}) {
  if (token != null) {
    return SliceTheme.instance
        .getColors(SliceTheme.instance.mode)
        .colorFromToken(token) ?? context.dls.textPrimary;
  }
  if (hex != null) {
    return sduiParseHexColor(hex) ?? context.dls.textPrimary;
  }
  return context.dls.textPrimary;
}
```

### Text Style

```dart
TextStyle resolveTextStyle({
  String? styleToken,
  String? sizeToken,
  dynamic weight,
}) {
  final base = DLSTextStyle.fromString(styleToken ?? '') ?? DLSTextStyle.bodyNormal();
  return base.copyWith(
    fontWeight: weight != null ? sduiParseFontWeight(weight.toString()) : null,
    fontSize: sizeToken != null ? sduiFontSizeForToken(sizeToken) : null,
    height: sizeToken != null ? sduiHeightFactorForSize(sizeToken) : null,
  );
}
```

---

## Key Rules

- Always fall back to a DLS token (`context.dls.textPrimary`, `DLSTextStyle.bodyNormal()`) — never fall back to hardcoded values
- Never parse hex strings or font weights manually — use the utility functions
- When both `styleToken` and `sizeToken` arrive from the API, apply `sizeToken` via `copyWith` — the size token overrides the size embedded in the named style
- For widget-level SDUI, load `/slice-flutter-ui` for the DLS component layer

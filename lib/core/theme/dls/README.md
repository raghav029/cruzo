Design Language System (DLS)

This folder contains tokens and shared component styles used across the app.

Tokens to include:
- colors.dart: semantic and palette colors
- typography.dart: text styles and font scale
- spacing.dart: spacing scale constants
- radii.dart: border radii
- elevation.dart: shadow/elevation tokens
- components.dart: shared component styles (buttons, inputs)

Guideline: UI files should import from `package:cruzo/core/theme/dls/dls.dart` to consume tokens.
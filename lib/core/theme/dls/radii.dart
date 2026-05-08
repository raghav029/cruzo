// Cruzo DLS — Border Radii
// Source: cursor_design/styles.css  --radius-sm / --radius / --radius-lg

abstract final class AppRadii {
  static const double xs   = 4.0;  // tight corners (kbd, scrollbar-thumb)
  static const double sm   = 6.0;  // --radius-sm: buttons, inputs, tags
  static const double md   = 10.0; // --radius: cards, nav items, icons
  static const double lg   = 14.0; // --radius-lg: large cards, modals
  static const double pill = 999.0; // border-radius: 999px (tags, badges, chips)
}

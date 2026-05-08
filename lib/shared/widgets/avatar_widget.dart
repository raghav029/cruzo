import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.name,
    this.radius = 16,
    this.fontSize,
  });

  final String name;
  final double radius;
  final double? fontSize;

  static Color _colorFromName(String name) {
    final hash = name.codeUnits.fold(0, (h, c) => (h * 31 + c) & 0xFFFFFF);
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.45).toColor();
  }

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = _colorFromName(name);
    final fg = bg.computeLuminance() > 0.3 ? Colors.black87 : Colors.white;
    final fs = fontSize ?? (radius * 0.72);
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        _initials,
        style: TextStyle(
          color: fg,
          fontSize: fs,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

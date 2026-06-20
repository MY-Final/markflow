import 'package:flutter/material.dart';

@immutable
class MarkFlowTheme extends ThemeExtension<MarkFlowTheme> {
  final Color background;
  final Color surface;
  final Color surfaceWarm;
  final Color text;
  final Color secondaryText;
  final Color tertiaryText;
  final Color ghostText;
  final Color border;
  final Color borderLight;
  final Color primary;
  final Color primaryLight;
  final Color primaryMist;
  final Color primaryGlow;
  final Color hover;
  final Color selected;
  final Color explorerBackground;
  final Color toolbarBackground;
  final Color statusBarBackground;

  const MarkFlowTheme({
    required this.background,
    required this.surface,
    required this.surfaceWarm,
    required this.text,
    required this.secondaryText,
    required this.tertiaryText,
    required this.ghostText,
    required this.border,
    required this.borderLight,
    required this.primary,
    required this.primaryLight,
    required this.primaryMist,
    required this.primaryGlow,
    required this.hover,
    required this.selected,
    required this.explorerBackground,
    required this.toolbarBackground,
    required this.statusBarBackground,
  });

  @override
  MarkFlowTheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceWarm,
    Color? text,
    Color? secondaryText,
    Color? tertiaryText,
    Color? ghostText,
    Color? border,
    Color? borderLight,
    Color? primary,
    Color? primaryLight,
    Color? primaryMist,
    Color? primaryGlow,
    Color? hover,
    Color? selected,
    Color? explorerBackground,
    Color? toolbarBackground,
    Color? statusBarBackground,
  }) {
    return MarkFlowTheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceWarm: surfaceWarm ?? this.surfaceWarm,
      text: text ?? this.text,
      secondaryText: secondaryText ?? this.secondaryText,
      tertiaryText: tertiaryText ?? this.tertiaryText,
      ghostText: ghostText ?? this.ghostText,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryMist: primaryMist ?? this.primaryMist,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      hover: hover ?? this.hover,
      selected: selected ?? this.selected,
      explorerBackground: explorerBackground ?? this.explorerBackground,
      toolbarBackground: toolbarBackground ?? this.toolbarBackground,
      statusBarBackground: statusBarBackground ?? this.statusBarBackground,
    );
  }

  @override
  MarkFlowTheme lerp(MarkFlowTheme? other, double t) {
    if (other is! MarkFlowTheme) return this;
    return MarkFlowTheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceWarm: Color.lerp(surfaceWarm, other.surfaceWarm, t)!,
      text: Color.lerp(text, other.text, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      tertiaryText: Color.lerp(tertiaryText, other.tertiaryText, t)!,
      ghostText: Color.lerp(ghostText, other.ghostText, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryMist: Color.lerp(primaryMist, other.primaryMist, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      explorerBackground: Color.lerp(explorerBackground, other.explorerBackground, t)!,
      toolbarBackground: Color.lerp(toolbarBackground, other.toolbarBackground, t)!,
      statusBarBackground: Color.lerp(statusBarBackground, other.statusBarBackground, t)!,
    );
  }

  static MarkFlowTheme get light {
    return const MarkFlowTheme(
      background: Color(0xFFF6F3EC),
      surface: Color(0xFFFFFFFF),
      surfaceWarm: Color(0xFFF0EBE0),
      text: Color(0xFF1A1A18),
      secondaryText: Color(0xFF3D3D38),
      tertiaryText: Color(0xFF8A8A80),
      ghostText: Color(0xFFB8B8AE),
      border: Color(0xFFE8E1D3),
      borderLight: Color(0xFFF0EBE0),
      primary: Color(0xFF2D5A3D),
      primaryLight: Color(0xFF3A7A52),
      primaryMist: Color(0xFFE8F0EB),
      primaryGlow: Color(0xFFD4E8DA),
      hover: Color(0xFFF0EBE0),
      selected: Color(0xFFE8F0EB),
      explorerBackground: Color(0xFFF6F3EC),
      toolbarBackground: Color(0xFFFFFFFF),
      statusBarBackground: Color(0xFFF0EBE0),
    );
  }

  static MarkFlowTheme get dark {
    return const MarkFlowTheme(
      background: Color(0xFF222120),
      surface: Color(0xFF2C2A27),
      surfaceWarm: Color(0xFF353230),
      text: Color(0xFFE5E1DA),
      secondaryText: Color(0xFFB8B4AC),
      tertiaryText: Color(0xFF7A7770),
      ghostText: Color(0xFF5A5850),
      border: Color(0xFF3A3835),
      borderLight: Color(0xFF302E2B),
      primary: Color(0xFF4FAA70),
      primaryLight: Color(0xFF5FC085),
      primaryMist: Color(0xFF1C2E22),
      primaryGlow: Color(0xFF253A2C),
      hover: Color(0xFF353230),
      selected: Color(0xFF1C2E22),
      explorerBackground: Color(0xFF222120),
      toolbarBackground: Color(0xFF2C2A27),
      statusBarBackground: Color(0xFF2C2A27),
    );
  }
}

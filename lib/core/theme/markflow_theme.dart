import 'package:flutter/material.dart';

@immutable
class MarkFlowTheme extends ThemeExtension<MarkFlowTheme> {
  final Color background;
  final Color surface;
  final Color text;
  final Color secondaryText;
  final Color border;
  final Color primary;
  final Color hover;
  final Color selected;
  final Color explorerBackground;
  final Color toolbarBackground;
  final Color statusBarBackground;

  const MarkFlowTheme({
    required this.background,
    required this.surface,
    required this.text,
    required this.secondaryText,
    required this.border,
    required this.primary,
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
    Color? text,
    Color? secondaryText,
    Color? border,
    Color? primary,
    Color? hover,
    Color? selected,
    Color? explorerBackground,
    Color? toolbarBackground,
    Color? statusBarBackground,
  }) {
    return MarkFlowTheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      text: text ?? this.text,
      secondaryText: secondaryText ?? this.secondaryText,
      border: border ?? this.border,
      primary: primary ?? this.primary,
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
      text: Color.lerp(text, other.text, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      explorerBackground: Color.lerp(explorerBackground, other.explorerBackground, t)!,
      toolbarBackground: Color.lerp(toolbarBackground, other.toolbarBackground, t)!,
      statusBarBackground: Color.lerp(statusBarBackground, other.statusBarBackground, t)!,
    );
  }

  static MarkFlowTheme get light {
    return const MarkFlowTheme(
      background: Color(0xFFF7F8FA),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF111827),
      secondaryText: Color(0xFF6B7280),
      border: Color(0xFFE5E7EB),
      primary: Color(0xFF3B82F6),
      hover: Color(0xFFF3F4F6),
      selected: Color(0xFFEFF6FF),
      explorerBackground: Color(0xFFF7F8FA),
      toolbarBackground: Color(0xFFFFFFFF),
      statusBarBackground: Color(0xFFF7F8FA),
    );
  }

  static MarkFlowTheme get dark {
    return const MarkFlowTheme(
      background: Color(0xFF0F1115),
      surface: Color(0xFF171A21),
      text: Color(0xFFF3F4F6),
      secondaryText: Color(0xFF9CA3AF),
      border: Color(0xFF2A2F3A),
      primary: Color(0xFF60A5FA),
      hover: Color(0xFF1E2330),
      selected: Color(0xFF2A3441),
      explorerBackground: Color(0xFF151718),
      toolbarBackground: Color(0xFF171A21),
      statusBarBackground: Color(0xFF151718),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/features/settings/settings_panel.dart';

class CustomTitleBar extends StatefulWidget {
  final String? currentFileName;
  final bool isSaved;
  final VoidCallback? onSettingsTap;

  const CustomTitleBar({
    super.key,
    this.currentFileName,
    this.isSaved = true,
    this.onSettingsTap,
  });

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _CustomTitleBarState extends State<CustomTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
      _checkMaximized();
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _checkMaximized() async {
    final maximized = await windowManager.isMaximized();
    if (mounted) {
      setState(() => _isMaximized = maximized);
    }
  }

  @override
  void onWindowMaximize() {
    if (mounted) setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    if (mounted) setState(() => _isMaximized = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.toolbarBackground,
        border: Border(
          bottom: BorderSide(
            color: theme.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) => windowManager.startDragging(),
              onDoubleTap: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MarkFlow',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.tertiaryText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (widget.currentFileName != null) ...[
                      Text(
                        ' — ',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.ghostText,
                        ),
                      ),
                      Text(
                        widget.currentFileName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.tertiaryText,
                        ),
                      ),
                      if (!widget.isSaved)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: theme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          _TitleBarButton(
            icon: Icons.settings_rounded,
            tooltip: 'Settings',
            onTap: widget.onSettingsTap ?? () => SettingsPanel.show(context),
            theme: theme,
          ),

          const SizedBox(width: 4),

          _buildWindowControls(theme),
        ],
      ),
    );
  }

  Widget _buildWindowControls(MarkFlowTheme theme) {
    return Row(
      children: [
        _WindowButton(
          icon: Icons.remove,
          onTap: () => windowManager.minimize(),
          theme: theme,
        ),
        _WindowButton(
          icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
          onTap: () async {
            if (await windowManager.isMaximized()) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
          theme: theme,
        ),
        _WindowButton(
          icon: Icons.close,
          onTap: () => windowManager.close(),
          theme: theme,
          isClose: true,
        ),
      ],
    );
  }
}

class _TitleBarButton extends StatefulWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onTap;
  final MarkFlowTheme theme;

  const _TitleBarButton({
    required this.icon,
    this.tooltip,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _isHovered ? widget.theme.hover : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: _isHovered ? widget.theme.primary : widget.theme.tertiaryText,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip,
        child: button,
      );
    }
    return button;
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final MarkFlowTheme theme;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onTap,
    required this.theme,
    this.isClose = false,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 46,
          height: 40,
          color: _isHovered
              ? (widget.isClose
                  ? const Color(0xFFC45C4A)
                  : widget.theme.hover)
              : Colors.transparent,
          child: Icon(
            widget.icon,
            size: 16,
            color: _isHovered && widget.isClose
                ? Colors.white
                : widget.theme.tertiaryText,
          ),
        ),
      ),
    );
  }
}

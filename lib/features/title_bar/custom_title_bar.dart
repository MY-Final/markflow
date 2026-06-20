import 'package:flutter/material.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/features/settings/settings_panel.dart';

class CustomTitleBar extends StatelessWidget {
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
          // 中间可拖拽区域
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) {
                // 窗口拖拽
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
                    if (currentFileName != null) ...[
                      Text(
                        ' — ',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.ghostText,
                        ),
                      ),
                      Text(
                        currentFileName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.tertiaryText,
                        ),
                      ),
                      if (!isSaved)
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

          // 设置按钮
          _TitleBarButton(
            icon: Icons.settings_rounded,
            tooltip: 'Settings',
            onTap: onSettingsTap ?? () => SettingsPanel.show(context),
            theme: theme,
          ),

          const SizedBox(width: 4),

          // 窗口控制按钮 (Windows 风格)
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
          onTap: () {},
          theme: theme,
        ),
        _WindowButton(
          icon: Icons.crop_square,
          onTap: () {},
          theme: theme,
        ),
        _WindowButton(
          icon: Icons.close,
          onTap: () {},
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

import 'package:flutter/material.dart';
import 'package:markflow/core/theme/theme.dart';

class CustomTitleBar extends StatelessWidget {
  final String? currentFileName;
  final bool isSaved;

  const CustomTitleBar({
    super.key,
    this.currentFileName,
    this.isSaved = true,
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
          // Logo
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  size: 20,
                  color: theme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'MarkFlow',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.text,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 24),
          
          // 当前文件名
          if (currentFileName != null)
            Row(
              children: [
                Text(
                  currentFileName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.secondaryText,
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
            ),
          
          // 中间可拖拽区域
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) {
                // 窗口拖拽
              },
            ),
          ),
          
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
                  ? const Color(0xFFE81123)
                  : widget.theme.hover)
              : Colors.transparent,
          child: Icon(
            widget.icon,
            size: 16,
            color: _isHovered && widget.isClose
                ? Colors.white
                : widget.theme.secondaryText,
          ),
        ),
      ),
    );
  }
}

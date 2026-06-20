import 'package:flutter/material.dart';
import 'package:markflow/core/theme/theme.dart';

class ModernToolbar extends StatelessWidget {
  final VoidCallback? onBold;
  final VoidCallback? onItalic;
  final VoidCallback? onCode;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onTogglePreview;
  final bool isPreviewMode;

  const ModernToolbar({
    super.key,
    this.onBold,
    this.onItalic,
    this.onCode,
    this.onUndo,
    this.onRedo,
    this.onTogglePreview,
    this.isPreviewMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;
    
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
          // 左侧格式化按钮组
          _buildButtonGroup(
            theme,
            children: [
              _ToolbarButton(
                icon: Icons.undo_rounded,
                tooltip: 'Undo',
                onTap: onUndo,
                theme: theme,
              ),
              _ToolbarButton(
                icon: Icons.redo_rounded,
                tooltip: 'Redo',
                onTap: onRedo,
                theme: theme,
              ),
            ],
          ),
          
          const SizedBox(width: 8),
          
          _buildDivider(theme),
          
          const SizedBox(width: 8),
          
          _buildButtonGroup(
            theme,
            children: [
              _ToolbarButton(
                icon: Icons.format_bold_rounded,
                tooltip: 'Bold',
                onTap: onBold,
                theme: theme,
              ),
              _ToolbarButton(
                icon: Icons.format_italic_rounded,
                tooltip: 'Italic',
                onTap: onItalic,
                theme: theme,
              ),
              _ToolbarButton(
                icon: Icons.code_rounded,
                tooltip: 'Code',
                onTap: onCode,
                theme: theme,
              ),
            ],
          ),
          
          const Spacer(),
          
          // 右侧视图切换
          _buildViewToggle(theme),
        ],
      ),
    );
  }

  Widget _buildButtonGroup(MarkFlowTheme theme, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildDivider(MarkFlowTheme theme) {
    return Container(
      width: 1,
      height: 24,
      color: theme.border,
    );
  }

  Widget _buildViewToggle(MarkFlowTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewToggleButton(
            icon: Icons.edit_rounded,
            label: 'Edit',
            isSelected: !isPreviewMode,
            onTap: () => onTogglePreview?.call(),
            theme: theme,
          ),
          _ViewToggleButton(
            icon: Icons.preview_rounded,
            label: 'Preview',
            isSelected: isPreviewMode,
            onTap: () => onTogglePreview?.call(),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final MarkFlowTheme theme;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    required this.theme,
  });

  @override
  State<_ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<_ToolbarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _isHovered ? widget.theme.hover : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: widget.theme.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewToggleButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final MarkFlowTheme theme;

  const _ViewToggleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.onTap,
    required this.theme,
  });

  @override
  State<_ViewToggleButton> createState() => _ViewToggleButtonState();
}

class _ViewToggleButtonState extends State<_ViewToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.theme.selected
                : _isHovered
                    ? widget.theme.hover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.isSelected
                    ? widget.theme.primary
                    : widget.theme.secondaryText,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: widget.isSelected
                      ? widget.theme.primary
                      : widget.theme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/shared/widgets/sliding_button_group.dart';

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
          // Logo
          _buildLogo(theme),
          
          const SizedBox(width: 16),
          
          // 左侧格式化按钮组
          _buildFormatGroup(theme),
          
          const Spacer(),
          
          // 右侧视图切换
          SlidingButtonGroup<String>(
            options: [
              SlidingButtonOption(
                value: 'edit',
                label: 'Edit',
                icon: Icons.edit_rounded,
              ),
              SlidingButtonOption(
                value: 'split',
                label: 'Split',
                icon: Icons.vertical_split_rounded,
              ),
              SlidingButtonOption(
                value: 'preview',
                label: 'Preview',
                icon: Icons.preview_rounded,
              ),
            ],
            selectedValue: isPreviewMode ? 'preview' : 'edit',
            onChanged: (value) {
              if (value == 'preview' || value == 'edit') {
                onTogglePreview?.call();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(MarkFlowTheme theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'M',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatGroup(MarkFlowTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceWarm,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FormatButton(
            label: 'B',
            style: const TextStyle(fontWeight: FontWeight.bold),
            tooltip: 'Bold',
            onTap: onBold,
            theme: theme,
          ),
          _FormatButton(
            label: 'I',
            style: const TextStyle(fontStyle: FontStyle.italic),
            tooltip: 'Italic',
            onTap: onItalic,
            theme: theme,
          ),
          _FormatButton(
            label: 'H',
            style: const TextStyle(fontWeight: FontWeight.w600),
            tooltip: 'Heading',
            onTap: () {},
            theme: theme,
          ),
          _FormatButton(
            label: '—',
            tooltip: 'Divider',
            onTap: () {},
            theme: theme,
          ),
          _FormatButton(
            label: '•',
            tooltip: 'List',
            onTap: () {},
            theme: theme,
          ),
          _FormatButton(
            label: '1.',
            style: const TextStyle(fontSize: 11),
            tooltip: 'Ordered List',
            onTap: () {},
            theme: theme,
          ),
          _FormatButton(
            label: '<>',
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            tooltip: 'Code',
            onTap: onCode,
            theme: theme,
          ),
          _FormatButton(
            label: '❝',
            tooltip: 'Quote',
            onTap: () {},
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _FormatButton extends StatefulWidget {
  final String label;
  final TextStyle? style;
  final String tooltip;
  final VoidCallback? onTap;
  final MarkFlowTheme theme;

  const _FormatButton({
    required this.label,
    this.style,
    required this.tooltip,
    this.onTap,
    required this.theme,
  });

  @override
  State<_FormatButton> createState() => _FormatButtonState();
}

class _FormatButtonState extends State<_FormatButton> {
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
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _isHovered
                  ? widget.theme.primaryMist
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: widget.style?.copyWith(
                  color: _isHovered
                      ? widget.theme.primary
                      : widget.theme.secondaryText,
                ) ?? TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _isHovered
                      ? widget.theme.primary
                      : widget.theme.secondaryText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

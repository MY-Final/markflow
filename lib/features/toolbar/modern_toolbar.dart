import 'package:flutter/material.dart';
import 'package:markflow/app/app.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/core/utils/file_utils.dart';
import 'package:markflow/shared/widgets/sliding_button_group.dart';

class ModernToolbar extends StatelessWidget {
  final void Function(String commandId)? onCommand;
  final ViewMode viewMode;
  final FileCategory fileCategory;

  const ModernToolbar({
    super.key,
    this.onCommand,
    this.viewMode = ViewMode.split,
    this.fileCategory = FileCategory.markdown,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;
    final isMarkdown = fileCategory == FileCategory.markdown;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.toolbarBackground,
        border: Border(
          bottom: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildLogo(theme),
          const SizedBox(width: 16),
          if (isMarkdown) _buildFormatGroup(theme),
          const Spacer(),
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
            selectedValue: viewMode.name,
            onChanged: (value) {
              onCommand?.call('view.${value}Mode');
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
            tooltip: '加粗 (Ctrl+B)',
            onTap: () => onCommand?.call('editor.insertBold'),
            theme: theme,
          ),
          _FormatButton(
            label: 'I',
            style: const TextStyle(fontStyle: FontStyle.italic),
            tooltip: '斜体 (Ctrl+I)',
            onTap: () => onCommand?.call('editor.insertItalic'),
            theme: theme,
          ),
          _FormatButton(
            label: 'H',
            style: const TextStyle(fontWeight: FontWeight.w600),
            tooltip: '标题',
            onTap: () => onCommand?.call('editor.insertHeading'),
            theme: theme,
          ),
          _FormatButton(
            label: '—',
            tooltip: '分割线',
            onTap: () => onCommand?.call('editor.insertDivider'),
            theme: theme,
          ),
          _FormatButton(
            label: '•',
            tooltip: '无序列表',
            onTap: () => onCommand?.call('editor.insertUnorderedList'),
            theme: theme,
          ),
          _FormatButton(
            label: '1.',
            style: const TextStyle(fontSize: 11),
            tooltip: '有序列表',
            onTap: () => onCommand?.call('editor.insertOrderedList'),
            theme: theme,
          ),
          _FormatButton(
            label: '<>',
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            tooltip: '代码块',
            onTap: () => onCommand?.call('editor.insertCode'),
            theme: theme,
          ),
          _FormatButton(
            label: '❝',
            tooltip: '引用',
            onTap: () => onCommand?.call('editor.insertQuote'),
            theme: theme,
          ),
          _FormatButton(
            label: '🔗',
            style: const TextStyle(fontSize: 13),
            tooltip: '链接',
            onTap: () => onCommand?.call('editor.insertLink'),
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
              color: _isHovered ? widget.theme.primaryMist : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: widget.style?.copyWith(
                  color: _isHovered ? widget.theme.primary : widget.theme.secondaryText,
                ) ?? TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _isHovered ? widget.theme.primary : widget.theme.secondaryText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

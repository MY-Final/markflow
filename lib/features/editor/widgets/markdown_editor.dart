import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class MarkdownEditor extends StatefulWidget {
  final String initialContent;
  final Function(String)? onChanged;
  final bool readOnly;

  const MarkdownEditor({
    super.key,
    this.initialContent = '',
    this.onChanged,
    this.readOnly = false,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialContent != oldWidget.initialContent) {
      _controller.text = widget.initialContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildModeToggle(context),
        Expanded(
          child: _isPreviewMode
              ? _buildPreview(context)
              : _buildEditor(context),
        ),
      ],
    );
  }

  Widget _buildModeToggle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF252525) : Color(0xFFF5F5F5),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Color(0xFF424242) : Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildModeButton(
            context,
            icon: Icons.edit,
            label: '编辑',
            isSelected: !_isPreviewMode,
            onPressed: () => setState(() => _isPreviewMode = false),
          ),
          _buildModeButton(
            context,
            icon: Icons.preview,
            label: '预览',
            isSelected: _isPreviewMode,
            onPressed: () => setState(() => _isPreviewMode = true),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.blue.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.1))
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (isDark ? Colors.blue[300] : Colors.blue[700])
                  : (isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? (isDark ? Colors.blue[300] : Colors.blue[700])
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? Color(0xFF1E1E1E) : Colors.white,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        readOnly: widget.readOnly,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white70 : Colors.black87,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          hintText: '开始输入 Markdown...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Markdown(
        data: _controller.text,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  /// 插入文本
  void insertText(String text) {
    final selection = _controller.selection;
    final newText = _controller.text.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: selection.start + text.length,
    );
    widget.onChanged?.call(_controller.text);
  }

  /// 包围选中文本
  void wrapSelectedText(String prefix, String suffix) {
    final selection = _controller.selection;
    if (selection.isCollapsed) return;

    final selectedText = _controller.text.substring(
      selection.start,
      selection.end,
    );
    final newText = _controller.text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$selectedText$suffix',
    );
    _controller.text = newText;
    _controller.selection = TextSelection(
      baseOffset: selection.start + prefix.length,
      extentOffset: selection.end + prefix.length,
    );
    widget.onChanged?.call(_controller.text);
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/core/utils/file_utils.dart';
import 'package:markflow/features/settings/settings_service.dart';

class ModernMarkdownEditor extends StatefulWidget {
  final String filePath;
  final String initialContent;
  final Function(String)? onChanged;
  final Function(int line, int column)? onCursorChanged;
  final ScrollController? scrollController;

  final FileCategory fileCategory;
  final bool isReadOnly;
  final bool isTruncated;
  final int totalLines;
  final VoidCallback? onLoadFullFile;

  const ModernMarkdownEditor({
    super.key,
    this.filePath = '',
    this.initialContent = '',
    this.onChanged,
    this.onCursorChanged,
    this.scrollController,
    this.fileCategory = FileCategory.markdown,
    this.isReadOnly = false,
    this.isTruncated = false,
    this.totalLines = 0,
    this.onLoadFullFile,
  });

  @override
  State<ModernMarkdownEditor> createState() => ModernMarkdownEditorState();
}

class ModernMarkdownEditorState extends State<ModernMarkdownEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  final SettingsService _settingsService = SettingsService();
  int _lineCount = 1;
  final ScrollController _lineNumberScrollController = ScrollController();

  TextEditingController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _focusNode = FocusNode();
    _settingsService.addListener(_onSettingsChanged);
    _updateLineCount();
    widget.scrollController?.addListener(_syncLineNumbers);
    _controller.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(ModernMarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filePath != oldWidget.filePath && widget.filePath.isNotEmpty) {
      _controller.text = widget.initialContent;
      _updateLineCount();
    }
    if (widget.scrollController != oldWidget.scrollController) {
      oldWidget.scrollController?.removeListener(_syncLineNumbers);
      widget.scrollController?.addListener(_syncLineNumbers);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_syncLineNumbers);
    _controller.removeListener(_onSelectionChanged);
    _lineNumberScrollController.dispose();
    _settingsService.removeListener(_onSettingsChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  void _updateLineCount() {
    _lineCount = '\n'.allMatches(_controller.text).length + 1;
  }

  void _onSelectionChanged() {
    if (!mounted) return;
    final selection = _controller.selection;
    final text = _controller.text;
    if (selection.start < 0 || selection.start > text.length) return;

    final beforeCursor = text.substring(0, selection.start);
    final lines = beforeCursor.split('\n');
    widget.onCursorChanged?.call(lines.length, lines.last.length + 1);
  }

  void _syncLineNumbers() {
    if (_lineNumberScrollController.hasClients &&
        widget.scrollController?.hasClients == true) {
      _lineNumberScrollController.jumpTo(widget.scrollController!.offset);
    }
  }

  void _notifyChanged() {
    _updateLineCount();
    setState(() {});
    widget.onChanged?.call(_controller.text);
  }

  // ==================== 编辑器命令方法 ====================

  String getText() => _controller.text;

  String getSelectedText() {
    final selection = _controller.selection;
    if (selection.isCollapsed) return '';
    return _controller.text.substring(selection.start, selection.end);
  }

  void wrapSelectedText(String before, String after) {
    final text = _controller.text;
    final selection = _controller.selection;

    if (selection.isCollapsed) {
      final newText = text.replaceRange(selection.start, selection.end, '$before$after');
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + before.length),
      );
    } else {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(selection.start, selection.end, '$before$selectedText$after');
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start + before.length,
          extentOffset: selection.start + before.length + selectedText.length,
        ),
      );
    }
    _notifyChanged();
  }

  void insertText(String text) {
    final currentText = _controller.text;
    final selection = _controller.selection;
    final newText = currentText.replaceRange(selection.start, selection.end, text);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + text.length),
    );
    _notifyChanged();
  }

  void insertAtLineStart(String prefix) {
    final text = _controller.text;
    final selection = _controller.selection;
    final cursorPos = selection.start;

    int lineStart = cursorPos;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final newText = text.replaceRange(lineStart, lineStart, prefix);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + prefix.length),
    );
    _notifyChanged();
  }

  void replaceSelectedText(String replacement) {
    final text = _controller.text;
    final selection = _controller.selection;
    final newText = text.replaceRange(selection.start, selection.end, replacement);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + replacement.length),
    );
    _notifyChanged();
  }

  // ==================== 撤销/重做 ====================

  void undo() {}
  void redo() {}

  // ==================== 格式化命令 ====================

  void insertStrikethrough() {
    wrapSelectedText('~~', '~~');
  }

  void insertInlineCode() {
    wrapSelectedText('`', '`');
  }

  void insertUnderline() {
    wrapSelectedText('<u>', '</u>');
  }

  // ==================== 标题命令 ====================

  void insertHeading(int level) {
    final prefix = '${'#' * level} ';
    insertAtLineStart(prefix);
  }

  void increaseHeadingLevel() {
    final text = _controller.text;
    final selection = _controller.selection;
    final cursorPos = selection.start;

    int lineStart = cursorPos;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final lineEnd = text.indexOf('\n', cursorPos);
    final line = text.substring(lineStart, lineEnd == -1 ? text.length : lineEnd);

    final headingMatch = RegExp(r'^(#{1,6})\s').firstMatch(line);
    if (headingMatch != null) {
      final currentLevel = headingMatch.group(1)!.length;
      if (currentLevel > 1) {
        final newPrefix = '${'#' * (currentLevel - 1)} ';
        final newLine = line.replaceFirst(RegExp(r'^#{1,6}\s'), newPrefix);
        final newText = text.replaceRange(lineStart, lineEnd == -1 ? text.length : lineEnd, newLine);
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: lineStart + newPrefix.length),
        );
        _notifyChanged();
      }
    }
  }

  void decreaseHeadingLevel() {
    final text = _controller.text;
    final selection = _controller.selection;
    final cursorPos = selection.start;

    int lineStart = cursorPos;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final lineEnd = text.indexOf('\n', cursorPos);
    final line = text.substring(lineStart, lineEnd == -1 ? text.length : lineEnd);

    final headingMatch = RegExp(r'^(#{1,6})\s').firstMatch(line);
    if (headingMatch != null) {
      final currentLevel = headingMatch.group(1)!.length;
      if (currentLevel < 6) {
        final newPrefix = '${'#' * (currentLevel + 1)} ';
        final newLine = line.replaceFirst(RegExp(r'^#{1,6}\s'), newPrefix);
        final newText = text.replaceRange(lineStart, lineEnd == -1 ? text.length : lineEnd, newLine);
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: lineStart + newPrefix.length),
        );
        _notifyChanged();
      }
    }
  }

  // ==================== 列表命令 ====================

  void insertTaskList() {
    insertAtLineStart('- [ ] ');
  }

  void indent() {
    insertText('  ');
  }

  void outdent() {
    final text = _controller.text;
    final selection = _controller.selection;
    final cursorPos = selection.start;

    int lineStart = cursorPos;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final line = text.substring(lineStart, cursorPos);
    if (line.startsWith('  ')) {
      final newText = text.replaceRange(lineStart, lineStart + 2, '');
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursorPos - 2),
      );
      _notifyChanged();
    }
  }

  // ==================== 代码与公式 ====================

  void insertCodeBlock() {
    wrapSelectedText('```\n', '\n```');
  }

  void insertInlineMath() {
    wrapSelectedText(r'$', r'$');
  }

  void insertBlockMath() {
    wrapSelectedText('\$\$\n', '\n\$\$');
  }

  // ==================== 链接与图片 ====================

  void insertImage() {
    final selectedText = getSelectedText();
    if (selectedText.isNotEmpty) {
      replaceSelectedText('![$selectedText](url)');
    } else {
      insertText('![图片描述](url)');
    }
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;
    final settings = _settingsService.settings;

    return Container(
      color: theme.background,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.text.withValues(alpha: 0.04),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isTruncated) _buildTruncationBar(theme),
                if (widget.isReadOnly && !widget.isTruncated)
                  _buildReadOnlyBar(theme),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (settings.editorShowLineNumbers) ...[
                        Container(
                          width: 50,
                          color: theme.surface,
                          padding: const EdgeInsets.only(top: 40, right: 8, bottom: 40, left: 8),
                          child: ScrollConfiguration(
                            behavior: _NoScrollbarBehavior(),
                            child: SingleChildScrollView(
                              controller: _lineNumberScrollController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List.generate(
                                  _lineCount,
                                  (index) => Text(
                                    '${index + 1}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: settings.editorFontSize * 0.85,
                                      height: settings.editorLineHeight,
                                      color: theme.ghostText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          color: theme.borderLight,
                        ),
                      ],
                      Expanded(
                        child: SingleChildScrollView(
                          controller: widget.scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: settings.editorShowLineNumbers ? 16 : 48,
                            vertical: 40,
                          ),
                          child: IntrinsicHeight(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              maxLines: null,
                              readOnly: widget.isReadOnly,
                              style: GoogleFonts.inter(
                                fontSize: settings.editorFontSize,
                                height: settings.editorLineHeight,
                                color: theme.text,
                              ),
                              decoration: InputDecoration(
                                hintText: widget.isReadOnly
                                    ? '该文件类型暂不支持编辑'
                                    : '开始输入...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: settings.editorFontSize,
                                  height: settings.editorLineHeight,
                                  color: theme.ghostText,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              onChanged: widget.isReadOnly
                                  ? null
                                  : (text) {
                                      _updateLineCount();
                                      setState(() {});
                                      widget.onChanged?.call(text);
                                    },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildFileTypeLabel(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTruncationBar(MarkFlowTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '文件过大（共 ${widget.totalLines} 行），仅显示前部分内容。',
              style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
            ),
          ),
          if (widget.onLoadFullFile != null)
            TextButton(
              onPressed: widget.onLoadFullFile,
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: const Text('加载完整文件', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyBar(MarkFlowTheme theme) {
    final categoryLabel = _categoryDisplayName(widget.fileCategory);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surfaceWarm,
        border: Border(
          bottom: BorderSide(color: theme.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: theme.tertiaryText),
          const SizedBox(width: 8),
          Text(
            '「$categoryLabel」文件以只读模式打开',
            style: TextStyle(fontSize: 13, color: theme.tertiaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTypeLabel(MarkFlowTheme theme) {
    final label = _categoryDisplayName(widget.fileCategory);
    final suffix = widget.isReadOnly ? ' · 只读' : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          top: BorderSide(color: theme.borderLight, width: 1),
        ),
      ),
      child: Text(
        '$label$suffix',
        style: TextStyle(fontSize: 12, color: theme.ghostText),
      ),
    );
  }

  String _categoryDisplayName(FileCategory category) {
    switch (category) {
      case FileCategory.markdown:
        return 'Markdown';
      case FileCategory.data:
        return '数据文件';
      case FileCategory.log:
        return '日志文件';
      case FileCategory.text:
        return '文本文件';
      case FileCategory.binary:
        return '二进制';
    }
  }
}

class _NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

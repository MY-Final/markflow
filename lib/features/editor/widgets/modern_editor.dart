import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/core/utils/file_utils.dart';
import 'package:markflow/features/settings/settings_service.dart';

class ModernMarkdownEditor extends StatefulWidget {
  final String filePath;
  final String initialContent;
  final Function(String)? onChanged;
  final ScrollController? scrollController;

  /// 文件内容分类（用于决定渲染策略）
  final FileCategory fileCategory;

  /// 是否为只读模式（非 Markdown 大文件自动只读）
  final bool isReadOnly;

  /// 内容是否被截断（仅显示了前 N 行）
  final bool isTruncated;

  /// 文件总行数（截断时用于提示）
  final int totalLines;

  /// 用户点击"加载完整文件"时的回调
  final VoidCallback? onLoadFullFile;

  const ModernMarkdownEditor({
    super.key,
    this.filePath = '',
    this.initialContent = '',
    this.onChanged,
    this.scrollController,
    this.fileCategory = FileCategory.markdown,
    this.isReadOnly = false,
    this.isTruncated = false,
    this.totalLines = 0,
    this.onLoadFullFile,
  });

  @override
  State<ModernMarkdownEditor> createState() => _ModernMarkdownEditorState();
}

class _ModernMarkdownEditorState extends State<ModernMarkdownEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  final SettingsService _settingsService = SettingsService();
  int _lineCount = 1;
  final ScrollController _lineNumberScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _focusNode = FocusNode();
    _settingsService.addListener(_onSettingsChanged);
    _updateLineCount();
    widget.scrollController?.addListener(_syncLineNumbers);
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

  void _syncLineNumbers() {
    if (_lineNumberScrollController.hasClients &&
        widget.scrollController?.hasClients == true) {
      _lineNumberScrollController.jumpTo(widget.scrollController!.offset);
    }
  }

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
                // 截断提示条
                if (widget.isTruncated) _buildTruncationBar(theme),
                // 只读提示条
                if (widget.isReadOnly && !widget.isTruncated)
                  _buildReadOnlyBar(theme),
                // 编辑器主体
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 行号区域
                      if (settings.editorShowLineNumbers) ...[
                        Container(
                          width: 50,
                          color: theme.surface,
                          padding: const EdgeInsets.only(top: 40, right: 8, bottom: 40, left: 8),
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
                        Container(
                          width: 1,
                          color: theme.borderLight,
                        ),
                      ],
                      // 编辑器区域
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
                // 底部文件类型标签
                _buildFileTypeLabel(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 截断提示条：黄底 + 加载完整文件按钮
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
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade900,
              ),
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

  /// 只读提示条
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

  /// 底部文件类型标签
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

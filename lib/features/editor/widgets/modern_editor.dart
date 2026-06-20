import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/features/settings/settings_service.dart';

class ModernMarkdownEditor extends StatefulWidget {
  final String filePath;
  final String initialContent;
  final Function(String)? onChanged;
  final ScrollController? scrollController;

  const ModernMarkdownEditor({
    super.key,
    this.filePath = '',
    this.initialContent = '',
    this.onChanged,
    this.scrollController,
  });

  @override
  State<ModernMarkdownEditor> createState() => _ModernMarkdownEditorState();
}

class _ModernMarkdownEditorState extends State<ModernMarkdownEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  final SettingsService _settingsService = SettingsService();
  int _lineCount = 1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _focusNode = FocusNode();
    _settingsService.addListener(_onSettingsChanged);
    _updateLineCount();
  }

  @override
  void didUpdateWidget(ModernMarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filePath != oldWidget.filePath && widget.filePath.isNotEmpty) {
      _controller.text = widget.initialContent;
      _updateLineCount();
    }
  }

  @override
  void dispose() {
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 行号区域
                if (settings.editorShowLineNumbers) ...[
                  Container(
                    width: 50,
                    color: theme.surface,
                    padding: const EdgeInsets.only(top: 40, right: 8, bottom: 40, left: 8),
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
                        style: GoogleFonts.inter(
                          fontSize: settings.editorFontSize,
                          height: settings.editorLineHeight,
                          color: theme.text,
                        ),
                        decoration: InputDecoration(
                          hintText: '开始输入...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: settings.editorFontSize,
                            height: settings.editorLineHeight,
                            color: theme.ghostText,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (text) {
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
        ),
      ),
    );
  }
}

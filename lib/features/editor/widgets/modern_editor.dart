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
  final ScrollController _lineNumberController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _focusNode = FocusNode();
    _settingsService.addListener(_onSettingsChanged);
  }

  @override
  void didUpdateWidget(ModernMarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filePath != oldWidget.filePath && widget.filePath.isNotEmpty) {
      _controller.text = widget.initialContent;
    }
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    _controller.dispose();
    _focusNode.dispose();
    _lineNumberController.dispose();
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;
    final settings = _settingsService.settings;
    final lines = _controller.text.split('\n');

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
                if (settings.editorShowLineNumbers)
                  SizedBox(
                    width: 50,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        controller: _lineNumberController,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          top: 40,
                          right: 12,
                          bottom: 40,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                            lines.length,
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
                // 分隔线
                if (settings.editorShowLineNumbers)
                  Container(
                    width: 1,
                    color: theme.borderLight,
                  ),
                // 编辑器区域
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification &&
                          notification.dragDetails != null) {
                        _lineNumberController.jumpTo(
                          notification.metrics.pixels.clamp(
                            0.0,
                            _lineNumberController.hasClients
                                ? _lineNumberController.position.maxScrollExtent
                                : 0.0,
                          ),
                        );
                      }
                      return false;
                    },
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: settings.editorShowLineNumbers ? 16 : 48,
                          vertical: 40,
                        ),
                      ),
                      onChanged: (text) {
                        setState(() {});
                        widget.onChanged?.call(text);
                      },
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

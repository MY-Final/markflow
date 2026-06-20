import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markflow/core/theme/theme.dart';

class ModernMarkdownEditor extends StatefulWidget {
  final String initialContent;
  final Function(String)? onChanged;
  final ScrollController? scrollController;

  const ModernMarkdownEditor({
    super.key,
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;
    
    return Container(
      color: theme.background,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.text.withValues(alpha: 0.05),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
              child: Scrollbar(
                controller: widget.scrollController,
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(64),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.8,
                      color: theme.text,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.8,
                        color: theme.secondaryText.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: widget.onChanged,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

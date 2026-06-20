import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markflow/core/theme/theme.dart';

class ModernPreviewPanel extends StatefulWidget {
  final String content;
  final ScrollController? scrollController;

  const ModernPreviewPanel({
    super.key,
    this.content = '',
    this.scrollController,
  });

  @override
  State<ModernPreviewPanel> createState() => _ModernPreviewPanelState();
}

class _ModernPreviewPanelState extends State<ModernPreviewPanel> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          left: BorderSide(
            color: theme.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: _buildContent(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(MarkFlowTheme theme) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.preview_rounded,
            size: 16,
            color: theme.secondaryText,
          ),
          const SizedBox(width: 8),
          Text(
            'PREVIEW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.secondaryText,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MarkFlowTheme theme) {
    if (widget.content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.preview_rounded,
              size: 48,
              color: theme.secondaryText.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Preview will appear here',
              style: TextStyle(
                fontSize: 13,
                color: theme.secondaryText.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
      child: Scrollbar(
        controller: widget.scrollController,
        child: Markdown(
          data: widget.content,
          controller: widget.scrollController,
          padding: const EdgeInsets.all(32),
          styleSheet: MarkdownStyleSheet(
            h1: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              color: theme.text,
              height: 1.3,
            ),
            h2: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: theme.text,
              height: 1.3,
            ),
            h3: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: theme.text,
              height: 1.4,
            ),
            p: GoogleFonts.inter(
              fontSize: 16,
              color: theme.text,
              height: 1.8,
            ),
            code: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              color: theme.primary,
              backgroundColor: theme.hover,
            ),
            codeblockDecoration: BoxDecoration(
              color: theme.hover,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.border,
                width: 1,
              ),
            ),
            blockquote: GoogleFonts.inter(
              fontSize: 16,
              color: theme.secondaryText,
              fontStyle: FontStyle.italic,
            ),
            blockquoteDecoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.primary,
                  width: 3,
                ),
              ),
            ),
            listBullet: GoogleFonts.inter(
              fontSize: 16,
              color: theme.text,
            ),
            a: GoogleFonts.inter(
              fontSize: 16,
              color: theme.primary,
              decoration: TextDecoration.underline,
            ),
            tableBorder: TableBorder.all(
              color: theme.border,
              width: 1,
            ),
            tableHead: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.text,
            ),
            tableBody: GoogleFonts.inter(
              fontSize: 14,
              color: theme.text,
            ),
          ),
        ),
      ),
    );
  }
}

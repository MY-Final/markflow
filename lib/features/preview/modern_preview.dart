import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/features/settings/settings_service.dart';

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
            color: theme.tertiaryText,
          ),
          const SizedBox(width: 8),
          Text(
            'PREVIEW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.tertiaryText,
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
              color: theme.ghostText,
            ),
            const SizedBox(height: 16),
            Text(
              'Preview will appear here',
              style: TextStyle(
                fontSize: 13,
                color: theme.tertiaryText,
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
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          styleSheet: _buildMarkdownStyleSheet(theme),
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(MarkFlowTheme theme) {
    final settings = SettingsService().settings;
    final fontSize = settings.previewFontSize;

    return MarkdownStyleSheet(
      // 标题
      h1: GoogleFonts.inter(
        fontSize: fontSize * 1.8,
        fontWeight: FontWeight.w600,
        color: theme.text,
        height: 1.3,
        letterSpacing: -0.5,
      ),
      h2: GoogleFonts.inter(
        fontSize: fontSize * 1.5,
        fontWeight: FontWeight.w600,
        color: theme.text,
        height: 1.3,
        letterSpacing: -0.3,
      ),
      h3: GoogleFonts.inter(
        fontSize: fontSize * 1.2,
        fontWeight: FontWeight.w600,
        color: theme.text,
        height: 1.4,
      ),
      h4: GoogleFonts.inter(
        fontSize: fontSize * 1.1,
        fontWeight: FontWeight.w600,
        color: theme.text,
        height: 1.4,
      ),

      // 正文 - 使用设置的字体大小
      p: GoogleFonts.inter(
        fontSize: fontSize,
        color: theme.secondaryText,
        height: 1.9,
      ),

      // 强调
      strong: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: theme.text,
      ),
      em: GoogleFonts.inter(
        fontSize: fontSize,
        fontStyle: FontStyle.italic,
        color: theme.primaryLight,
      ),

      // 代码
      code: GoogleFonts.jetBrainsMono(
        fontSize: fontSize * 0.87,
        color: theme.primary,
        backgroundColor: theme.surfaceWarm,
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.surfaceWarm,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.border,
          width: 1,
        ),
      ),
      codeblockPadding: const EdgeInsets.all(16),

      // 引用
      blockquote: GoogleFonts.inter(
        fontSize: fontSize,
        color: theme.tertiaryText,
        fontStyle: FontStyle.italic,
        height: 1.9,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.primary.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 16),

      // 列表
      listBullet: GoogleFonts.inter(
        fontSize: fontSize,
        color: theme.primary.withValues(alpha: 0.4),
      ),
      listBulletPadding: const EdgeInsets.only(right: 8),

      // 链接
      a: GoogleFonts.inter(
        fontSize: fontSize,
        color: theme.primary,
        decoration: TextDecoration.underline,
      ),

      // 表格
      tableBorder: TableBorder.all(
        color: theme.border,
        width: 1,
        borderRadius: BorderRadius.circular(8),
      ),
      tableHead: GoogleFonts.inter(
        fontSize: fontSize * 0.93,
        fontWeight: FontWeight.w600,
        color: theme.text,
      ),
      tableBody: GoogleFonts.inter(
        fontSize: fontSize * 0.93,
        color: theme.secondaryText,
      ),
      tableHeadAlign: TextAlign.left,
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),

      // 分隔线 - 渐变效果
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.border,
            width: 1,
          ),
        ),
      ),

      // 图片
      img: GoogleFonts.inter(
        fontSize: 14,
        color: theme.tertiaryText,
      ),

      // Checkbox
      checkbox: GoogleFonts.inter(
        fontSize: 15,
        color: theme.primary,
      ),
    );
  }
}

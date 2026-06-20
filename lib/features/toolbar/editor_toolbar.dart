import 'package:flutter/material.dart';

class EditorToolbar extends StatelessWidget {
  final VoidCallback? onBold;
  final VoidCallback? onItalic;
  final VoidCallback? onStrikethrough;
  final VoidCallback? onHeading1;
  final VoidCallback? onHeading2;
  final VoidCallback? onUnorderedList;
  final VoidCallback? onOrderedList;
  final VoidCallback? onTaskList;
  final VoidCallback? onCodeBlock;
  final VoidCallback? onQuoteBlock;
  final VoidCallback? onLink;
  final VoidCallback? onImage;
  final VoidCallback? onHorizontalRule;

  const EditorToolbar({
    super.key,
    this.onBold,
    this.onItalic,
    this.onStrikethrough,
    this.onHeading1,
    this.onHeading2,
    this.onUnorderedList,
    this.onOrderedList,
    this.onTaskList,
    this.onCodeBlock,
    this.onQuoteBlock,
    this.onLink,
    this.onImage,
    this.onHorizontalRule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF252525) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Color(0xFF424242) : Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildToolbarButton(
            context,
            icon: Icons.add,
            tooltip: '新建文件',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          _buildDivider(),
          const SizedBox(width: 4),
          _buildToolbarButton(
            context,
            icon: Icons.format_bold,
            tooltip: '加粗 (Ctrl+B)',
            onPressed: onBold,
          ),
          _buildToolbarButton(
            context,
            icon: Icons.format_italic,
            tooltip: '斜体 (Ctrl+I)',
            onPressed: onItalic,
          ),
          _buildToolbarButton(
            context,
            icon: Icons.format_strikethrough,
            tooltip: '删除线',
            onPressed: onStrikethrough,
          ),
          const SizedBox(width: 4),
          _buildDivider(),
          const SizedBox(width: 4),
          _buildToolbarButton(
            context,
            icon: Icons.title,
            tooltip: '标题 1',
            onPressed: onHeading1,
            child: Text(
              'H1',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildToolbarButton(
            context,
            icon: Icons.title,
            tooltip: '标题 2',
            onPressed: onHeading2,
            child: Text(
              'H2',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          _buildDivider(),
          const SizedBox(width: 4),
          _buildToolbarButton(
            context,
            icon: Icons.format_list_bulleted,
            tooltip: '无序列表',
            onPressed: onUnorderedList,
          ),
          _buildToolbarButton(
            context,
            icon: Icons.format_list_numbered,
            tooltip: '有序列表',
            onPressed: onOrderedList,
          ),
          _buildToolbarButton(
            context,
            icon: Icons.check_box,
            tooltip: '任务列表',
            onPressed: onTaskList,
          ),
          const SizedBox(width: 4),
          _buildDivider(),
          const SizedBox(width: 4),
          _buildToolbarButton(
            context,
            icon: Icons.code,
            tooltip: '代码块',
            onPressed: onCodeBlock,
          ),
          _buildToolbarButton(
            context,
            icon: Icons.format_quote,
            tooltip: '引用',
            onPressed: onQuoteBlock,
          ),
          const SizedBox(width: 4),
          _buildDivider(),
          const SizedBox(width: 4),
          _buildToolbarButton(
            context,
            icon: Icons.link,
            tooltip: '链接',
            onPressed: onLink,
          ),
          _buildToolbarButton(
            context,
            icon: Icons.image,
            tooltip: '图片',
            onPressed: onImage,
          ),
          _buildToolbarButton(
            context,
            icon: Icons.horizontal_rule,
            tooltip: '分割线',
            onPressed: onHorizontalRule,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
    Widget? child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: child ??
              Icon(
                icon,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }
}

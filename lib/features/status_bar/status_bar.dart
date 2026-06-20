import 'package:flutter/material.dart';
import 'package:markflow/core/theme/theme.dart';

class ModernStatusBar extends StatelessWidget {
  final String encoding;
  final String fileType;
  final String saveStatus;
  final int line;
  final int column;

  const ModernStatusBar({
    super.key,
    this.encoding = 'UTF-8',
    this.fileType = 'Markdown',
    this.saveStatus = 'Saved',
    this.line = 1,
    this.column = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;
    
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.statusBarBackground,
        border: Border(
          top: BorderSide(
            color: theme.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 左侧信息
          _buildStatusItem(
            theme,
            label: 'Ln $line, Col $column',
          ),
          const SizedBox(width: 16),
          _buildStatusItem(
            theme,
            label: encoding,
          ),
          const SizedBox(width: 16),
          _buildStatusItem(
            theme,
            label: fileType,
          ),

          const Spacer(),

          // 右侧保存状态
          _buildSaveStatus(theme),
        ],
      ),
    );
  }

  Widget _buildStatusItem(MarkFlowTheme theme, {required String label}) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        color: theme.secondaryText,
      ),
    );
  }

  Widget _buildSaveStatus(MarkFlowTheme theme) {
    final isSaved = saveStatus == 'Saved';
    final color = isSaved ? const Color(0xFF34D399) : const Color(0xFFFBBF24);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          saveStatus,
          style: TextStyle(
            fontSize: 11,
            color: color,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/features/settings/settings_service.dart';

class SettingsPanel extends StatefulWidget {
  final VoidCallback onClose;

  const SettingsPanel({
    super.key,
    required this.onClose,
  });

  static Future<void> show(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Settings',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: SettingsPanel(
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final SettingsService _settingsService = SettingsService();
  late SettingsModel _settings;
  bool _isLoading = true;

  // Shortcut settings (display only)
  final Map<String, String> _shortcuts = {
    '保存': 'Ctrl+S',
    '撤销': 'Ctrl+Z',
    '重做': 'Ctrl+Y',
    '加粗': 'Ctrl+B',
    '斜体': 'Ctrl+I',
    '命令面板': 'Ctrl+Shift+P',
  };

  @override
  void initState() {
    super.initState();
    _settings = _settingsService.settings;
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;

    if (_isLoading) {
      return Container(
        width: 380,
        color: theme.surface,
        child: Center(
          child: CircularProgressIndicator(color: theme.primary),
        ),
      );
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          widget.onClose();
        }
      },
      child: Material(
        color: theme.surface,
        child: SizedBox(
          width: 380,
          height: double.infinity,
          child: Column(
            children: [
              _buildHeader(theme),
              Expanded(
                child: _buildContent(theme),
              ),
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(MarkFlowTheme theme) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            Icons.settings_rounded,
            size: 20,
            color: theme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            '设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.text,
            ),
          ),
          const Spacer(),
          _buildIconButton(
            icon: Icons.close_rounded,
            onTap: widget.onClose,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MarkFlowTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('编辑器', Icons.edit_rounded, [
            _buildSliderSetting(
              '字体大小',
              _settings.editorFontSize,
              12,
              24,
              (value) {
                setState(() => _settings = _settings.copyWith(editorFontSize: value));
                _settingsService.updateEditorFontSize(value);
              },
              theme,
              '${_settings.editorFontSize.round()}px',
            ),
            _buildSliderSetting(
              '行高',
              _settings.editorLineHeight,
              1.2,
              2.5,
              (value) {
                setState(() => _settings = _settings.copyWith(editorLineHeight: value));
                _settingsService.updateEditorLineHeight(value);
              },
              theme,
              _settings.editorLineHeight.toStringAsFixed(1),
            ),
            _buildSwitchSetting(
              '自动换行',
              _settings.editorWordWrap,
              (value) {
                setState(() => _settings = _settings.copyWith(editorWordWrap: value));
                _settingsService.updateEditorWordWrap(value);
              },
              theme,
            ),
            _buildSwitchSetting(
              '显示行号',
              _settings.editorShowLineNumbers,
              (value) {
                setState(() => _settings = _settings.copyWith(editorShowLineNumbers: value));
                _settingsService.updateEditorShowLineNumbers(value);
              },
              theme,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('预览', Icons.preview_rounded, [
            _buildSliderSetting(
              '字体大小',
              _settings.previewFontSize,
              12,
              24,
              (value) {
                setState(() => _settings = _settings.copyWith(previewFontSize: value));
                _settingsService.updatePreviewFontSize(value);
              },
              theme,
              '${_settings.previewFontSize.round()}px',
            ),
            _buildSwitchSetting(
              '同步滚动',
              _settings.previewSyncScroll,
              (value) {
                setState(() => _settings = _settings.copyWith(previewSyncScroll: value));
                _settingsService.updatePreviewSyncScroll(value);
              },
              theme,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('导出', Icons.file_download_rounded, [
            _buildDropdownSetting(
              '默认格式',
              _settings.defaultExportFormat,
              ['PDF', 'HTML', 'Markdown'],
              (value) {
                setState(() => _settings = _settings.copyWith(defaultExportFormat: value!));
                _settingsService.updateDefaultExportFormat(value!);
              },
              theme,
            ),
            _buildSwitchSetting(
              '包含目录',
              _settings.exportIncludeToc,
              (value) {
                setState(() => _settings = _settings.copyWith(exportIncludeToc: value));
                _settingsService.updateExportIncludeToc(value);
              },
              theme,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('快捷键', Icons.keyboard_rounded, [
            ..._shortcuts.entries.map((entry) =>
                _buildShortcutItem(entry.key, entry.value, theme)),
          ]),
          const SizedBox(height: 24),
          _buildSection('关于', Icons.info_outline_rounded, [
            _buildInfoItem('版本', '1.0.0', theme),
            _buildInfoItem('构建', '2026.06.20', theme),
            _buildInfoItem('许可证', 'MIT', theme),
            _buildInfoItem('配置路径', _settingsService.getSettingsPath(), theme),
          ]),
        ],
      ),
    );
  }

  Widget _buildFooter(MarkFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.border,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showResetDialog(theme),
          icon: const Icon(Icons.restore_rounded, size: 18),
          label: const Text('恢复默认设置'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFC45C4A),
            side: const BorderSide(color: Color(0xFFC45C4A)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: theme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSliderSetting(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    MarkFlowTheme theme,
    String displayValue,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: theme.primary,
                    inactiveTrackColor: theme.border,
                    thumbColor: theme.primary,
                    overlayColor: theme.primaryMist,
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: theme.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    MarkFlowTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.secondaryText,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
    MarkFlowTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.secondaryText,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.surfaceWarm,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.border),
            ),
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              underline: const SizedBox.shrink(),
              style: TextStyle(
                fontSize: 13,
                color: theme.secondaryText,
              ),
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem(String action, String shortcut, MarkFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              action,
              style: TextStyle(
                fontSize: 13,
                color: theme.secondaryText,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.surfaceWarm,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.border),
            ),
            child: Text(
              shortcut,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: theme.tertiaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, MarkFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: theme.tertiaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required MarkFlowTheme theme,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.hover,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: theme.secondaryText,
          ),
        ),
      ),
    );
  }

  void _showResetDialog(MarkFlowTheme theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '重置设置',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.text,
          ),
        ),
        content: Text(
          '确定要将所有设置恢复为默认值吗？此操作不可撤销。',
          style: TextStyle(
            fontSize: 14,
            color: theme.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: TextStyle(color: theme.tertiaryText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetToDefault();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFC45C4A),
            ),
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _settings = SettingsModel.defaultSettings;
    });
    _settingsService.resetToDefault();
  }
}

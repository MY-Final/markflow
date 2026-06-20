import 'package:flutter/material.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/core/utils/sync_scroll_controller.dart';
import 'package:markflow/features/title_bar/custom_title_bar.dart';
import 'package:markflow/features/toolbar/modern_toolbar.dart';
import 'package:markflow/features/file_explorer/modern_file_explorer.dart';
import 'package:markflow/features/editor/widgets/modern_editor.dart';
import 'package:markflow/features/preview/modern_preview.dart';
import 'package:markflow/features/status_bar/status_bar.dart';

class MarkFlowApp extends StatelessWidget {
  const MarkFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarkFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MarkFlowHomePage(),
    );
  }
}

class MarkFlowHomePage extends StatefulWidget {
  const MarkFlowHomePage({super.key});

  @override
  State<MarkFlowHomePage> createState() => _MarkFlowHomePageState();
}

class _MarkFlowHomePageState extends State<MarkFlowHomePage> {
  String? _currentFilePath;
  String _editorContent = '';
  String _saveStatus = 'Saved';
  int _line = 1;
  int _column = 1;
  bool _isPreviewMode = false;
  
  late final SyncScrollController _syncController;

  @override
  void initState() {
    super.initState();
    _syncController = SyncScrollController();
  }

  @override
  void dispose() {
    _syncController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;
    
    return Scaffold(
      body: Column(
        children: [
          // 自定义标题栏
          CustomTitleBar(
            currentFileName: _currentFilePath?.split('/').last.split('\\').last,
            isSaved: _saveStatus == 'Saved',
          ),

          // 工具栏
          ModernToolbar(
            onBold: () {},
            onItalic: () {},
            onCode: () {},
            onUndo: () {},
            onRedo: () {},
            onTogglePreview: () {
              setState(() {
                _isPreviewMode = !_isPreviewMode;
              });
            },
            isPreviewMode: _isPreviewMode,
          ),

          // 主内容区域 - 三栏布局
          Expanded(
            child: Row(
              children: [
                // 左侧文件树
                ModernFileExplorer(
                  rootPath: _currentFilePath != null
                      ? _getDirectoryPath(_currentFilePath!)
                      : null,
                  selectedFilePath: _currentFilePath,
                  onFileSelected: _handleFileSelected,
                ),

                // 中间编辑区
                Expanded(
                  flex: 3,
                  child: _isPreviewMode
                      ? ModernPreviewPanel(
                          content: _editorContent,
                          scrollController: _syncController.rightController,
                        )
                      : ModernMarkdownEditor(
                          initialContent: _editorContent,
                          onChanged: _handleContentChanged,
                          scrollController: _syncController.leftController,
                        ),
                ),

                // 右侧预览区 (非预览模式时显示)
                if (!_isPreviewMode)
                  Expanded(
                    flex: 2,
                    child: ModernPreviewPanel(
                      content: _editorContent,
                      scrollController: _syncController.rightController,
                    ),
                  ),
              ],
            ),
          ),

          // 状态栏
          ModernStatusBar(
            saveStatus: _saveStatus,
            line: _line,
            column: _column,
          ),
        ],
      ),
    );
  }

  String _getDirectoryPath(String filePath) {
    final parts = filePath.split(RegExp(r'[/\\]'));
    parts.removeLast();
    return parts.join(RegExp(r'[/\\]').pattern);
  }

  void _handleFileSelected(String path) {
    setState(() {
      _currentFilePath = path;
      _saveStatus = 'Saved';
    });
  }

  void _handleContentChanged(String content) {
    setState(() {
      _editorContent = content;
      _saveStatus = 'Modified';
      _updateCursorPosition(content);
    });
  }

  void _updateCursorPosition(String content) {
    final lines = content.split('\n');
    _line = lines.length;
    _column = lines.last.length + 1;
  }
}

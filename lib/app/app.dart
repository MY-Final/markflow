import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/core/registry/command_registry.dart';
import 'package:markflow/core/registry/shortcut_registry.dart';
import 'package:markflow/features/title_bar/custom_title_bar.dart';
import 'package:markflow/features/toolbar/modern_toolbar.dart';
import 'package:markflow/features/file_explorer/modern_file_explorer.dart';
import 'package:markflow/features/editor/widgets/modern_editor.dart';
import 'package:markflow/features/preview/modern_preview.dart';
import 'package:markflow/features/status_bar/status_bar.dart';
import 'package:markflow/features/command_palette/command_palette.dart';

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
  bool _isSidebarVisible = true;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupCommands();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _setupCommands() {
    final commandRegistry = CommandRegistry();
    
    // Override commands with actual implementations
    commandRegistry.registerCommand(Command(
      id: 'editor.save',
      title: 'Save',
      description: 'Save current file',
      category: 'Editor',
      icon: Icons.save_rounded,
      handler: (args) async {
        setState(() => _saveStatus = 'Saved');
      },
    ));

    commandRegistry.registerCommand(Command(
      id: 'view.toggleSidebar',
      title: 'Toggle Sidebar',
      description: 'Show or hide sidebar',
      category: 'View',
      icon: Icons.view_sidebar_rounded,
      handler: (args) async {
        setState(() => _isSidebarVisible = !_isSidebarVisible);
      },
    ));

    commandRegistry.registerCommand(Command(
      id: 'view.togglePreview',
      title: 'Toggle Preview',
      description: 'Show or hide preview panel',
      category: 'View',
      icon: Icons.preview_rounded,
      handler: (args) async {
        setState(() => _isPreviewMode = !_isPreviewMode);
      },
    ));

    commandRegistry.registerCommand(Command(
      id: 'commandPalette.open',
      title: 'Command Palette',
      description: 'Open command palette',
      category: 'General',
      icon: Icons.search_rounded,
      handler: (args) async {
        if (mounted) {
          CommandPalette.show(context);
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Column(
          children: [
            // 自定义标题栏
            CustomTitleBar(
              currentFileName: _currentFilePath?.split('/').last.split('\\').last,
              isSaved: _saveStatus == 'Saved',
            ),

            // 工具栏
            ModernToolbar(
              onBold: () => CommandRegistry().executeCommand('editor.insertBold'),
              onItalic: () => CommandRegistry().executeCommand('editor.insertItalic'),
              onCode: () => CommandRegistry().executeCommand('editor.insertCode'),
              onUndo: () => CommandRegistry().executeCommand('editor.undo'),
              onRedo: () => CommandRegistry().executeCommand('editor.redo'),
              onTogglePreview: () {
                CommandRegistry().executeCommand('view.togglePreview');
              },
              isPreviewMode: _isPreviewMode,
            ),

            // 主内容区域 - 三栏布局
            Expanded(
              child: Row(
                children: [
                  // 左侧文件树
                  if (_isSidebarVisible)
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
                          )
                        : ModernMarkdownEditor(
                            initialContent: _editorContent,
                            onChanged: _handleContentChanged,
                          ),
                  ),

                  // 右侧预览区 (非预览模式时显示)
                  if (!_isPreviewMode)
                    Expanded(
                      flex: 2,
                      child: ModernPreviewPanel(
                        content: _editorContent,
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
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    // Build key combo string
    final parts = <String>[];
    if (HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed) {
      parts.add('ctrl');
    }
    if (HardwareKeyboard.instance.isShiftPressed) {
      parts.add('shift');
    }
    if (HardwareKeyboard.instance.isAltPressed) {
      parts.add('alt');
    }
    parts.add(event.logicalKey.keyLabel.toLowerCase());
    
    final keyCombo = parts.join('+');
    final commandId = AppShortcutRegistry().getCommandId(keyCombo);
    
    if (commandId != null) {
      CommandRegistry().executeCommand(commandId);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
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

import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/core/registry/command_registry.dart';
import 'package:markflow/core/registry/shortcut_registry.dart';
import 'package:markflow/core/utils/sync_scroll_controller.dart';
import 'package:markflow/features/title_bar/custom_title_bar.dart';
import 'package:markflow/features/file_explorer/file_explorer.dart';
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
  String? _rootPath;
  String _editorContent = '';
  String _saveStatus = 'Saved';
  int _line = 1;
  int _column = 1;
  bool _isPreviewMode = false;
  bool _isSidebarVisible = true;
  bool _isDragging = false;

  final FocusNode _focusNode = FocusNode();
  late final SyncScrollController _syncController;

  @override
  void initState() {
    super.initState();
    _syncController = SyncScrollController();
    _setupCommands();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _syncController.dispose();
    super.dispose();
  }

  void _setupCommands() {
    final commandRegistry = CommandRegistry();

    commandRegistry.registerCommand(Command(
      id: 'editor.save',
      title: '保存',
      description: '保存当前文件',
      category: '编辑器',
      icon: Icons.save_rounded,
      handler: (args) async {
        setState(() => _saveStatus = '已保存');
      },
    ));

    commandRegistry.registerCommand(Command(
      id: 'view.toggleSidebar',
      title: '切换侧边栏',
      description: '显示或隐藏侧边栏',
      category: '视图',
      icon: Icons.view_sidebar_rounded,
      handler: (args) async {
        setState(() => _isSidebarVisible = !_isSidebarVisible);
      },
    ));

    commandRegistry.registerCommand(Command(
      id: 'view.togglePreview',
      title: '切换预览',
      description: '显示或隐藏预览面板',
      category: '视图',
      icon: Icons.preview_rounded,
      handler: (args) async {
        setState(() => _isPreviewMode = !_isPreviewMode);
      },
    ));

    commandRegistry.registerCommand(Command(
      id: 'commandPalette.open',
      title: '命令面板',
      description: '打开命令面板',
      category: '通用',
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
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;

    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: DropTarget(
          onDragEntered: (detail) {
            setState(() => _isDragging = true);
          },
          onDragExited: (detail) {
            setState(() => _isDragging = false);
          },
          onDragDone: (detail) {
            setState(() => _isDragging = false);
            _handleDrop(detail);
          },
          child: Stack(
            children: [
              Column(
                children: [
                  // 自定义标题栏
                  CustomTitleBar(
                    currentFileName: _currentFilePath?.split('/').last.split('\\').last,
                    isSaved: _saveStatus == '已保存',
                  ),

                  // 主内容区域 - 三栏布局
                  Expanded(
                    child: Row(
                      children: [
                        // 左侧文件树
                        if (_isSidebarVisible)
                          FileExplorer(
                            rootPath: _rootPath,
                            selectedFilePath: _currentFilePath,
                            onFileSelected: _handleFileSelected,
                            onFolderOpened: _handleFolderOpened,
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
                                  filePath: _currentFilePath ?? '',
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

              // 拖拽覆盖层
              if (_isDragging)
                Container(
                  color: theme.primaryMist.withValues(alpha: 0.8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.primary,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primary.withValues(alpha: 0.2),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 64,
                            color: theme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '释放以打开文件夹',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '支持拖入文件夹到此处打开',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.tertiaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDrop(DropDoneDetails detail) {
    for (final file in detail.files) {
      final path = file.path;
      final entity = FileSystemEntity.typeSync(path);
      
      if (entity == FileSystemEntityType.directory) {
        _handleFolderOpened(path);
        break;
      } else if (entity == FileSystemEntityType.file) {
        _handleFileSelected(path);
        break;
      }
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

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

  void _handleFolderOpened(String path) {
    setState(() {
      _rootPath = path;
    });
  }

  void _handleFileSelected(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _currentFilePath = path;
          _editorContent = content;
          _saveStatus = '已保存';
        });
      }
    } catch (e) {
      debugPrint('Error reading file: $e');
    }
  }

  void _handleContentChanged(String content) {
    setState(() {
      _editorContent = content;
      _saveStatus = '已修改';
      _updateCursorPosition(content);
    });
  }

  void _updateCursorPosition(String content) {
    final lines = content.split('\n');
    _line = lines.length;
    _column = lines.last.length + 1;
  }
}

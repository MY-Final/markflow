import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/core/registry/command_registry.dart';
import 'package:markflow/core/registry/shortcut_registry.dart';
import 'package:markflow/core/utils/file_utils.dart';
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
  String _saveStatus = '已保存';
  int _line = 1;
  int _column = 1;
  bool _isPreviewMode = false;
  bool _isSidebarVisible = true;
  bool _isDragging = false;

  // 大文件处理相关状态
  FileCategory _fileCategory = FileCategory.markdown;
  bool _isFileTruncated = false;
  int _totalLines = 0;
  static const _largeFileThreshold = 1 * 1024 * 1024; // 1MB
  static const _truncatedMaxLines = 5000;

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
                                  filePath: _currentFilePath,
                                  fileCategory: _fileCategory,
                                  isTruncated: _isFileTruncated,
                                  totalLines: _totalLines,
                                  scrollController: _syncController.rightController,
                                )
                              : ModernMarkdownEditor(
                                  filePath: _currentFilePath ?? '',
                                  initialContent: _editorContent,
                                  onChanged: _handleContentChanged,
                                  scrollController: _syncController.leftController,
                                  fileCategory: _fileCategory,
                                  isReadOnly: _fileCategory != FileCategory.markdown,
                                  isTruncated: _isFileTruncated,
                                  totalLines: _totalLines,
                                  onLoadFullFile: _handleLoadFullFile,
                                ),
                        ),

                        // 右侧预览区 (非预览模式时显示)
                        if (!_isPreviewMode)
                          Expanded(
                            flex: 2,
                            child: ModernPreviewPanel(
                              content: _editorContent,
                              filePath: _currentFilePath,
                              fileCategory: _fileCategory,
                              isTruncated: _isFileTruncated,
                              totalLines: _totalLines,
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
      if (!await file.exists()) return;

      // MarkFlow 只处理 Markdown 文件
      if (!FileUtils.isMarkdownFile(path)) {
        _showSnackBar('仅支持打开 Markdown 文件（.md / .markdown / .mdown）');
        return;
      }

      final fileSize = await file.length();
      String content;
      bool isTruncated = false;
      int totalLines = 0;

      if (fileSize > _largeFileThreshold) {
        // 大 Markdown 文件：弹窗确认
        final lines = await file.readAsLines();
        totalLines = lines.length;

        final confirmed = await _showMarkdownLargeWarningDialog(
          fileSize: fileSize,
          totalLines: totalLines,
        );
        if (!confirmed) return;

        if (totalLines > _truncatedMaxLines) {
          content = lines.take(_truncatedMaxLines).join('\n');
          content += '\n\n--- 文件过大（共 $totalLines 行），仅显示前 $_truncatedMaxLines 行 ---';
          isTruncated = true;
        } else {
          content = lines.join('\n');
        }
      } else {
        // 正常文件：直接读取
        content = await file.readAsString();
        totalLines = '\n'.allMatches(content).length + 1;
      }

      setState(() {
        _currentFilePath = path;
        _editorContent = content;
        _fileCategory = FileCategory.markdown;
        _isFileTruncated = isTruncated;
        _totalLines = totalLines;
        _saveStatus = '已保存';
      });
    } catch (e) {
      debugPrint('Error reading file: $e');
    }
  }

  /// Markdown 大文件确认弹窗
  Future<bool> _showMarkdownLargeWarningDialog({
    required int fileSize,
    required int totalLines,
  }) async {
    final sizeText = FileUtils.formatFileSize(fileSize);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Text('Markdown 文件较大'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '文件大小为 $sizeText，共 $totalLines 行。',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '预览面板会对 Markdown 全量解析渲染，大文件可能导致卡顿。'
              '${totalLines > _truncatedMaxLines ? "\n将仅加载前 $_truncatedMaxLines 行。" : ""}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('继续打开'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 加载完整文件（由编辑器截断提示条中的按钮触发）
  void _handleLoadFullFile() {
    if (_currentFilePath == null) return;
    final path = _currentFilePath!;
    // 重新走 _handleFileSelected，但跳过弹窗直接全量加载
    _loadFullFile(path);
  }

  Future<void> _loadFullFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final totalLines = '\n'.allMatches(content).length + 1;
      setState(() {
        _editorContent = content;
        _isFileTruncated = false;
        _totalLines = totalLines;
      });
    } catch (e) {
      debugPrint('Error loading full file: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
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

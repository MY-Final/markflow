import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/core/registry/command_registry.dart';
import 'package:markflow/core/registry/shortcut_registry.dart';
import 'package:markflow/core/utils/file_utils.dart';
import 'package:markflow/core/utils/sync_scroll_controller.dart';
import 'package:markflow/features/title_bar/custom_title_bar.dart';
import 'package:markflow/features/toolbar/modern_toolbar.dart';
import 'package:markflow/features/file_explorer/file_explorer.dart';
import 'package:markflow/features/editor/widgets/modern_editor.dart';
import 'package:markflow/features/preview/modern_preview.dart';
import 'package:markflow/features/status_bar/status_bar.dart';
import 'package:markflow/features/command_palette/command_palette.dart';

/// 视图模式
enum ViewMode {
  /// 只显示编辑器
  edit,

  /// 编辑器 + 预览并排
  split,

  /// 只显示预览
  preview,
}

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
  ViewMode _viewMode = ViewMode.split;
  bool _isSidebarVisible = true;
  bool _isDragging = false;

  FileCategory _fileCategory = FileCategory.markdown;
  bool _isFileTruncated = false;
  int _totalLines = 0;
  static const _largeFileThreshold = 1 * 1024 * 1024;
  static const _truncatedMaxLines = 5000;

  final FocusNode _focusNode = FocusNode();
  late final SyncScrollController _syncController;
  final GlobalKey<ModernMarkdownEditorState> _editorKey = GlobalKey<ModernMarkdownEditorState>();

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

  // ==================== 命令注册 ====================

  void _setupCommands() {
    final cr = CommandRegistry();

    // ---- 新建文件 ----
    cr.registerCommand(Command(
      id: 'file.new',
      title: '新建文件',
      description: '创建新的 Markdown 文件',
      category: '文件',
      icon: Icons.note_add_rounded,
      shortcut: 'Ctrl+N',
      handler: (args) async => _handleNewFile(),
    ));

    // ---- 打开文件 ----
    cr.registerCommand(Command(
      id: 'file.open',
      title: '打开文件',
      description: '打开已有的 Markdown 文件',
      category: '文件',
      icon: Icons.folder_open_rounded,
      shortcut: 'Ctrl+O',
      handler: (args) async => _handleOpenFile(),
    ));

    // ---- 保存 ----
    cr.registerCommand(Command(
      id: 'editor.save',
      title: '保存',
      description: '保存当前文件',
      category: '编辑器',
      icon: Icons.save_rounded,
      shortcut: 'Ctrl+S',
      handler: (args) => _handleSave(),
    ));

    // ---- 撤销/重做（TextField 内建，这里留空壳） ----
    cr.registerCommand(Command(
      id: 'editor.undo',
      title: '撤销',
      description: '撤销上一步操作',
      category: '编辑器',
      icon: Icons.undo_rounded,
      shortcut: 'Ctrl+Z',
      handler: (args) async {},
    ));
    cr.registerCommand(Command(
      id: 'editor.redo',
      title: '重做',
      description: '重做上一步操作',
      category: '编辑器',
      icon: Icons.redo_rounded,
      shortcut: 'Ctrl+Y',
      handler: (args) async {},
    ));

    // ---- 加粗 / 斜体 ----
    cr.registerCommand(Command(
      id: 'editor.insertBold',
      title: '加粗',
      description: '插入粗体文本',
      category: '编辑器',
      icon: Icons.format_bold_rounded,
      shortcut: 'Ctrl+B',
      handler: (args) async {
        _editorKey.currentState?.wrapSelectedText('**', '**');
      },
    ));
    cr.registerCommand(Command(
      id: 'editor.insertItalic',
      title: '斜体',
      description: '插入斜体文本',
      category: '编辑器',
      icon: Icons.format_italic_rounded,
      shortcut: 'Ctrl+I',
      handler: (args) async {
        _editorKey.currentState?.wrapSelectedText('*', '*');
      },
    ));

    // ---- 代码块 ----
    cr.registerCommand(Command(
      id: 'editor.insertCode',
      title: '代码块',
      description: '插入代码块',
      category: '编辑器',
      icon: Icons.code_rounded,
      handler: (args) async {
        _editorKey.currentState?.wrapSelectedText('```\n', '\n```');
      },
    ));

    // ---- 引用 ----
    cr.registerCommand(Command(
      id: 'editor.insertQuote',
      title: '引用',
      description: '插入引用',
      category: '编辑器',
      icon: Icons.format_quote_rounded,
      handler: (args) async {
        _editorKey.currentState?.insertAtLineStart('> ');
      },
    ));

    // ---- 无序列表 ----
    cr.registerCommand(Command(
      id: 'editor.insertUnorderedList',
      title: '无序列表',
      description: '插入无序列表',
      category: '编辑器',
      icon: Icons.format_list_bulleted_rounded,
      handler: (args) async {
        _editorKey.currentState?.insertAtLineStart('- ');
      },
    ));

    // ---- 有序列表 ----
    cr.registerCommand(Command(
      id: 'editor.insertOrderedList',
      title: '有序列表',
      description: '插入有序列表',
      category: '编辑器',
      icon: Icons.format_list_numbered_rounded,
      handler: (args) async {
        _editorKey.currentState?.insertAtLineStart('1. ');
      },
    ));

    // ---- 标题 ----
    cr.registerCommand(Command(
      id: 'editor.insertHeading',
      title: '标题',
      description: '插入标题',
      category: '编辑器',
      icon: Icons.title_rounded,
      handler: (args) async {
        _editorKey.currentState?.insertAtLineStart('## ');
      },
    ));

    // ---- 分割线 ----
    cr.registerCommand(Command(
      id: 'editor.insertDivider',
      title: '分割线',
      description: '插入分割线',
      category: '编辑器',
      icon: Icons.horizontal_rule_rounded,
      handler: (args) async {
        _editorKey.currentState?.insertText('\n---\n');
      },
    ));

    // ---- 链接 ----
    cr.registerCommand(Command(
      id: 'editor.insertLink',
      title: '链接',
      description: '插入链接',
      category: '编辑器',
      icon: Icons.link_rounded,
      handler: (args) async {
        final editor = _editorKey.currentState;
        if (editor == null) return;
        final selected = editor.getSelectedText();
        if (selected.isNotEmpty) {
          editor.replaceSelectedText('[$selected](url)');
        } else {
          editor.insertText('[链接文字](url)');
        }
      },
    ));

    // ---- 视图命令 ----
    cr.registerCommand(Command(
      id: 'view.toggleSidebar',
      title: '切换侧边栏',
      description: '显示或隐藏侧边栏',
      category: '视图',
      icon: Icons.view_sidebar_rounded,
      handler: (args) async {
        setState(() => _isSidebarVisible = !_isSidebarVisible);
      },
    ));
    cr.registerCommand(Command(
      id: 'view.editMode',
      title: '编辑模式',
      description: '仅显示编辑器',
      category: '视图',
      icon: Icons.edit_rounded,
      handler: (args) async {
        setState(() => _viewMode = ViewMode.edit);
      },
    ));
    cr.registerCommand(Command(
      id: 'view.splitMode',
      title: '分屏模式',
      description: '编辑器与预览并排显示',
      category: '视图',
      icon: Icons.vertical_split_rounded,
      handler: (args) async {
        setState(() => _viewMode = ViewMode.split);
      },
    ));
    cr.registerCommand(Command(
      id: 'view.previewMode',
      title: '预览模式',
      description: '仅显示预览',
      category: '视图',
      icon: Icons.preview_rounded,
      handler: (args) async {
        setState(() => _viewMode = ViewMode.preview);
      },
    ));

    // ---- 命令面板 ----
    cr.registerCommand(Command(
      id: 'commandPalette.open',
      title: '命令面板',
      description: '打开命令面板',
      category: '通用',
      icon: Icons.search_rounded,
      handler: (args) async {
        if (mounted) CommandPalette.show(context);
      },
    ));
  }

  // ==================== 文件操作 ====================

  void _handleNewFile() {
    setState(() {
      _currentFilePath = null;
      _editorContent = '';
      _fileCategory = FileCategory.markdown;
      _isFileTruncated = false;
      _totalLines = 0;
      _saveStatus = '未保存';
      _line = 1;
      _column = 1;
    });
  }

  Future<void> _handleOpenFile() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '打开 Markdown 文件',
      type: FileType.custom,
      allowedExtensions: ['md', 'markdown', 'mdown', 'txt'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path != null) {
      _handleFileSelected(path);
    }
  }

  // ==================== 保存 ====================

  Future<void> _handleSave() async {
    if (_currentFilePath != null) {
      try {
        final file = File(_currentFilePath!);
        final content = _editorKey.currentState?.getText() ?? _editorContent;
        await file.writeAsString(content);
        setState(() {
          _editorContent = content;
          _saveStatus = '已保存';
        });
      } catch (e) {
        _showSnackBar('保存失败: $e');
      }
    } else {
      await _handleSaveAs();
    }
  }

  Future<void> _handleSaveAs() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: '另存为',
      fileName: 'untitled.md',
      type: FileType.custom,
      allowedExtensions: ['md', 'markdown', 'txt'],
    );
    if (result == null) return;

    try {
      final file = File(result);
      final content = _editorKey.currentState?.getText() ?? _editorContent;
      await file.writeAsString(content);
      setState(() {
        _currentFilePath = result;
        _editorContent = content;
        _saveStatus = '已保存';
      });
    } catch (e) {
      _showSnackBar('保存失败: $e');
    }
  }

  // ==================== 布局 ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;

    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: DropTarget(
          onDragEntered: (detail) => setState(() => _isDragging = true),
          onDragExited: (detail) => setState(() => _isDragging = false),
          onDragDone: (detail) {
            setState(() => _isDragging = false);
            _handleDrop(detail);
          },
          child: Stack(
            children: [
              Column(
                children: [
                  CustomTitleBar(
                    currentFileName: _currentFilePath?.split('/').last.split('\\').last,
                    isSaved: _saveStatus == '已保存',
                  ),
                  ModernToolbar(
                    onCommand: (id) => CommandRegistry().executeCommand(id),
                    viewMode: _viewMode,
                    fileCategory: _fileCategory,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        if (_isSidebarVisible)
                          FileExplorer(
                            rootPath: _rootPath,
                            selectedFilePath: _currentFilePath,
                            onFileSelected: _handleFileSelected,
                            onFolderOpened: _handleFolderOpened,
                          ),
                        // 编辑器（Edit 和 Split 模式显示）
                        if (_viewMode != ViewMode.preview)
                          Expanded(
                            flex: _viewMode == ViewMode.split ? 3 : 1,
                            child: ModernMarkdownEditor(
                              key: _editorKey,
                              filePath: _currentFilePath ?? '',
                              initialContent: _editorContent,
                              onChanged: _handleContentChanged,
                              onCursorChanged: _handleCursorChanged,
                              scrollController: _syncController.leftController,
                              fileCategory: _fileCategory,
                              isReadOnly: _fileCategory != FileCategory.markdown,
                              isTruncated: _isFileTruncated,
                              totalLines: _totalLines,
                              onLoadFullFile: _handleLoadFullFile,
                            ),
                          ),
                        // 预览面板（Split 和 Preview 模式显示）
                        if (_viewMode != ViewMode.edit)
                          Expanded(
                            flex: _viewMode == ViewMode.split ? 2 : 1,
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
                  ModernStatusBar(
                    saveStatus: _saveStatus,
                    line: _line,
                    column: _column,
                    fileType: _statusBarFileType(),
                  ),
                ],
              ),
              if (_isDragging) _buildDropOverlay(theme),
            ],
          ),
        ),
      ),
    );
  }

  String _statusBarFileType() {
    switch (_fileCategory) {
      case FileCategory.markdown:
        return 'Markdown';
      case FileCategory.data:
        return 'Data';
      case FileCategory.log:
        return 'Log';
      case FileCategory.text:
        return 'Text';
      case FileCategory.binary:
        return 'Binary';
    }
  }

  Widget _buildDropOverlay(MarkFlowTheme theme) {
    return Container(
      color: theme.primaryMist.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.primary, width: 2, strokeAlign: BorderSide.strokeAlignInside),
            boxShadow: [
              BoxShadow(color: theme.primary.withValues(alpha: 0.2), blurRadius: 32, offset: const Offset(0, 16)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open_rounded, size: 64, color: theme.primary),
              const SizedBox(height: 16),
              Text('释放以打开文件夹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.text)),
              const SizedBox(height: 8),
              Text('支持拖入文件夹到此处打开', style: TextStyle(fontSize: 14, color: theme.tertiaryText)),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 事件处理 ====================

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
    setState(() => _rootPath = path);
  }

  void _handleFileSelected(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return;

      if (!FileUtils.isMarkdownFile(path)) {
        _showSnackBar('仅支持打开 Markdown 文件（.md / .markdown / .mdown）');
        return;
      }

      final fileSize = await file.length();
      String content;
      bool isTruncated = false;
      int totalLines = 0;

      if (fileSize > _largeFileThreshold) {
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
            Text('文件大小为 $sizeText，共 $totalLines 行。', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              '预览面板会对 Markdown 全量解析渲染，大文件可能导致卡顿。'
              '${totalLines > _truncatedMaxLines ? "\n将仅加载前 $_truncatedMaxLines 行。" : ""}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('继续打开')),
        ],
      ),
    );
    return result ?? false;
  }

  void _handleLoadFullFile() {
    if (_currentFilePath == null) return;
    _loadFullFile(_currentFilePath!);
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
    });
  }

  void _handleCursorChanged(int line, int column) {
    setState(() {
      _line = line;
      _column = column;
    });
  }
}

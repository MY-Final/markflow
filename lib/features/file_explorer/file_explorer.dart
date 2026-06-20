import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:markflow/core/theme/theme.dart';
import 'package:markflow/core/utils/file_utils.dart';

class FileTreeNode {
  final String name;
  final String path;
  final bool isDirectory;
  final List<FileTreeNode> children;
  bool isExpanded;

  FileTreeNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.children = const [],
    this.isExpanded = false,
  });
}

class FileExplorer extends StatefulWidget {
  final String? rootPath;
  final String? selectedFilePath;
  final Function(String)? onFileSelected;
  final Function(String)? onFolderOpened;

  const FileExplorer({
    super.key,
    this.rootPath,
    this.selectedFilePath,
    this.onFileSelected,
    this.onFolderOpened,
  });

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  FileTreeNode? _rootNode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.rootPath != null) {
      _loadDirectory(widget.rootPath!);
    }
  }

  @override
  void didUpdateWidget(FileExplorer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rootPath != oldWidget.rootPath && widget.rootPath != null) {
      _loadDirectory(widget.rootPath!);
    }
  }

  Future<void> _loadDirectory(String path) async {
    setState(() => _isLoading = true);
    final directory = Directory(path);
    if (!await directory.exists()) {
      setState(() => _isLoading = false);
      return;
    }

    final node = await _buildTreeNode(directory);
    setState(() {
      _rootNode = node;
      _isLoading = false;
    });
  }

  Future<void> _refreshTree() async {
    if (widget.rootPath != null) {
      await _loadDirectory(widget.rootPath!);
    }
  }

  Future<FileTreeNode> _buildTreeNode(Directory directory) async {
    final List<FileTreeNode> children = [];

    try {
      final entities = directory.listSync()
        ..sort((a, b) {
          if (a is Directory && b is File) return -1;
          if (a is File && b is Directory) return 1;
          return a.path.compareTo(b.path);
        });

      for (final entity in entities) {
        final name = entity.path.split(Platform.pathSeparator).last;
        if (name.startsWith('.')) continue;

        if (entity is Directory) {
          children.add(FileTreeNode(
            name: name,
            path: entity.path,
            isDirectory: true,
          ));
        } else if (entity is File && FileUtils.isMarkdownFile(entity.path)) {
          children.add(FileTreeNode(
            name: name,
            path: entity.path,
            isDirectory: false,
          ));
        }
      }
    } catch (e) {
      // 忽略无权限目录
    }

    return FileTreeNode(
      name: directory.path.split(Platform.pathSeparator).last,
      path: directory.path,
      isDirectory: true,
      children: children,
    );
  }

  Future<void> _openFolder() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Open Folder',
    );

    if (result != null) {
      await _loadDirectory(result);
      widget.onFolderOpened?.call(result);
    }
  }

  // ==================== 右键菜单操作 ====================

  OverlayEntry? _contextMenuOverlay;

  void _showContextMenu(BuildContext anchorContext, FileTreeNode node, Offset position) {
    _closeContextMenu();
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;
    final isDir = node.isDirectory;

    final items = <_ContextMenuItem>[
      if (isDir) _ContextMenuItem('newFile', Icons.note_add_rounded, '新建 Markdown 文件'),
      if (isDir) _ContextMenuItem('newFolder', Icons.create_new_folder_rounded, '新建文件夹'),
      if (isDir) _ContextMenuItem('rename', Icons.edit_rounded, '重命名'),
      if (!isDir) _ContextMenuItem('rename', Icons.edit_rounded, '重命名'),
      if (!isDir) _ContextMenuItem('copyPath', Icons.content_copy_rounded, '复制路径'),
      _ContextMenuItem('delete', Icons.delete_outline_rounded, '删除', isDestructive: true),
    ];

    _contextMenuOverlay = OverlayEntry(
      builder: (ctx) => _ContextMenuWidget(
        position: position,
        theme: theme,
        items: items,
        onTap: (action) {
          _closeContextMenu();
          _handleMenuAction(action, node);
        },
        onDismiss: _closeContextMenu,
      ),
    );

    Overlay.of(context).insert(_contextMenuOverlay!);
  }

  void _closeContextMenu() {
    _contextMenuOverlay?.remove();
    _contextMenuOverlay = null;
  }

  void _handleMenuAction(String action, FileTreeNode node) {
    switch (action) {
      case 'newFile':
        _createNewFile(node.path);
        break;
      case 'newFolder':
        _createNewFolder(node.path);
        break;
      case 'rename':
        _renameItem(node);
        break;
      case 'delete':
        _deleteItem(node);
        break;
      case 'copyPath':
        Clipboard.setData(ClipboardData(text: node.path));
        _showSnackBar('已复制路径');
        break;
    }
  }

  Future<void> _createNewFile(String parentDir) async {
    final name = await _showInputDialog(
      title: '新建 Markdown 文件',
      label: '文件名',
      initialValue: 'untitled.md',
      validator: (v) => v.trim().isEmpty ? '文件名不能为空' : null,
    );
    if (name == null) return;

    final path = '$parentDir${Platform.pathSeparator}$name';
    try {
      final file = File(path);
      if (await file.exists()) {
        _showSnackBar('文件已存在');
        return;
      }
      await file.writeAsString('');
      await _refreshTree();
      widget.onFileSelected?.call(path);
    } catch (e) {
      _showSnackBar('创建失败: $e');
    }
  }

  Future<void> _createNewFolder(String parentDir) async {
    final name = await _showInputDialog(
      title: '新建文件夹',
      label: '文件夹名',
      initialValue: 'new_folder',
      validator: (v) => v.trim().isEmpty ? '文件夹名不能为空' : null,
    );
    if (name == null) return;

    final path = '$parentDir${Platform.pathSeparator}$name';
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        _showSnackBar('文件夹已存在');
        return;
      }
      await dir.create();
      await _refreshTree();
    } catch (e) {
      _showSnackBar('创建失败: $e');
    }
  }

  Future<void> _renameItem(FileTreeNode node) async {
    final name = await _showInputDialog(
      title: '重命名',
      label: '新名称',
      initialValue: node.name,
      validator: (v) => v.trim().isEmpty ? '名称不能为空' : null,
    );
    if (name == null || name == node.name) return;

    final parentDir = FileUtils.getDirectoryPath(node.path);
    final newPath = '$parentDir${Platform.pathSeparator}$name';
    try {
      if (node.isDirectory) {
        await Directory(node.path).rename(newPath);
      } else {
        await File(node.path).rename(newPath);
      }
      await _refreshTree();
    } catch (e) {
      _showSnackBar('重命名失败: $e');
    }
  }

  Future<void> _deleteItem(FileTreeNode node) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除${node.isDirectory ? "文件夹" : "文件"}'),
        content: Text('确定要删除「${node.name}」吗？\n此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      if (node.isDirectory) {
        await Directory(node.path).delete(recursive: true);
      } else {
        await File(node.path).delete();
      }
      await _refreshTree();
      _showSnackBar('已删除「${node.name}」');
    } catch (e) {
      _showSnackBar('删除失败: $e');
    }
  }

  Future<String?> _showInputDialog({
    required String title,
    required String label,
    required String initialValue,
    String? Function(String)? validator,
  }) {
    final controller = TextEditingController(text: initialValue);
    controller.selection = TextSelection(baseOffset: 0, extentOffset: initialValue.length);
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            validator: validator != null ? (v) => validator(v ?? '') : null,
            onFieldSubmitted: (_) {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: theme.explorerBackground,
        border: Border(
          right: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: _isLoading
                ? _buildLoadingState(theme)
                : _rootNode != null
                    ? _buildTreeView(_rootNode!, 0, theme)
                    : _buildEmptyState(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(MarkFlowTheme theme) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.folder_rounded, size: 16, color: theme.tertiaryText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _rootNode?.name ?? 'EXPLORER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.tertiaryText,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _HeaderButton(
            icon: Icons.folder_open_rounded,
            onTap: _openFolder,
            tooltip: 'Open Folder',
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(MarkFlowTheme theme) {
    return Center(
      child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary),
    );
  }

  Widget _buildEmptyState(MarkFlowTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 48, color: theme.ghostText),
          const SizedBox(height: 16),
          Text('No folder opened', style: TextStyle(fontSize: 13, color: theme.tertiaryText)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _openFolder,
            icon: Icon(Icons.folder_open_rounded, size: 16, color: theme.primary),
            label: Text('Open Folder', style: TextStyle(fontSize: 12, color: theme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeView(FileTreeNode node, int depth, MarkFlowTheme theme) {
    if (node.isDirectory) {
      return _buildDirectoryNode(node, depth, theme);
    } else {
      return _buildFileNode(node, depth, theme);
    }
  }

  Widget _buildDirectoryNode(FileTreeNode node, int depth, MarkFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FileTreeItem(
          icon: node.isExpanded
              ? Icons.keyboard_arrow_down_rounded
              : Icons.keyboard_arrow_right_rounded,
          label: node.name,
          isDirectory: true,
          isExpanded: node.isExpanded,
          depth: depth,
          onTap: () => setState(() => node.isExpanded = !node.isExpanded),
          onSecondaryTap: (pos) => _showContextMenu(context, node, pos),
          theme: theme,
        ),
        if (node.isExpanded)
          ...node.children.map(
            (child) => _buildTreeView(child, depth + 1, theme),
          ),
      ],
    );
  }

  Widget _buildFileNode(FileTreeNode node, int depth, MarkFlowTheme theme) {
    final isSelected = widget.selectedFilePath == node.path;

    return _FileTreeItem(
      icon: _getFileIcon(node.name),
      iconColor: _getFileIconColor(node.name, theme),
      label: node.name,
      isDirectory: false,
      isSelected: isSelected,
      depth: depth,
      onTap: () => widget.onFileSelected?.call(node.path),
      onSecondaryTap: (pos) => _showContextMenu(context, node, pos),
      theme: theme,
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'md':
      case 'markdown':
        return Icons.description_outlined;
      case 'dart':
        return Icons.code_rounded;
      case 'json':
        return Icons.data_object_rounded;
      case 'yaml':
      case 'yml':
        return Icons.settings_outlined;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        return Icons.image_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getFileIconColor(String fileName, MarkFlowTheme theme) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'md':
      case 'markdown':
        return theme.primary;
      case 'dart':
        return const Color(0xFF0175C2);
      case 'json':
        return const Color(0xFFF5A623);
      case 'yaml':
      case 'yml':
        return const Color(0xFFCB171E);
      default:
        return theme.tertiaryText;
    }
  }
}

class _HeaderButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final MarkFlowTheme theme;

  const _HeaderButton({
    required this.icon,
    this.onTap,
    this.tooltip,
    required this.theme,
  });

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _isHovered ? widget.theme.hover : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(widget.icon, size: 16, color: widget.theme.tertiaryText),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip, child: button);
    }
    return button;
  }
}

class _FileTreeItem extends StatefulWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final bool isDirectory;
  final bool isExpanded;
  final bool isSelected;
  final int depth;
  final VoidCallback? onTap;
  final void Function(Offset position)? onSecondaryTap;
  final MarkFlowTheme theme;

  const _FileTreeItem({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.isDirectory,
    this.isExpanded = false,
    this.isSelected = false,
    required this.depth,
    this.onTap,
    this.onSecondaryTap,
    required this.theme,
  });

  @override
  State<_FileTreeItem> createState() => _FileTreeItemState();
}

class _FileTreeItemState extends State<_FileTreeItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTapDown: (details) {
          widget.onSecondaryTap?.call(details.globalPosition);
        },
        child: Container(
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                width: 3,
                height: widget.isSelected ? 24 : 0,
                decoration: BoxDecoration(
                  color: widget.theme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(
                    left: 8.0 + widget.depth * 16,
                    right: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? widget.theme.selected : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 32,
                  child: Row(
                    children: [
                      Icon(
                        widget.icon,
                        size: 16,
                        color: widget.isDirectory
                            ? widget.theme.tertiaryText
                            : widget.iconColor ?? widget.theme.tertiaryText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.isSelected
                                ? widget.theme.text
                                : widget.theme.secondaryText,
                            fontWeight: widget.isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 自定义上下文菜单 ====================

class _ContextMenuItem {
  final String action;
  final IconData icon;
  final String label;
  final bool isDestructive;

  _ContextMenuItem(this.action, this.icon, this.label, {this.isDestructive = false});
}

class _ContextMenuWidget extends StatefulWidget {
  final Offset position;
  final MarkFlowTheme theme;
  final List<_ContextMenuItem> items;
  final void Function(String action) onTap;
  final VoidCallback onDismiss;

  const _ContextMenuWidget({
    required this.position,
    required this.theme,
    required this.items,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_ContextMenuWidget> createState() => _ContextMenuWidgetState();
}

class _ContextMenuWidgetState extends State<_ContextMenuWidget> {
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double left = widget.position.dx;
    double top = widget.position.dy;

    const menuWidth = 200.0;
    final itemHeight = 34.0;
    final menuHeight = widget.items.length * itemHeight + 8;

    if (left + menuWidth > screenWidth) left = screenWidth - menuWidth - 8;
    if (top + menuHeight > screenHeight) top = screenHeight - menuHeight - 8;

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onDismiss,
          behavior: HitTestBehavior.translucent,
          child: Container(
            color: Colors.transparent,
          ),
        ),
        Positioned(
          left: left,
          top: top,
          child: MouseRegion(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: menuWidth,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: widget.theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: widget.theme.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    final isHovered = _hoveredIndex == index;
                    final color = item.isDestructive
                        ? Colors.red.shade600
                        : isHovered
                            ? widget.theme.text
                            : widget.theme.secondaryText;

                    return MouseRegion(
                      onEnter: (_) => setState(() => _hoveredIndex = index),
                      onExit: (_) => setState(() => _hoveredIndex = -1),
                      child: GestureDetector(
                        onTap: () => widget.onTap(item.action),
                        child: Container(
                          height: itemHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isHovered
                                ? (item.isDestructive
                                    ? Colors.red.withValues(alpha: 0.08)
                                    : widget.theme.hover)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(item.icon, size: 16, color: color),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: color,
                                    fontWeight: isHovered ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

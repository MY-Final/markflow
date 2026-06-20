import 'dart:io';
import 'package:flutter/material.dart';

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
  final Function(String)? onFileSelected;
  final Function(String)? onFileCreated;
  final Function(String)? onFolderCreated;

  const FileExplorer({
    super.key,
    this.rootPath,
    this.onFileSelected,
    this.onFileCreated,
    this.onFolderCreated,
  });

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  FileTreeNode? _rootNode;
  String? _selectedFilePath;

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
    final directory = Directory(path);
    if (!await directory.exists()) return;

    final node = await _buildTreeNode(directory);
    setState(() {
      _rootNode = node;
    });
  }

  Future<FileTreeNode> _buildTreeNode(Directory directory) async {
    final List<FileTreeNode> children = [];

    try {
      final entities = directory.listSync()
        ..sort((a, b) {
          // 目录优先
          if (a is Directory && b is File) return -1;
          if (a is File && b is Directory) return 1;
          // 按名称排序
          return a.path.compareTo(b.path);
        });

      for (final entity in entities) {
        final name = entity.path.split(Platform.pathSeparator).last;

        // 跳过隐藏文件
        if (name.startsWith('.')) continue;

        if (entity is Directory) {
          children.add(FileTreeNode(
            name: name,
            path: entity.path,
            isDirectory: true,
            children: [],
          ));
        } else if (entity is File) {
          children.add(FileTreeNode(
            name: name,
            path: entity.path,
            isDirectory: false,
          ));
        }
      }
    } catch (e) {
      // 忽略无权限的目录
    }

    return FileTreeNode(
      name: directory.path.split(Platform.pathSeparator).last,
      path: directory.path,
      isDirectory: true,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Color(0xFF424242) : Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _rootNode != null
                ? _buildTreeView(context, _rootNode!, 0)
                : _buildEmptyState(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF252525) : Color(0xFFF5F5F5),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Color(0xFF424242) : Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.folder,
            size: 16,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _rootNode?.name ?? '文件资源管理器',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.create_new_folder, size: 16),
            onPressed: _createNewFolder,
            tooltip: '新建文件夹',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.note_add, size: 16),
            onPressed: _createNewFile,
            tooltip: '新建文件',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 48,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            '未打开文件夹',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _openFolder,
            icon: Icon(Icons.folder_open, size: 16),
            label: Text('打开文件夹'),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeView(
    BuildContext context,
    FileTreeNode node,
    int depth,
  ) {
    if (node.isDirectory) {
      return _buildDirectoryNode(context, node, depth);
    } else {
      return _buildFileNode(context, node, depth);
    }
  }

  Widget _buildDirectoryNode(
    BuildContext context,
    FileTreeNode node,
    int depth,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              node.isExpanded = !node.isExpanded;
            });
          },
          child: Container(
            height: 32,
            padding: EdgeInsets.only(left: 12.0 + depth * 16),
            child: Row(
              children: [
                Icon(
                  node.isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                const SizedBox(width: 4),
                Icon(
                  node.isExpanded ? Icons.folder_open : Icons.folder,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (node.isExpanded)
          ...node.children.map((child) => _buildTreeView(context, child, depth + 1)),
      ],
    );
  }

  Widget _buildFileNode(
    BuildContext context,
    FileTreeNode node,
    int depth,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedFilePath == node.path;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilePath = node.path;
        });
        widget.onFileSelected?.call(node.path);
      },
      child: Container(
        height: 32,
        padding: EdgeInsets.only(left: 12.0 + depth * 16),
        color: isSelected
            ? (isDark ? Colors.blue.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.1))
            : null,
        child: Row(
          children: [
            Icon(
              _getFileIcon(node.name),
              size: 16,
              color: _getFileIconColor(node.name),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                node.name,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? (isDark ? Colors.blue[300] : Colors.blue[700])
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'md':
      case 'markdown':
        return Icons.description;
      case 'dart':
        return Icons.code;
      case 'json':
        return Icons.data_object;
      case 'yaml':
      case 'yml':
        return Icons.settings;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'md':
      case 'markdown':
        return Colors.blue;
      case 'dart':
        return Colors.blue;
      case 'json':
        return Colors.orange;
      case 'yaml':
      case 'yml':
        return Colors.purple;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        return Colors.green;
      case 'pdf':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _openFolder() {
    // TODO: 实现打开文件夹
  }

  void _createNewFile() {
    // TODO: 实现新建文件
  }

  void _createNewFolder() {
    // TODO: 实现新建文件夹
  }
}

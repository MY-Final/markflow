import 'dart:io';
import 'package:flutter/material.dart';
import 'package:markflow/core/theme/theme.dart';

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

class ModernFileExplorer extends StatefulWidget {
  final String? rootPath;
  final String? selectedFilePath;
  final Function(String)? onFileSelected;

  const ModernFileExplorer({
    super.key,
    this.rootPath,
    this.selectedFilePath,
    this.onFileSelected,
  });

  @override
  State<ModernFileExplorer> createState() => _ModernFileExplorerState();
}

class _ModernFileExplorerState extends State<ModernFileExplorer> {
  FileTreeNode? _rootNode;

  @override
  void initState() {
    super.initState();
    if (widget.rootPath != null) {
      _loadDirectory(widget.rootPath!);
    }
  }

  @override
  void didUpdateWidget(ModernFileExplorer oldWidget) {
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
        } else if (entity is File) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;
    
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: theme.explorerBackground,
        border: Border(
          right: BorderSide(
            color: theme.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: _rootNode != null
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
          Icon(
            Icons.folder_rounded,
            size: 16,
            color: theme.secondaryText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _rootNode?.name ?? 'EXPLORER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _HeaderButton(
            icon: Icons.create_new_folder_outlined,
            onTap: () {},
            theme: theme,
          ),
          const SizedBox(width: 4),
          _HeaderButton(
            icon: Icons.note_add_outlined,
            onTap: () {},
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(MarkFlowTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 48,
            color: theme.secondaryText.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No folder opened',
            style: TextStyle(
              fontSize: 13,
              color: theme.secondaryText.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.folder_open_rounded, size: 16, color: theme.primary),
            label: Text(
              'Open Folder',
              style: TextStyle(
                fontSize: 12,
                color: theme.primary,
              ),
            ),
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
          onTap: () {
            setState(() {
              node.isExpanded = !node.isExpanded;
            });
          },
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
        return theme.secondaryText;
    }
  }
}

class _HeaderButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final MarkFlowTheme theme;

  const _HeaderButton({
    required this.icon,
    this.onTap,
    required this.theme,
  });

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
          child: Icon(
            widget.icon,
            size: 16,
            color: widget.theme.secondaryText,
          ),
        ),
      ),
    );
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
    required this.theme,
  });

  @override
  State<_FileTreeItem> createState() => _FileTreeItemState();
}

class _FileTreeItemState extends State<_FileTreeItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: Container(
            height: 32,
            padding: EdgeInsets.only(
              left: 16.0 + widget.depth * 16,
              right: 8,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.theme.selected
                  : _isHovered
                      ? widget.theme.hover
                      : Colors.transparent,
              borderRadius: widget.isSelected || _isHovered
                  ? BorderRadius.circular(8)
                  : null,
            ),
            child: Row(
            children: [
              if (widget.isDirectory)
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.theme.secondaryText,
                )
              else
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.iconColor ?? widget.theme.secondaryText,
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
                    fontWeight: widget.isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

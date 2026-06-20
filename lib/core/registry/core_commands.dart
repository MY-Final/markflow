import 'package:flutter/material.dart';
import 'package:markflow/core/registry/command_registry.dart';
import 'package:markflow/core/registry/menu_registry.dart';
import 'package:markflow/core/registry/shortcut_registry.dart';

void registerCoreCommands() {
  final commandRegistry = CommandRegistry();
  final menuRegistry = MenuRegistry();
  final shortcutRegistry = AppShortcutRegistry();

  // Editor Commands
  commandRegistry.registerCommand(Command(
    id: 'editor.save',
    title: '保存',
    description: '保存当前文件',
    category: '编辑器',
    icon: Icons.save_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.save');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.saveAs',
    title: '另存为',
    description: '将当前文件另存为新文件',
    category: '编辑器',
    icon: Icons.save_as_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.saveAs');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.undo',
    title: '撤销',
    description: '撤销上一步操作',
    category: '编辑器',
    icon: Icons.undo_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.undo');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.redo',
    title: '重做',
    description: '重做上一步操作',
    category: '编辑器',
    icon: Icons.redo_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.redo');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.insertBold',
    title: '加粗',
    description: '插入粗体文本',
    category: '编辑器',
    icon: Icons.format_bold_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.insertBold');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.insertItalic',
    title: '斜体',
    description: '插入斜体文本',
    category: '编辑器',
    icon: Icons.format_italic_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.insertItalic');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.insertCode',
    title: '代码块',
    description: '插入代码块',
    category: '编辑器',
    icon: Icons.code_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.insertCode');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.insertImage',
    title: '插入图片',
    description: '从文件插入图片',
    category: '编辑器',
    icon: Icons.image_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.insertImage');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.insertTable',
    title: '插入表格',
    description: '插入 Markdown 表格',
    category: '编辑器',
    icon: Icons.table_chart_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.insertTable');
    },
  ));

  // View Commands
  commandRegistry.registerCommand(Command(
    id: 'view.toggleSidebar',
    title: '切换侧边栏',
    description: '显示或隐藏侧边栏',
    category: '视图',
    icon: Icons.view_sidebar_rounded,
    handler: (args) async {
      debugPrint('Execute: view.toggleSidebar');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'view.togglePreview',
    title: '切换预览',
    description: '显示或隐藏预览面板',
    category: '视图',
    icon: Icons.preview_rounded,
    handler: (args) async {
      debugPrint('Execute: view.togglePreview');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'view.zoomIn',
    title: '放大',
    description: '增大字体大小',
    category: '视图',
    icon: Icons.zoom_in_rounded,
    handler: (args) async {
      debugPrint('Execute: view.zoomIn');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'view.zoomOut',
    title: '缩小',
    description: '减小字体大小',
    category: '视图',
    icon: Icons.zoom_out_rounded,
    handler: (args) async {
      debugPrint('Execute: view.zoomOut');
    },
  ));

  // Theme Commands
  commandRegistry.registerCommand(Command(
    id: 'theme.toggle',
    title: '切换主题',
    description: '在亮色和暗色主题之间切换',
    category: '主题',
    icon: Icons.dark_mode_rounded,
    handler: (args) async {
      debugPrint('Execute: theme.toggle');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'theme.light',
    title: '亮色主题',
    description: '切换到亮色主题',
    category: '主题',
    icon: Icons.light_mode_rounded,
    handler: (args) async {
      debugPrint('Execute: theme.light');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'theme.dark',
    title: '暗色主题',
    description: '切换到暗色主题',
    category: '主题',
    icon: Icons.dark_mode_rounded,
    handler: (args) async {
      debugPrint('Execute: theme.dark');
    },
  ));

  // File Commands
  commandRegistry.registerCommand(Command(
    id: 'file.new',
    title: '新建文件',
    description: '创建新文件',
    category: '文件',
    icon: Icons.note_add_rounded,
    handler: (args) async {
      debugPrint('Execute: file.new');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'file.open',
    title: '打开文件',
    description: '打开已有文件',
    category: '文件',
    icon: Icons.folder_open_rounded,
    handler: (args) async {
      debugPrint('Execute: file.open');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'file.openFolder',
    title: '打开文件夹',
    description: '在资源管理器中打开文件夹',
    category: '文件',
    icon: Icons.folder_rounded,
    handler: (args) async {
      debugPrint('Execute: file.openFolder');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'file.close',
    title: '关闭文件',
    description: '关闭当前文件',
    category: '文件',
    icon: Icons.close_rounded,
    handler: (args) async {
      debugPrint('Execute: file.close');
    },
  ));

  // Command Palette
  commandRegistry.registerCommand(Command(
    id: 'commandPalette.open',
    title: '命令面板',
    description: '打开命令面板',
    category: '通用',
    icon: Icons.search_rounded,
    handler: (args) async {
      debugPrint('Execute: commandPalette.open');
    },
  ));

  // Register Shortcuts
  shortcutRegistry.registerShortcut(
    'ctrl+s',
    'editor.save',
  );
  shortcutRegistry.registerShortcut(
    'ctrl+z',
    'editor.undo',
  );
  shortcutRegistry.registerShortcut(
    'ctrl+y',
    'editor.redo',
  );
  shortcutRegistry.registerShortcut(
    'ctrl+b',
    'editor.insertBold',
  );
  shortcutRegistry.registerShortcut(
    'ctrl+i',
    'editor.insertItalic',
  );
  shortcutRegistry.registerShortcut(
    'ctrl+shift+p',
    'commandPalette.open',
  );

  // Register Menus
  menuRegistry.registerMenu('file', [
    MenuItem(id: 'new', label: '新建文件', commandId: 'file.new', icon: Icons.note_add_rounded),
    MenuItem(id: 'open', label: '打开文件', commandId: 'file.open', icon: Icons.folder_open_rounded),
    MenuItem(id: 'openFolder', label: '打开文件夹', commandId: 'file.openFolder', icon: Icons.folder_rounded),
    MenuItem.divider(),
    MenuItem(id: 'save', label: '保存', commandId: 'editor.save', icon: Icons.save_rounded),
    MenuItem(id: 'saveAs', label: '另存为', commandId: 'editor.saveAs', icon: Icons.save_as_rounded),
    MenuItem.divider(),
    MenuItem(id: 'close', label: '关闭', commandId: 'file.close', icon: Icons.close_rounded),
  ]);

  menuRegistry.registerMenu('edit', [
    MenuItem(id: 'undo', label: '撤销', commandId: 'editor.undo', icon: Icons.undo_rounded),
    MenuItem(id: 'redo', label: '重做', commandId: 'editor.redo', icon: Icons.redo_rounded),
    MenuItem.divider(),
    MenuItem(id: 'bold', label: '加粗', commandId: 'editor.insertBold', icon: Icons.format_bold_rounded),
    MenuItem(id: 'italic', label: '斜体', commandId: 'editor.insertItalic', icon: Icons.format_italic_rounded),
    MenuItem(id: 'code', label: '代码块', commandId: 'editor.insertCode', icon: Icons.code_rounded),
    MenuItem.divider(),
    MenuItem(id: 'image', label: '插入图片', commandId: 'editor.insertImage', icon: Icons.image_rounded),
    MenuItem(id: 'table', label: '插入表格', commandId: 'editor.insertTable', icon: Icons.table_chart_rounded),
  ]);

  menuRegistry.registerMenu('view', [
    MenuItem(id: 'sidebar', label: '切换侧边栏', commandId: 'view.toggleSidebar', icon: Icons.view_sidebar_rounded),
    MenuItem(id: 'preview', label: '切换预览', commandId: 'view.togglePreview', icon: Icons.preview_rounded),
    MenuItem.divider(),
    MenuItem(id: 'zoomIn', label: '放大', commandId: 'view.zoomIn', icon: Icons.zoom_in_rounded),
    MenuItem(id: 'zoomOut', label: '缩小', commandId: 'view.zoomOut', icon: Icons.zoom_out_rounded),
    MenuItem.divider(),
    MenuItem(id: 'theme', label: '切换主题', commandId: 'theme.toggle', icon: Icons.dark_mode_rounded),
  ]);

  menuRegistry.registerMenu('help', [
    MenuItem(id: 'commandPalette', label: '命令面板', commandId: 'commandPalette.open', icon: Icons.search_rounded),
  ]);
}

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
    title: 'Save',
    description: 'Save current file',
    category: 'Editor',
    icon: Icons.save_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.save');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.saveAs',
    title: 'Save As',
    description: 'Save current file as new file',
    category: 'Editor',
    icon: Icons.save_as_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.saveAs');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.undo',
    title: 'Undo',
    description: 'Undo last action',
    category: 'Editor',
    icon: Icons.undo_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.undo');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.redo',
    title: 'Redo',
    description: 'Redo last action',
    category: 'Editor',
    icon: Icons.redo_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.redo');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.insertBold',
    title: 'Bold',
    description: 'Insert bold text',
    category: 'Editor',
    icon: Icons.format_bold_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.insertBold');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.insertItalic',
    title: 'Italic',
    description: 'Insert italic text',
    category: 'Editor',
    icon: Icons.format_italic_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.insertItalic');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.insertCode',
    title: 'Code Block',
    description: 'Insert code block',
    category: 'Editor',
    icon: Icons.code_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.insertCode');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.insertImage',
    title: 'Insert Image',
    description: 'Insert image from file',
    category: 'Editor',
    icon: Icons.image_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.insertImage');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'editor.insertTable',
    title: 'Insert Table',
    description: 'Insert markdown table',
    category: 'Editor',
    icon: Icons.table_chart_rounded,
    handler: (args) async {
      debugPrint('Execute: editor.insertTable');
    },
  ));

  // View Commands
  commandRegistry.registerCommand(Command(
    id: 'view.toggleSidebar',
    title: 'Toggle Sidebar',
    description: 'Show or hide sidebar',
    category: 'View',
    icon: Icons.view_sidebar_rounded,
    handler: (args) async {
      debugPrint('Execute: view.toggleSidebar');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'view.togglePreview',
    title: 'Toggle Preview',
    description: 'Show or hide preview panel',
    category: 'View',
    icon: Icons.preview_rounded,
    handler: (args) async {
      debugPrint('Execute: view.togglePreview');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'view.zoomIn',
    title: 'Zoom In',
    description: 'Increase font size',
    category: 'View',
    icon: Icons.zoom_in_rounded,
    handler: (args) async {
      debugPrint('Execute: view.zoomIn');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'view.zoomOut',
    title: 'Zoom Out',
    description: 'Decrease font size',
    category: 'View',
    icon: Icons.zoom_out_rounded,
    handler: (args) async {
      debugPrint('Execute: view.zoomOut');
    },
  ));

  // Theme Commands
  commandRegistry.registerCommand(Command(
    id: 'theme.toggle',
    title: 'Toggle Theme',
    description: 'Switch between light and dark theme',
    category: 'Theme',
    icon: Icons.dark_mode_rounded,
    handler: (args) async {
      debugPrint('Execute: theme.toggle');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'theme.light',
    title: 'Light Theme',
    description: 'Switch to light theme',
    category: 'Theme',
    icon: Icons.light_mode_rounded,
    handler: (args) async {
      debugPrint('Execute: theme.light');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'theme.dark',
    title: 'Dark Theme',
    description: 'Switch to dark theme',
    category: 'Theme',
    icon: Icons.dark_mode_rounded,
    handler: (args) async {
      debugPrint('Execute: theme.dark');
    },
  ));

  // File Commands
  commandRegistry.registerCommand(Command(
    id: 'file.new',
    title: 'New File',
    description: 'Create new file',
    category: 'File',
    icon: Icons.note_add_rounded,
    handler: (args) async {
      debugPrint('Execute: file.new');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'file.open',
    title: 'Open File',
    description: 'Open existing file',
    category: 'File',
    icon: Icons.folder_open_rounded,
    handler: (args) async {
      debugPrint('Execute: file.open');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'file.openFolder',
    title: 'Open Folder',
    description: 'Open folder in explorer',
    category: 'File',
    icon: Icons.folder_rounded,
    handler: (args) async {
      debugPrint('Execute: file.openFolder');
    },
  ));

  commandRegistry.registerCommand(Command(
    id: 'file.close',
    title: 'Close File',
    description: 'Close current file',
    category: 'File',
    icon: Icons.close_rounded,
    handler: (args) async {
      debugPrint('Execute: file.close');
    },
  ));

  // Command Palette
  commandRegistry.registerCommand(Command(
    id: 'commandPalette.open',
    title: 'Command Palette',
    description: 'Open command palette',
    category: 'General',
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
    MenuItem(id: 'new', label: 'New File', commandId: 'file.new', icon: Icons.note_add_rounded),
    MenuItem(id: 'open', label: 'Open File', commandId: 'file.open', icon: Icons.folder_open_rounded),
    MenuItem(id: 'openFolder', label: 'Open Folder', commandId: 'file.openFolder', icon: Icons.folder_rounded),
    MenuItem.divider(),
    MenuItem(id: 'save', label: 'Save', commandId: 'editor.save', icon: Icons.save_rounded),
    MenuItem(id: 'saveAs', label: 'Save As', commandId: 'editor.saveAs', icon: Icons.save_as_rounded),
    MenuItem.divider(),
    MenuItem(id: 'close', label: 'Close', commandId: 'file.close', icon: Icons.close_rounded),
  ]);

  menuRegistry.registerMenu('edit', [
    MenuItem(id: 'undo', label: 'Undo', commandId: 'editor.undo', icon: Icons.undo_rounded),
    MenuItem(id: 'redo', label: 'Redo', commandId: 'editor.redo', icon: Icons.redo_rounded),
    MenuItem.divider(),
    MenuItem(id: 'bold', label: 'Bold', commandId: 'editor.insertBold', icon: Icons.format_bold_rounded),
    MenuItem(id: 'italic', label: 'Italic', commandId: 'editor.insertItalic', icon: Icons.format_italic_rounded),
    MenuItem(id: 'code', label: 'Code Block', commandId: 'editor.insertCode', icon: Icons.code_rounded),
    MenuItem.divider(),
    MenuItem(id: 'image', label: 'Insert Image', commandId: 'editor.insertImage', icon: Icons.image_rounded),
    MenuItem(id: 'table', label: 'Insert Table', commandId: 'editor.insertTable', icon: Icons.table_chart_rounded),
  ]);

  menuRegistry.registerMenu('view', [
    MenuItem(id: 'sidebar', label: 'Toggle Sidebar', commandId: 'view.toggleSidebar', icon: Icons.view_sidebar_rounded),
    MenuItem(id: 'preview', label: 'Toggle Preview', commandId: 'view.togglePreview', icon: Icons.preview_rounded),
    MenuItem.divider(),
    MenuItem(id: 'zoomIn', label: 'Zoom In', commandId: 'view.zoomIn', icon: Icons.zoom_in_rounded),
    MenuItem(id: 'zoomOut', label: 'Zoom Out', commandId: 'view.zoomOut', icon: Icons.zoom_out_rounded),
    MenuItem.divider(),
    MenuItem(id: 'theme', label: 'Toggle Theme', commandId: 'theme.toggle', icon: Icons.dark_mode_rounded),
  ]);

  menuRegistry.registerMenu('help', [
    MenuItem(id: 'commandPalette', label: 'Command Palette', commandId: 'commandPalette.open', icon: Icons.search_rounded),
  ]);
}

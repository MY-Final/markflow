class AppShortcutRegistry {
  static final AppShortcutRegistry _instance = AppShortcutRegistry._();
  factory AppShortcutRegistry() => _instance;
  AppShortcutRegistry._();

  final Map<String, String> _shortcuts = {};
  final Map<String, String> _commandShortcuts = {};

  void registerShortcut(String keyCombo, String commandId) {
    _shortcuts[keyCombo] = commandId;
    _commandShortcuts[commandId] = keyCombo;
  }

  void unregisterShortcut(String keyCombo) {
    final commandId = _shortcuts.remove(keyCombo);
    if (commandId != null) {
      _commandShortcuts.remove(commandId);
    }
  }

  void unregisterCommand(String commandId) {
    final keyCombo = _commandShortcuts.remove(commandId);
    if (keyCombo != null) {
      _shortcuts.remove(keyCombo);
    }
  }

  void updateShortcut(String commandId, String newKeyCombo) {
    final oldKeyCombo = _commandShortcuts.remove(commandId);
    if (oldKeyCombo != null) {
      _shortcuts.remove(oldKeyCombo);
    }
    _shortcuts[newKeyCombo] = commandId;
    _commandShortcuts[commandId] = newKeyCombo;
  }

  String? getCommandId(String keyCombo) {
    return _shortcuts[keyCombo];
  }

  String? getShortcut(String commandId) {
    return _commandShortcuts[commandId];
  }

  Map<String, String> listShortcuts() {
    return Map.from(_commandShortcuts);
  }

  String buildKeyCombo({
    bool ctrl = false,
    bool shift = false,
    bool alt = false,
    required String key,
  }) {
    final parts = <String>[];
    if (ctrl) parts.add('ctrl');
    if (shift) parts.add('shift');
    if (alt) parts.add('alt');
    parts.add(key.toLowerCase());
    return parts.join('+');
  }

  String formatShortcut(String keyCombo) {
    return keyCombo
        .split('+')
        .map((part) {
          if (part == 'ctrl') return 'Ctrl';
          if (part == 'shift') return 'Shift';
          if (part == 'alt') return 'Alt';
          return part.toUpperCase();
        })
        .join('+');
  }
}

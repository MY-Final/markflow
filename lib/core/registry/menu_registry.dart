import 'package:flutter/material.dart';

class MenuItem {
  final String id;
  final String label;
  final String? commandId;
  final IconData? icon;
  final List<MenuItem>? children;
  final bool isDivider;

  const MenuItem({
    required this.id,
    required this.label,
    this.commandId,
    this.icon,
    this.children,
    this.isDivider = false,
  });

  static MenuItem divider() {
    return const MenuItem(id: 'divider', label: '', isDivider: true);
  }
}

class MenuRegistry {
  static final MenuRegistry _instance = MenuRegistry._();
  factory MenuRegistry() => _instance;
  MenuRegistry._();

  final Map<String, List<MenuItem>> _menus = {};

  void registerMenu(String menuId, List<MenuItem> items) {
    _menus[menuId] = items;
  }

  void unregisterMenu(String menuId) {
    _menus.remove(menuId);
  }

  List<MenuItem>? getMenu(String menuId) {
    return _menus[menuId];
  }

  Map<String, List<MenuItem>> getAllMenus() {
    return Map.from(_menus);
  }

  MenuItem? findMenuItem(String menuId, String itemId) {
    final items = _menus[menuId];
    if (items == null) return null;
    return _findItem(items, itemId);
  }

  MenuItem? _findItem(List<MenuItem> items, String itemId) {
    for (final item in items) {
      if (item.id == itemId) return item;
      if (item.children != null) {
        final found = _findItem(item.children!, itemId);
        if (found != null) return found;
      }
    }
    return null;
  }

  List<MenuItem> searchMenus(String query) {
    final results = <MenuItem>[];
    final lowerQuery = query.toLowerCase();

    for (final items in _menus.values) {
      _searchItems(items, lowerQuery, results);
    }

    return results;
  }

  void _searchItems(List<MenuItem> items, String query, List<MenuItem> results) {
    for (final item in items) {
      if (item.label.toLowerCase().contains(query)) {
        results.add(item);
      }
      if (item.children != null) {
        _searchItems(item.children!, query, results);
      }
    }
  }
}

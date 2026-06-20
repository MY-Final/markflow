import 'package:flutter/material.dart';

typedef CommandHandler = Future<void> Function(Map<String, dynamic>? args);

class Command {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? shortcut;
  final CommandHandler handler;
  final IconData? icon;

  const Command({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.shortcut,
    required this.handler,
    this.icon,
  });
}

class CommandRegistry {
  static final CommandRegistry _instance = CommandRegistry._();
  factory CommandRegistry() => _instance;
  CommandRegistry._();

  final Map<String, Command> _commands = {};

  void registerCommand(Command command) {
    _commands[command.id] = command;
  }

  void unregisterCommand(String commandId) {
    _commands.remove(commandId);
  }

  Future<void> executeCommand(String commandId, {Map<String, dynamic>? args}) async {
    final command = _commands[commandId];
    if (command == null) {
      debugPrint('Command not found: $commandId');
      return;
    }
    await command.handler(args);
  }

  Command? getCommand(String commandId) {
    return _commands[commandId];
  }

  List<Command> listCommands() {
    return _commands.values.toList();
  }

  List<Command> getCommandsByCategory(String category) {
    return _commands.values
        .where((cmd) => cmd.category == category)
        .toList();
  }

  List<String> getCategories() {
    final categories = _commands.values.map((cmd) => cmd.category).toSet();
    return categories.toList()..sort();
  }
}

import 'package:flutter/material.dart';
import 'package:markflow/app/app.dart';
import 'package:markflow/core/registry/core_commands.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register core commands, menus, and shortcuts
  registerCoreCommands();
  
  runApp(const MarkFlowApp());
}

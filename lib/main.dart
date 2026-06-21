import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:markflow/app/app.dart';
import 'package:markflow/core/registry/core_commands.dart';
import 'package:markflow/features/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final windowManager = WindowManager.instance;
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(900, 620),
      titleBarStyle: TitleBarStyle.hidden,
    );
    await windowManager.waitUntilReadyToShow(windowOptions);
    await windowManager.show();
    await windowManager.focus();
  }

  await SettingsService().initialize();

  registerCoreCommands();

  runApp(const MarkFlowApp());
}

import 'package:flutter/material.dart';
import 'package:markflow/app/app.dart';
import 'package:markflow/core/registry/core_commands.dart';
import 'package:markflow/features/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化设置服务
  await SettingsService().initialize();
  
  // 注册核心命令
  registerCoreCommands();
  
  runApp(const MarkFlowApp());
}

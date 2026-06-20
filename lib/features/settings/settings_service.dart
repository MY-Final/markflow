import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SettingsModel {
  // Editor settings
  final double editorFontSize;
  final double editorLineHeight;
  final bool editorWordWrap;
  final bool editorShowLineNumbers;

  // Preview settings
  final double previewFontSize;
  final bool previewSyncScroll;

  // Export settings
  final String defaultExportFormat;
  final bool exportIncludeToc;

  const SettingsModel({
    this.editorFontSize = 15,
    this.editorLineHeight = 1.9,
    this.editorWordWrap = true,
    this.editorShowLineNumbers = false,
    this.previewFontSize = 15,
    this.previewSyncScroll = true,
    this.defaultExportFormat = 'PDF',
    this.exportIncludeToc = false,
  });

  SettingsModel copyWith({
    double? editorFontSize,
    double? editorLineHeight,
    bool? editorWordWrap,
    bool? editorShowLineNumbers,
    double? previewFontSize,
    bool? previewSyncScroll,
    String? defaultExportFormat,
    bool? exportIncludeToc,
  }) {
    return SettingsModel(
      editorFontSize: editorFontSize ?? this.editorFontSize,
      editorLineHeight: editorLineHeight ?? this.editorLineHeight,
      editorWordWrap: editorWordWrap ?? this.editorWordWrap,
      editorShowLineNumbers: editorShowLineNumbers ?? this.editorShowLineNumbers,
      previewFontSize: previewFontSize ?? this.previewFontSize,
      previewSyncScroll: previewSyncScroll ?? this.previewSyncScroll,
      defaultExportFormat: defaultExportFormat ?? this.defaultExportFormat,
      exportIncludeToc: exportIncludeToc ?? this.exportIncludeToc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'editor': {
        'fontSize': editorFontSize,
        'lineHeight': editorLineHeight,
        'wordWrap': editorWordWrap,
        'showLineNumbers': editorShowLineNumbers,
      },
      'preview': {
        'fontSize': previewFontSize,
        'syncScroll': previewSyncScroll,
      },
      'export': {
        'defaultFormat': defaultExportFormat,
        'includeToc': exportIncludeToc,
      },
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    final editor = json['editor'] as Map<String, dynamic>? ?? {};
    final preview = json['preview'] as Map<String, dynamic>? ?? {};
    final export = json['export'] as Map<String, dynamic>? ?? {};

    return SettingsModel(
      editorFontSize: (editor['fontSize'] as num?)?.toDouble() ?? 15,
      editorLineHeight: (editor['lineHeight'] as num?)?.toDouble() ?? 1.9,
      editorWordWrap: editor['wordWrap'] as bool? ?? true,
      editorShowLineNumbers: editor['showLineNumbers'] as bool? ?? false,
      previewFontSize: (preview['fontSize'] as num?)?.toDouble() ?? 15,
      previewSyncScroll: preview['syncScroll'] as bool? ?? true,
      defaultExportFormat: export['defaultFormat'] as String? ?? 'PDF',
      exportIncludeToc: export['includeToc'] as bool? ?? false,
    );
  }

  static const SettingsModel defaultSettings = SettingsModel();
}

class SettingsService {
  static final SettingsService _instance = SettingsService._();
  factory SettingsService() => _instance;
  SettingsService._();

  SettingsModel _settings = SettingsModel.defaultSettings;
  File? _settingsFile;

  SettingsModel get settings => _settings;

  Future<void> initialize() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final markFlowDir = Directory('${appDir.path}${Platform.pathSeparator}MarkFlow');
      
      if (!await markFlowDir.exists()) {
        await markFlowDir.create(recursive: true);
      }

      _settingsFile = File('${markFlowDir.path}${Platform.pathSeparator}settings.json');

      if (await _settingsFile!.exists()) {
        final content = await _settingsFile!.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        _settings = SettingsModel.fromJson(json);
        debugPrint('Settings loaded from: ${_settingsFile!.path}');
      } else {
        await _saveSettings();
        debugPrint('Settings file created at: ${_settingsFile!.path}');
      }
    } catch (e) {
      debugPrint('Error initializing settings: $e');
      _settings = SettingsModel.defaultSettings;
    }
  }

  Future<void> _saveSettings() async {
    try {
      if (_settingsFile == null) return;
      final json = _settings.toJson();
      final content = const JsonEncoder.withIndent('  ').convert(json);
      await _settingsFile!.writeAsString(content);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> updateSettings(SettingsModel newSettings) async {
    _settings = newSettings;
    await _saveSettings();
  }

  Future<void> updateEditorFontSize(double value) async {
    _settings = _settings.copyWith(editorFontSize: value);
    await _saveSettings();
  }

  Future<void> updateEditorLineHeight(double value) async {
    _settings = _settings.copyWith(editorLineHeight: value);
    await _saveSettings();
  }

  Future<void> updateEditorWordWrap(bool value) async {
    _settings = _settings.copyWith(editorWordWrap: value);
    await _saveSettings();
  }

  Future<void> updateEditorShowLineNumbers(bool value) async {
    _settings = _settings.copyWith(editorShowLineNumbers: value);
    await _saveSettings();
  }

  Future<void> updatePreviewFontSize(double value) async {
    _settings = _settings.copyWith(previewFontSize: value);
    await _saveSettings();
  }

  Future<void> updatePreviewSyncScroll(bool value) async {
    _settings = _settings.copyWith(previewSyncScroll: value);
    await _saveSettings();
  }

  Future<void> updateDefaultExportFormat(String value) async {
    _settings = _settings.copyWith(defaultExportFormat: value);
    await _saveSettings();
  }

  Future<void> updateExportIncludeToc(bool value) async {
    _settings = _settings.copyWith(exportIncludeToc: value);
    await _saveSettings();
  }

  Future<void> resetToDefault() async {
    _settings = SettingsModel.defaultSettings;
    await _saveSettings();
  }

  String getSettingsPath() {
    return _settingsFile?.path ?? 'Not initialized';
  }
}

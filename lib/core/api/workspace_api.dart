import 'dart:io';
import 'package:markflow/core/event/event_bus.dart';

class FileInfo {
  final String path;
  final String name;
  final bool isOpen;
  final bool isModified;

  const FileInfo({
    required this.path,
    required this.name,
    this.isOpen = false,
    this.isModified = false,
  });

  FileInfo copyWith({
    String? path,
    String? name,
    bool? isOpen,
    bool? isModified,
  }) {
    return FileInfo(
      path: path ?? this.path,
      name: name ?? this.name,
      isOpen: isOpen ?? this.isOpen,
      isModified: isModified ?? this.isModified,
    );
  }
}

class WorkspaceAPI {
  static final WorkspaceAPI _instance = WorkspaceAPI._();
  factory WorkspaceAPI() => _instance;
  WorkspaceAPI._();

  final EventBus _eventBus = EventBus();
  String _rootPath = '';
  final List<FileInfo> _openFiles = [];
  int _activeFileIndex = -1;

  String get rootPath => _rootPath;
  List<FileInfo> get openFiles => List.unmodifiable(_openFiles);
  FileInfo? get activeFile =>
      _activeFileIndex >= 0 && _activeFileIndex < _openFiles.length
          ? _openFiles[_activeFileIndex]
          : null;

  void openFolder(String path) {
    _rootPath = path;
  }

  Future<void> openFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return;

    final name = path.split(Platform.pathSeparator).last;
    final existingIndex = _openFiles.indexWhere((f) => f.path == path);

    if (existingIndex >= 0) {
      _activeFileIndex = existingIndex;
    } else {
      _openFiles.add(FileInfo(
        path: path,
        name: name,
        isOpen: true,
      ));
      _activeFileIndex = _openFiles.length - 1;
    }

    _eventBus.emit(EventType.fileOpened, data: path);
  }

  Future<void> saveFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);

    final index = _openFiles.indexWhere((f) => f.path == path);
    if (index >= 0) {
      _openFiles[index] = _openFiles[index].copyWith(isModified: false);
    }

    _eventBus.emit(EventType.fileSaved, data: path);
  }

  Future<String> saveAs(String newPath, String content) async {
    await saveFile(newPath, content);
    return newPath;
  }

  void closeFile(String path) {
    final index = _openFiles.indexWhere((f) => f.path == path);
    if (index >= 0) {
      _openFiles.removeAt(index);
      if (_activeFileIndex >= _openFiles.length) {
        _activeFileIndex = _openFiles.length - 1;
      }
      _eventBus.emit(EventType.fileClosed, data: path);
    }
  }

  Future<List<String>> listFiles(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) return [];

    final files = <String>[];
    await for (final entity in directory.list()) {
      if (entity is File) {
        files.add(entity.path);
      }
    }
    return files;
  }

  Future<List<String>> listDirectories(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) return [];

    final directories = <String>[];
    await for (final entity in directory.list()) {
      if (entity is Directory) {
        final name = entity.path.split(Platform.pathSeparator).last;
        if (!name.startsWith('.')) {
          directories.add(entity.path);
        }
      }
    }
    return directories;
  }

  void setActiveFile(String path) {
    final index = _openFiles.indexWhere((f) => f.path == path);
    if (index >= 0) {
      _activeFileIndex = index;
    }
  }

  void markFileModified(String path, bool isModified) {
    final index = _openFiles.indexWhere((f) => f.path == path);
    if (index >= 0) {
      _openFiles[index] = _openFiles[index].copyWith(isModified: isModified);
    }
  }
}

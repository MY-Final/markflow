import 'package:flutter/material.dart';
import 'package:markflow/core/event/event_bus.dart';

class EditorAPI {
  static final EditorAPI _instance = EditorAPI._();
  factory EditorAPI() => _instance;
  EditorAPI._();

  String _document = '';
  TextSelection _selection = TextSelection.collapsed(offset: 0);
  String _currentFile = '';
  bool _isModified = false;

  final EventBus _eventBus = EventBus();

  String getDocument() => _document;

  void setDocument(String content) {
    _document = content;
    _eventBus.emit(EventType.documentChanged, data: content);
  }

  void insertText(String text) {
    final before = _document.substring(0, _selection.start);
    final after = _document.substring(_selection.end);
    _document = before + text + after;
    _selection = TextSelection.collapsed(
      offset: _selection.start + text.length,
    );
    _isModified = true;
    _eventBus.emit(EventType.documentChanged, data: _document);
  }

  void replaceSelection(String text) {
    final before = _document.substring(0, _selection.start);
    final after = _document.substring(_selection.end);
    _document = before + text + after;
    _selection = TextSelection.collapsed(
      offset: _selection.start + text.length,
    );
    _isModified = true;
    _eventBus.emit(EventType.documentChanged, data: _document);
  }

  TextSelection getSelection() => _selection;

  void setSelection(TextSelection selection) {
    _selection = selection;
    _eventBus.emit(EventType.selectionChanged, data: selection);
  }

  String getCurrentFile() => _currentFile;

  void setCurrentFile(String path) {
    _currentFile = path;
    _eventBus.emit(EventType.fileOpened, data: path);
  }

  bool get isModified => _isModified;

  void markSaved() {
    _isModified = false;
    _eventBus.emit(EventType.fileSaved, data: _currentFile);
  }

  void scrollTo(int line) {
    // 滚动到指定行
  }

  void focus() {
    // 聚焦编辑器
  }

  int getLineCount() {
    return _document.split('\n').length;
  }

  int getCurrentLine() {
    final textBefore = _document.substring(0, _selection.start);
    return textBefore.split('\n').length;
  }

  int getCurrentColumn() {
    final textBefore = _document.substring(0, _selection.start);
    final lastNewline = textBefore.lastIndexOf('\n');
    return textBefore.length - lastNewline;
  }
}

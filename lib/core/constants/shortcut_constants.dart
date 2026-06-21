/// MarkFlow 快捷键常量定义
/// 集中管理所有快捷键映射，便于维护和修改
library;

class ShortcutConstants {
  // ==================== 文件操作 ====================
  static const String fileNew = 'ctrl+n';
  static const String fileOpen = 'ctrl+o';
  static const String fileSave = 'ctrl+s';
  static const String fileSaveAs = 'ctrl+shift+s';
  static const String fileClose = 'ctrl+w';
  static const String fileExportPdf = 'ctrl+shift+e'; // 调整：避免与命令面板冲突
  static const String fileQuickOpen = 'ctrl+p';

  // ==================== 编辑操作 ====================
  static const String undo = 'ctrl+z';
  static const String redo = 'ctrl+shift+z';
  static const String redoAlt = 'ctrl+y';
  static const String find = 'ctrl+f';
  static const String replace = 'ctrl+h';
  static const String selectAll = 'ctrl+a';
  static const String copyAsPlainText = 'ctrl+shift+c';
  static const String pasteAsPlainText = 'ctrl+shift+v';
  static const String copyAsMarkdown = 'ctrl+shift+g';

  // ==================== 基础格式化 ====================
  static const String bold = 'ctrl+b';
  static const String italic = 'ctrl+i';
  static const String strikethrough = 'alt+shift+5';
  static const String inlineCode = 'ctrl+`';
  static const String underline = 'ctrl+u';
  static const String link = 'ctrl+k';
  static const String image = 'ctrl+shift+i';

  // ==================== 标题层级 ====================
  static const String heading1 = 'ctrl+1';
  static const String heading2 = 'ctrl+2';
  static const String heading3 = 'ctrl+3';
  static const String heading4 = 'ctrl+4';
  static const String heading5 = 'ctrl+5';
  static const String heading6 = 'ctrl+6';
  static const String increaseHeadingLevel = 'ctrl+shift+=';
  static const String decreaseHeadingLevel = 'ctrl+shift+-';

  // ==================== 列表与结构 ====================
  static const String unorderedList = 'ctrl+shift+]';
  static const String orderedList = 'ctrl+shift+[';
  static const String taskList = 'ctrl+shift+x';
  static const String indent = 'tab';
  static const String outdent = 'shift+tab';
  static const String quote = 'ctrl+shift+q';

  // ==================== 代码与公式 ====================
  static const String codeBlock = 'ctrl+shift+k';
  static const String inlineMath = 'ctrl+shift+m';
  static const String blockMath = 'ctrl+shift+m'; // 与行内相同，通过上下文区分

  // ==================== 视图与模式 ====================
  static const String sourceMode = 'ctrl+/';
  static const String focusMode = 'f8';
  static const String typewriterMode = 'f9';
  static const String outlinePanel = 'ctrl+shift+1';
  static const String fileTreePanel = 'ctrl+shift+2';
  static const String fullscreen = 'f11';
  static const String zoomIn = 'ctrl+=';
  static const String zoomOut = 'ctrl+-';

  // ==================== AI 功能 ====================
  static const String aiComplete = 'ctrl+enter';
  static const String aiRewrite = 'ctrl+shift+enter';
  static const String aiTranslate = 'ctrl+shift+t';
  static const String aiSummarize = 'ctrl+shift+j';

  // ==================== 插入操作 ====================
  static const String insertDivider = 'ctrl+shift+d'; // 调整：避免与标题级别冲突
  static const String insertTable = 'ctrl+shift+b'; // 调整：避免与AI翻译冲突
  static const String switchTab = 'ctrl+tab';

  // ==================== 命令面板 ====================
  static const String commandPalette = 'ctrl+shift+p';
}

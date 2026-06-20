import 'dart:io';
import 'package:path/path.dart' as path;

/// 文件内容分类，用于决定渲染策略
enum FileCategory {
  /// Markdown 文件：.md, .markdown, .mdown
  markdown,

  /// 结构化数据：.json, .yaml, .yml, .toml, .xml, .csv
  data,

  /// 日志/锁文件：.log, .lock, .sql
  log,

  /// 其他纯文本：.txt 以及无扩展名等
  text,

  /// 二进制文件（图片、压缩包等，不渲染）
  binary,
}

class FileUtils {
  static const _dataExtensions = {'json', 'yaml', 'yml', 'toml', 'xml', 'csv'};
  static const _logExtensions = {'log', 'lock', 'sql'};
  static const _binaryExtensions = {
    'png', 'jpg', 'jpeg', 'gif', 'bmp', 'ico', 'webp', 'svg',
    'mp3', 'mp4', 'wav', 'avi', 'mov', 'mkv', 'flv',
    'zip', 'rar', '7z', 'tar', 'gz', 'bz2',
    'exe', 'dll', 'so', 'dylib', 'bin',
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
  };

  /// 按扩展名对文件进行分类
  static FileCategory classifyFile(String filePath) {
    final ext = getExtension(filePath).toLowerCase().replaceFirst('.', '');
    if (ext.isEmpty) return FileCategory.text;
    if (['md', 'markdown', 'mdown'].contains(ext)) return FileCategory.markdown;
    if (_dataExtensions.contains(ext)) return FileCategory.data;
    if (_logExtensions.contains(ext)) return FileCategory.log;
    if (_binaryExtensions.contains(ext)) return FileCategory.binary;
    return FileCategory.text;
  }

  /// 该分类是否需要 Markdown 预览渲染
  static bool shouldRenderMarkdown(FileCategory category) {
    return category == FileCategory.markdown;
  }

  /// 该分类的文件是否支持编辑（二进制不支持）
  static bool isEditable(FileCategory category) {
    return category != FileCategory.binary;
  }

  /// 判断文件是否为"大文件"
  static bool isLargeFile(int bytes, {int threshold = 1024 * 1024}) {
    return bytes > threshold;
  }

  /// 读取文件内容
  static Future<String> readFile(String filePath) async {
    final file = File(filePath);
    return await file.readAsString();
  }

  /// 写入文件内容
  static Future<void> writeFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }

  /// 检查文件是否存在
  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  /// 获取文件扩展名
  static String getExtension(String filePath) {
    return path.extension(filePath);
  }

  /// 获取文件名（不含扩展名）
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// 获取文件名（含扩展名）
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// 获取目录路径
  static String getDirectoryPath(String filePath) {
    return path.dirname(filePath);
  }

  /// 判断是否为 Markdown 文件
  static bool isMarkdownFile(String filePath) {
    return classifyFile(filePath) == FileCategory.markdown;
  }

  /// 获取文件大小（字节）
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

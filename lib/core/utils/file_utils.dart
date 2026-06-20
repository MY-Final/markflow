import 'dart:io';
import 'package:path/path.dart' as path;

class FileUtils {
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
    final ext = getExtension(filePath).toLowerCase();
    return ext == '.md' || ext == '.markdown' || ext == '.mdown';
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

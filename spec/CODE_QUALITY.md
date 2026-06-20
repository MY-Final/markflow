# MarkFlow - 代码质量规范

## 核心原则

```
可读性 > 可维护性 > 性能 > 代码量
```

---

## 命名规范

### 文件命名
```
✅ 小写 + 下划线：markdown_editor.dart、file_tree.dart
❌ 大驼峰：MarkdownEditor.dart
❌ 连字符：markdown-editor.dart
```

### 类命名
```dart
✅ 大驼峰：MarkdownEditor、FileTreeNode
❌ 小驼峰：markdownEditor、fileTreeNode
```

### 变量/函数命名
```dart
✅ 小驼峰：currentFile、saveDocument()
❌ 大驼峰：CurrentFile、SaveDocument()
```

### 常量命名
```dart
✅ 小写 + 下划线：maxFileSize、defaultTheme
✅ 大写下划线（全局）：API_KEY、BASE_URL
```

### 私有成员
```dart
✅ 下划线前缀：_controller、_loadFile()
```

---

## 代码结构

### 文件顺序
```dart
// 1. import（按组排列）
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/file_node.dart';

// 2. 常量
const double _kToolbarHeight = 48.0;

// 3. 类定义
class EditorToolbar extends StatelessWidget {
  // 4. 构造函数
  const EditorToolbar({super.key});

  // 5. 成员变量
  final String title;

  // 6. 方法
  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

### Import 分组
```dart
// 1. Dart 内置库
import 'dart:async';
import 'dart:io';

// 2. Flutter 框架
import 'package:flutter/material.dart';

// 3. 第三方包
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

// 4. 项目内部
import '../models/file_node.dart';
import '../services/file_service.dart';
```

---

## 函数规范

### 单一职责
```dart
// ✅ 一个函数只做一件事
void saveFile(String content) { ... }
void updateStatusBar(String status) { ... }

// ❌ 一个函数做多件事
void saveAndUpdateStatus(String content, String status) { ... }
```

### 函数长度
```
建议：不超过 30 行
超过时考虑拆分子函数
```

### 参数规范
```dart
// ✅ 使用命名参数（参数 > 2 个时）
void openFile({
  required String path,
  Encoding encoding = utf8,
  bool readOnly = false,
})

// ✅ 位置参数（参数 <= 2 个）
void writeFile(String path, String content)
```

---

## 类规范

### 类长度
```
建议：不超过 300 行
超过时考虑拆分职责
```

### 组件拆分
```dart
// ✅ 拆分为小组件
class EditorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EditorAppBar(),
      body: EditorBody(),
      statusBar: EditorStatusBar(),
    );
  }
}

// ❌ 单文件过长
class EditorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 50 行 AppBar 代码...
      ),
      body: Column(
        // 100 行 Body 代码...
      ),
    );
  }
}
```

---

## 注释规范

### 文件头注释
```dart
/// MarkFlow - Markdown 编辑器
///
/// 负责 Markdown 文件的编辑和预览功能
library editor;

import 'package:flutter/material.dart';
```

### 类注释
```dart
/// Markdown 编辑器组件
///
/// 提供所见即所得的 Markdown 编辑功能，
/// 支持标题、列表、代码块等语法。
class MarkdownEditor extends StatefulWidget {
```

### 方法注释
```dart
/// 保存当前文档到文件
///
/// [path] 保存路径，为空时使用当前文件路径
/// 返回是否保存成功
Future<bool> saveDocument({String? path}) async {
```

### 行内注释
```dart
// 临时方案，后续需要重构
final temp = calculate();
```

### 禁止行为
```dart
// ❌ 无意义注释
i++; // i 加 1

// ❌ 注释掉的代码（应删除或使用 Git 管理）
// oldFunction();
// deprecatedMethod();
```

---

## 错误处理

### 异常捕获
```dart
// ✅ 具体异常类型
try {
  await file.writeAsString(content);
} on FileSystemException catch (e) {
  logger.error('文件写入失败: ${e.message}');
  return false;
} catch (e, stack) {
  logger.error('未知错误', e, stack);
  rethrow;
}

// ❌ 捕获所有异常但不处理
try {
  await file.writeAsString(content);
} catch (e) {
  // 空 catch
}
```

### 空安全
```dart
// ✅ 使用可空类型
String? fileName;

// ✅ 空值检查
if (fileName != null) {
  print(fileName);
}

// ✅ 空值合并
final name = fileName ?? 'untitled';

// ❌ 强制解包
print(fileName!);
```

---

## 资源管理

### Controller 释放
```dart
// ✅ 在 dispose 中释放所有 Controller
class EditorPage extends StatefulWidget {
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final TextEditingController _textController;
  late final ScrollController _scrollController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
```

### Stream 订阅管理
```dart
// ✅ 在 dispose 中取消订阅
class FileWatcher extends StatefulWidget {
  @override
  State<FileWatcher> createState() => _FileWatcherState();
}

class _FileWatcherState extends State<FileWatcher> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = fileSystemWatcher.events.listen((event) {
      // 处理文件变化
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// ❌ 忘记取消订阅
class FileWatcher extends StatefulWidget {
  @override
  State<FileWatcher> createState() => _FileWatcherState();
}

class _FileWatcherState extends State<FileWatcher> {
  @override
  void initState() {
    super.initState();
    fileSystemWatcher.events.listen((event) {
      // 内存泄漏！订阅永远不会取消
    });
  }
}
```

### AnimationController 释放
```dart
// ✅ 正确释放 AnimationController
class FadeWidget extends StatefulWidget {
  @override
  State<FadeWidget> createState() => _FadeWidgetState();
}

class _FadeWidgetState extends State<FadeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Timer 释放
```dart
// ✅ 在 dispose 中取消 Timer
class AutoSave extends StatefulWidget {
  @override
  State<AutoSave> createState() => _AutoSaveState();
}

class _AutoSaveState extends State<AutoSave> {
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _autoSaveTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _save(),
    );
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
```

### 图片/文件资源释放
```dart
// ✅ 及时释放大文件资源
class ImagePreview extends StatefulWidget {
  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  File? _tempFile;

  Future<void> _loadImage(String path) async {
    _tempFile = File(path);
    final bytes = await _tempFile!.readAsBytes();
    // 处理图片
  }

  @override
  void dispose() {
    // 清理临时文件
    _tempFile?.delete();
    super.dispose();
  }
}

// ✅ 使用 try-finally 确保资源释放
Future<void> processFile(String path) async {
  final file = File(path);
  final RandomAccessFile handle = await file.open();
  try {
    // 处理文件
  } finally {
    await handle.close();
  }
}
```

### ValueNotifier 释放
```dart
// ✅ 释放 ValueNotifier
class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  final ValueNotifier<int> _counter = ValueNotifier(0);

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }
}
```

### 资源释放清单
```
必须释放的资源：
- [ ] TextEditingController
- [ ] ScrollController
- [ ] FocusNode
- [ ] AnimationController
- [ ] StreamSubscription
- [ ] Timer
- [ ] ValueNotifier
- [ ] ChangeNotifier
- [ ] RandomAccessFile
- [ ] Socket
- [ ] HttpClient
```

---

## 性能规范

### Widget 优化
```dart
// ✅ 使用 const 构造函数
const Text('Hello')
const Icon(Icons.add)

// ✅ 提取重复使用的 Widget
final titleStyle = Theme.of(context).textTheme.headlineMedium;

// ❌ 在 build 中创建新对象
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () {}, // 每次 build 都创建新闭包
  );
}
```

### 列表优化
```dart
// ✅ 使用 ListView.builder
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// ❌ 直接构建所有子项
ListView(
  children: items.map((e) => ItemWidget(e)).toList(),
)
```

### 状态管理
```dart
// ✅ 最小化 setState 范围
void _increment() {
  setState(() {
    _counter++;
  });
}

// ❌ 过大的 setState 范围
void _refresh() {
  setState(() {
    _counter++;
    _title = 'new';
    _color = Colors.red;
    // ... 大量更新
  });
}
```

---

## 代码格式

### 格式化工具
```bash
# 自动格式化
dart format .

# 检查格式
dart format --set-exit-if-changed .
```

### 行长度
```
建议：80 字符
最大：120 字符（超过必须换行）
```

### 括号规范
```dart
// ✅ 单行 if
if (condition) return;

// ✅ 多行 if 必须括号
if (condition) {
  doSomething();
  doAnotherThing();
}

// ❌ 无括号多行
if (condition)
  doSomething();
  doAnotherThing();
```

---

## 静态分析

### analysis_options.yaml
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - annotate_overrides
    - avoid_empty_else
    - avoid_print
    - avoid_unnecessary_containers
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_locals
    - sort_constructors_first
    - unnecessary_const
    - unnecessary_new
    - use_key_in_widget_constructors
```

### 检查命令
```bash
# 静态分析
flutter analyze

# 严格模式
flutter analyze --fatal-infos
```

---

## 代码审查清单

### 提交前自检

- [ ] 无 `print()` 调试语句
- [ ] 无未使用的 import
- [ ] 无未使用的变量
- [ ] 无硬编码字符串（使用常量）
- [ ] 无 TODO 遗留（或已创建 Issue）
- [ ] 命名清晰有意义
- [ ] 函数长度合理
- [ ] 错误处理完整
- [ ] 注释清晰必要

### Review 关注点

```
1. 逻辑正确性
2. 边界条件处理
3. 性能影响
4. 安全风险
5. 代码可读性
6. 测试覆盖
```

---

## 技术债务管理

### TODO 标记
```dart
// TODO(username): 描述待办事项
// FIXME: 描述需要修复的问题
// HACK: 临时方案说明
// REVIEW: 需要审查的代码
```

### 债务记录
```
- 在代码中标记 TODO/FIXME
- 定期清理技术债务
- 重大债务创建 Issue 跟踪
```

---

*文档版本：v0.1*
*最后更新：2026-06-20*

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarkFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const MarkdownDemoPage(),
    );
  }
}

class MarkdownDemoPage extends StatelessWidget {
  const MarkdownDemoPage({super.key});

  static const String _sampleMarkdown = '''
# MarkFlow - Markdown 预览演示

## 基础语法

这是一段普通文本。**这是粗体**，*这是斜体*，~~这是删除线~~。

你也可以使用 **_粗斜体_** 组合。

---

## 列表

### 无序列表
- 项目一
- 项目二
  - 子项目 A
  - 子项目 B
- 项目三

### 有序列表
1. 第一步
2. 第二步
3. 第三步

---

## 代码

行内代码：`print("Hello World")`

代码块：

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarkFlow',
      home: const HomePage(),
    );
  }
}
```

---

## 引用

> 这是一段引用文本。
> 
> 可以有多行。

> **嵌套引用**
>> 这是嵌套的引用内容。

---

## 链接

访问 [Flutter 官网](https://flutter.dev) 了解更多。

GitHub 仓库：[MarkFlow](https://github.com/MY-Final/markflow)

---

## 表格

| 功能 | 状态 | 说明 |
|------|------|------|
| Markdown 渲染 | ✅ 完成 | 支持完整语法 |
| 实时预览 | 🚧 开发中 | 编辑器 + 预览 |
| 导出 PDF | 📋 计划中 | 未来功能 |

---

## 待办列表

- [x] 项目初始化
- [x] Markdown 预览
- [ ] 编辑器功能
- [ ] 导出功能

---

> 💡 **提示**：这是一个 MarkFlow 的演示页面，展示了 Flutter 中 Markdown 的渲染效果。
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MarkFlow'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Markdown(
        data: _sampleMarkdown,
        padding: const EdgeInsets.all(16.0),
        onTapLink: (text, href, title) {
          if (href != null) {
            debugPrint('链接点击: $href');
          }
        },
      ),
    );
  }
}

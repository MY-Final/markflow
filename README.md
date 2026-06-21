# MarkFlow

一款基于 Flutter 的现代化桌面 Markdown 编辑器，支持实时预览、语法编辑、文件管理等功能。

## 特性

- **三种编辑模式**：编辑模式、分屏模式（编辑 + 预览）、预览模式
- **实时 Markdown 预览**：基于 `flutter_markdown_plus`，支持标题、粗体、斜体、代码块、表格、任务列表等
- **格式化工具栏**：一键插入 Markdown 语法（加粗、斜体、标题、列表、代码块、引用、链接等）
- **文件管理器**：侧边栏文件树，按扩展名分类图标
- **命令面板**：`Ctrl+Shift+P` 打开，快速执行命令
- **自定义窗口标题栏**：原生窗口控制（最小化、最大化、关闭），支持拖拽
- **深色/浅色主题**：跟随系统切换，暖色自然色调
- **可配置设置**：字体大小、行高、自动换行、行号等
- **快捷键系统**：全面支持 Markdown 编辑快捷键
- **拖拽打开**：支持拖拽文件/文件夹到窗口
- **跨平台**：支持 Windows、macOS、Linux

## 快捷键

| 类别 | 功能 | 快捷键 |
|------|------|--------|
| 文件 | 新建 | `Ctrl+N` |
| 文件 | 打开 | `Ctrl+O` |
| 文件 | 保存 | `Ctrl+S` |
| 文件 | 另存为 | `Ctrl+Shift+S` |
| 编辑 | 撤销 | `Ctrl+Z` |
| 编辑 | 重做 | `Ctrl+Shift+Z` / `Ctrl+Y` |
| 格式 | 加粗 | `Ctrl+B` |
| 格式 | 斜体 | `Ctrl+I` |
| 格式 | 删除线 | `Alt+Shift+5` |
| 格式 | 行内代码 | `` Ctrl+` `` |
| 格式 | 下划线 | `Ctrl+U` |
| 格式 | 链接 | `Ctrl+K` |
| 格式 | 图片 | `Ctrl+Shift+I` |
| 标题 | H1-H6 | `Ctrl+1` ~ `Ctrl+6` |
| 标题 | 升级 | `Ctrl+Shift+=` |
| 标题 | 降级 | `Ctrl+Shift+-` |
| 列表 | 无序列表 | `Ctrl+Shift+]` |
| 列表 | 有序列表 | `Ctrl+Shift+[` |
| 列表 | 任务列表 | `Ctrl+Shift+X` |
| 列表 | 引用 | `Ctrl+Shift+Q` |
| 代码 | 代码块 | `Ctrl+Shift+K` |
| 数学 | 行内公式 | `Ctrl+Shift+M` |
| 视图 | 命令面板 | `Ctrl+Shift+P` |
| 插入 | 分割线 | `Ctrl+Shift+D` |

## 开始使用

### 环境要求

- Flutter SDK >= 3.12.2
- Dart SDK >= 3.12.2

### 安装

```bash
# 克隆项目
git clone https://github.com/MY-Final/markflow.git
cd markflow

# 安装依赖
flutter pub get

# 运行
flutter run
```

### 构建

```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## 技术栈

- **框架**：Flutter + Dart
- **状态管理**：Riverpod
- **Markdown 渲染**：flutter_markdown_plus
- **字体**：Inter（界面）、JetBrains Mono（代码）
- **主题**：Material 3，自定义暖色调配色

## 许可证

MIT License

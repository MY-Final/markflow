# MarkFlow - 项目规范文档

## 项目概述

**项目名称：** MarkFlow（暂定）

**项目定位：** 桌面端 Markdown 编辑器

**核心卖点：**
- 本地 Markdown 文件编辑
- Typora 式沉浸写作体验
- 开源免费
- Flutter 跨平台支持

---

## 目标平台

| 平台 | 优先级 | 状态 |
|------|--------|------|
| Windows | P0 | 首期开发 |
| macOS | P1 | 后续支持 |
| Linux | P2 | 待定 |

---

## UI 布局设计

```
┌─────────────────────────────────────────────┐
│  File    Edit    View    Insert    Help      │  ← 菜单栏
├─────────────────────────────────────────────┤
│  [+]  [B]  [I]  [H1]  [H2]  [□]  [</>]     │  ← 工具栏
├────────────┬────────────────────────────────┤
│            │                                │
│   文件树    │       Markdown 编辑区           │
│   侧边栏    │       (所见即所得)              │
│            │                                │
│            │                                │
│            │                                │
├────────────┴────────────────────────────────┤
│  UTF-8  │  Markdown  │  Saved               │  ← 状态栏
└─────────────────────────────────────────────┘
```

### 布局区域说明

| 区域 | 描述 |
|------|------|
| **菜单栏** | File / Edit / View / Insert / Help 标准菜单 |
| **工具栏** | 常用操作快捷按钮：新建、加粗、斜体、标题、列表、代码块 |
| **文件树侧边栏** | 左侧可折叠，显示当前打开文件夹的目录结构 |
| **编辑区** | 核心区域，支持 Typora 式所见即所得 Markdown 编辑 |
| **状态栏** | 显示编码格式、语法类型、保存状态 |

---

## 功能模块

### P0 - 核心功能（首期）

#### 1. 文件管理
- [ ] 打开本地文件夹
- [ ] 文件树展示（支持嵌套目录）
- [ ] 新建文件/文件夹
- [ ] 重命名
- [ ] 删除（确认弹窗）
- [ ] 文件拖拽导入

#### 2. Markdown 编辑器
- [ ] 所见即所得编辑（Typora 风格）
- [ ] 标题（H1-H6）
- [ ] 粗体 / 斜体 / 删除线
- [ ] 有序列表 / 无序列表
- [ ] 任务列表（待办事项）
- [ ] 代码块（语法高亮）
- [ ] 引用块
- [ ] 链接 / 图片
- [ ] 表格
- [ ] 分割线
- [ ] LaTeX 数学公式（可选）

#### 3. 工具栏
- [ ] 新建文件
- [ ] 加粗 (B)
- [ ] 斜体 (I)
- [ ] 标题选择 (H1/H2)
- [ ] 列表切换
- [ ] 代码块插入

#### 4. 状态栏
- [ ] 文件编码显示（UTF-8）
- [ ] 语法类型显示（Markdown）
- [ ] 保存状态（Saved / Modified）

### P1 - 增强功能（二期）

- [ ] 多标签页编辑
- [ ] 查找与替换
- [ ] 撤销 / 重做
- [ ] 快捷键支持
- [ ] 主题切换（亮色/暗色）
- [ ] 字体大小调整
- [ ] 导出 PDF / HTML
- [ ] 拼写检查

### P2 - 高级功能（远期）

- [ ] Vim 模式
- [ ] 侧边栏预览（编辑/预览分屏）
- [ ] 自定义快捷键
- [ ] 插件系统
- [ ] 云同步

---

## 技术栈

| 类别 | 技术选型 |
|------|----------|
| 框架 | Flutter 3.x |
| 语言 | Dart |
| 状态管理 | Riverpod / Bloc（待定） |
| Markdown 解析 | flutter_markdown_plus / markdown |
| 文件操作 | dart:io |
| 语法高亮 | highlight.dart |
| 目录树 | file_picker + 自定义组件 |

---

## 快捷键设计

| 操作 | Windows | macOS |
|------|---------|-------|
| 新建文件 | Ctrl+N | Cmd+N |
| 打开文件夹 | Ctrl+O | Cmd+O |
| 保存 | Ctrl+S | Cmd+S |
| 另存为 | Ctrl+Shift+S | Cmd+Shift+S |
| 撤销 | Ctrl+Z | Cmd+Z |
| 重做 | Ctrl+Y | Cmd+Y |
| 加粗 | Ctrl+B | Cmd+B |
| 斜体 | Ctrl+I | Cmd+I |
| 查找 | Ctrl+F | Cmd+F |

---

## 项目结构（规划）

```
lib/
├── main.dart                    # 应用入口
├── app/
│   └── app.dart                 # MaterialApp 配置
├── core/
│   ├── constants/               # 常量定义
│   ├── theme/                   # 主题配置
│   └── utils/                   # 工具函数
├── features/
│   ├── editor/                  # 编辑器模块
│   │   ├── widgets/             # 编辑器组件
│   │   ├── providers/           # 状态管理
│   │   └── services/            # 编辑器服务
│   ├── file_explorer/           # 文件树模块
│   ├── menu_bar/                # 菜单栏模块
│   ├── toolbar/                 # 工具栏模块
│   └── status_bar/              # 状态栏模块
└── shared/
    ├── models/                  # 数据模型
    └── widgets/                 # 公共组件
```

---

## 版本规划

| 版本 | 目标 | 预计时间 |
|------|------|----------|
| v0.1.0 | 基础框架 + 文件树 + 纯文本编辑 | - |
| v0.2.0 | Markdown 基础渲染 | - |
| v0.3.0 | 所见即所得编辑 | - |
| v0.4.0 | 工具栏 + 状态栏 | - |
| v1.0.0 | Windows 正式版发布 | - |

---

## 可扩展架构 (V1)

### 核心原则

所有功能必须通过 Command 形式存在：

```
Menu → Command
Shortcut → Command
AI → Command
Plugin → Command
```

禁止直接调用：`Menu → Service` 或 `Shortcut → Editor`

---

### Command Registry

全局命令注册中心，所有业务能力以 Command 形式注册。

```dart
// 注册命令
CommandRegistry().registerCommand(Command(
  id: 'editor.save',
  title: 'Save',
  description: 'Save current file',
  category: 'Editor',
  handler: (args) async { /* ... */ },
));

// 执行命令
await CommandRegistry().executeCommand('editor.save');

// 查询命令
final cmd = CommandRegistry().getCommand('editor.save');
final allCmds = CommandRegistry().listCommands();
final editorCmds = CommandRegistry().getCommandsByCategory('Editor');
```

**内置命令列表：**

| 命令 ID | 说明 | 分类 |
|---------|------|------|
| `editor.save` | 保存文件 | Editor |
| `editor.saveAs` | 另存为 | Editor |
| `editor.undo` | 撤销 | Editor |
| `editor.redo` | 重做 | Editor |
| `editor.insertBold` | 插入粗体 | Editor |
| `editor.insertItalic` | 插入斜体 | Editor |
| `editor.insertCode` | 插入代码块 | Editor |
| `editor.insertImage` | 插入图片 | Editor |
| `editor.insertTable` | 插入表格 | Editor |
| `view.toggleSidebar` | 切换侧边栏 | View |
| `view.togglePreview` | 切换预览 | View |
| `view.zoomIn` | 放大 | View |
| `view.zoomOut` | 缩小 | View |
| `theme.toggle` | 切换主题 | Theme |
| `theme.light` | 亮色主题 | Theme |
| `theme.dark` | 暗色主题 | Theme |
| `file.new` | 新建文件 | File |
| `file.open` | 打开文件 | File |
| `file.openFolder` | 打开文件夹 | File |
| `file.close` | 关闭文件 | File |
| `commandPalette.open` | 打开命令面板 | General |

---

### Menu Registry

菜单不直接绑定逻辑，只绑定 Command ID。

```dart
MenuRegistry().registerMenu('file', [
  MenuItem(id: 'save', label: 'Save', commandId: 'editor.save'),
  MenuItem(id: 'saveAs', label: 'Save As', commandId: 'editor.saveAs'),
]);

// 点击菜单时执行
CommandRegistry().executeCommand(menuItem.commandId);
```

---

### Shortcut Registry

统一快捷键管理，快捷键映射到 Command ID。

```dart
// 注册快捷键
AppShortcutRegistry().registerShortcut('ctrl+s', 'editor.save');
AppShortcutRegistry().registerShortcut('ctrl+z', 'editor.undo');
AppShortcutRegistry().registerShortcut('ctrl+shift+p', 'commandPalette.open');

// 查询快捷键
final combo = AppShortcutRegistry().getShortcut('editor.save'); // 'ctrl+s'
final formatted = AppShortcutRegistry().formatShortcut(combo);  // 'Ctrl+S'
final cmdId = AppShortcutRegistry().getCommandId('ctrl+s');     // 'editor.save'
```

---

### Command Palette

参考 VSCode，快捷键 `Ctrl+Shift+P` 打开。

```dart
CommandPalette.show(context);
```

功能：
- 搜索所有已注册命令
- 键盘上下选择
- 回车执行
- 显示快捷键

---

### Event Bus

全局事件总线，用于模块间通信。

```dart
// 订阅事件
EventBus().subscribe(EventType.fileOpened, (event) {
  print('File opened: ${event.data}');
});

// 发布事件
EventBus().emit(EventType.fileSaved, data: filePath);

// 获取历史事件
final history = EventBus().getEventHistory();
```

**内置事件类型：**

| 事件 | 说明 | 数据 |
|------|------|------|
| `fileOpened` | 文件打开 | 文件路径 |
| `fileSaved` | 文件保存 | 文件路径 |
| `fileClosed` | 文件关闭 | 文件路径 |
| `documentChanged` | 文档变更 | 文档内容 |
| `selectionChanged` | 选区变更 | TextSelection |
| `themeChanged` | 主题变更 | 主题名称 |
| `commandExecuted` | 命令执行 | 命令 ID |
| `toolExecuted` | 工具执行 | 工具 ID |

---

### Editor API

对外暴露的编辑器操作接口，供 AI/Plugin 调用。

```dart
final editor = EditorAPI();

// 文档操作
String content = editor.getDocument();
editor.setDocument('# Hello');
editor.insertText('World');
editor.replaceSelection('**Bold**');

// 选区操作
TextSelection sel = editor.getSelection();
editor.setSelection(TextSelection.collapsed(offset: 10));

// 文件信息
String file = editor.getCurrentFile();
editor.setCurrentFile('/path/to/file.md');
bool modified = editor.isModified;
editor.markSaved();

// 光标信息
int line = editor.getCurrentLine();
int col = editor.getCurrentColumn();
int lines = editor.getLineCount();
```

**方法列表：**

| 方法 | 说明 | 参数 | 返回值 |
|------|------|------|--------|
| `getDocument()` | 获取文档内容 | - | `String` |
| `setDocument(content)` | 设置文档内容 | `String` | `void` |
| `insertText(text)` | 在光标处插入文本 | `String` | `void` |
| `replaceSelection(text)` | 替换选中文本 | `String` | `void` |
| `getSelection()` | 获取选区 | - | `TextSelection` |
| `setSelection(sel)` | 设置选区 | `TextSelection` | `void` |
| `getCurrentFile()` | 获取当前文件路径 | - | `String` |
| `setCurrentFile(path)` | 设置当前文件 | `String` | `void` |
| `isModified` | 是否已修改 | - | `bool` |
| `markSaved()` | 标记为已保存 | - | `void` |
| `getCurrentLine()` | 获取当前行号 | - | `int` |
| `getCurrentColumn()` | 获取当前列号 | - | `int` |
| `getLineCount()` | 获取总行数 | - | `int` |
| `scrollTo(line)` | 滚动到指定行 | `int` | `void` |
| `focus()` | 聚焦编辑器 | - | `void` |

---

### Workspace API

对外暴露的工作区操作接口。

```dart
final workspace = WorkspaceAPI();

// 文件夹操作
workspace.openFolder('/path/to/project');

// 文件操作
await workspace.openFile('/path/to/file.md');
await workspace.saveFile('/path/to/file.md', content);
workspace.closeFile('/path/to/file.md');

// 文件列表
List<String> files = await workspace.listFiles('/path/to/dir');
List<String> dirs = await workspace.listDirectories('/path/to/dir');

// 状态查询
FileInfo? active = workspace.activeFile;
List<FileInfo> openFiles = workspace.openFiles;
String root = workspace.rootPath;
```

**方法列表：**

| 方法 | 说明 | 参数 | 返回值 |
|------|------|------|--------|
| `openFolder(path)` | 打开文件夹 | `String` | `void` |
| `openFile(path)` | 打开文件 | `String` | `Future<void>` |
| `saveFile(path, content)` | 保存文件 | `String, String` | `Future<void>` |
| `saveAs(newPath, content)` | 另存为 | `String, String` | `Future<String>` |
| `closeFile(path)` | 关闭文件 | `String` | `void` |
| `listFiles(dir)` | 列出文件 | `String` | `Future<List<String>>` |
| `listDirectories(dir)` | 列出目录 | `String` | `Future<List<String>>` |
| `setActiveFile(path)` | 设置活动文件 | `String` | `void` |
| `markFileModified(path, modified)` | 标记修改状态 | `String, bool` | `void` |
| `rootPath` | 根目录路径 | - | `String` |
| `openFiles` | 打开的文件列表 | - | `List<FileInfo>` |
| `activeFile` | 当前活动文件 | - | `FileInfo?` |

---

### AI Agent 工作流 (V2)

AI 不允许直接访问 Editor，必须通过 Tool → Command → Editor：

```
AI Agent
    ↓
Tool Registry (V2)
    ↓
Command Registry
    ↓
Editor / Workspace
```

内置 Tool (V2 规划)：

| Tool | 说明 |
|------|------|
| `readDocument` | 读取当前文档 |
| `replaceSelection` | 替换选中文本 |
| `insertText` | 插入文本 |
| `getCurrentFile` | 获取当前文件 |
| `listWorkspaceFiles` | 列出工作区文件 |
| `createFile` | 创建文件 |
| `openFile` | 打开文件 |
| `saveFile` | 保存文件 |
| `searchWorkspace` | 搜索工作区 |

---

*文档版本：v0.2*
*最后更新：2026-06-20*

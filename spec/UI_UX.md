# MarkFlow - UI/UX 规范

## 设计原则

### 核心理念
```
简洁 · 专注 · 沉浸
```

### 设计目标
- **低干扰** - 界面元素不抢夺注意力
- **高效率** - 常用操作触手可及
- **一致性** - 统一的视觉语言
- **可访问性** - 支持键盘导航和屏幕阅读器

---

## 视觉规范

### 颜色系统

#### 主色调
```dart
// 主色 - 蓝色系
primary: Color(0xFF2196F3)        // 主色
primaryLight: Color(0xFF64B5F6)   // 浅色
primaryDark: Color(0xFF1976D2)    // 深色

// 强调色
accent: Color(0xFF00BCD4)         // 强调色
```

#### 中性色
```dart
// 背景色
background: Color(0xFFFFFFFF)     // 页面背景
surface: Color(0xFFF5F5F5)        // 卡片背景
surfaceVariant: Color(0xFFEEEEEE) // 次级表面

// 文字色
onBackground: Color(0xFF212121)   // 主文字
onSurface: Color(0xFF757575)      // 次文字
onSurfaceVariant: Color(0xFF9E9E9E) // 辅助文字
```

#### 语义色
```dart
success: Color(0xFF4CAF50)        // 成功
warning: Color(0xFFFF9800)        // 警告
error: Color(0xFFF44336)          // 错误
info: Color(0xFF2196F3)           // 信息
```

#### 暗色主题
```dart
// 暗色模式
backgroundDark: Color(0xFF121212)
surfaceDark: Color(0xFF1E1E1E)
onBackgroundDark: Color(0xFFE0E0E0)
```

---

### 主题模式

#### 支持模式
```
- 亮色模式 (Light)
- 暗色模式 (Dark)
- 跟随系统 (System) - 默认
```

#### 主题配置
```dart
// 主题模式枚举
enum ThemeMode {
  system,  // 跟随系统
  light,   // 亮色模式
  dark,    // 暗色模式
}

// MaterialApp 配置
MaterialApp(
  themeMode: themeMode,  // 当前主题模式
  theme: _buildLightTheme(),      // 亮色主题
  darkTheme: _buildDarkTheme(),   // 暗色主题
)
```

#### 跟随系统实现
```dart
// 检测系统主题
final brightness = MediaQuery.platformBrightnessOf(context);
final isDarkMode = brightness == Brightness.dark;

// 自动切换
themeMode: ThemeMode.system
```

#### 亮色主题定义
```dart
ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF00BCD4),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFF5F5F5),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF212121),
      onBackground: Color(0xFF212121),
    ),
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    cardColor: Colors.white,
    dividerColor: Color(0xFFE0E0E0),
  );
}
```

#### 暗色主题定义
```dart
ThemeData _buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF64B5F6),
      secondary: Color(0xFF00BCD4),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Color(0xFFE0E0E0),
      onBackground: Color(0xFFE0E0E0),
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    cardColor: Color(0xFF1E1E1E),
    dividerColor: Color(0xFF424242),
  );
}
```

#### 主题切换 UI
```dart
// 设置页面中的主题选择
SegmentedButton<ThemeMode>(
  segments: [
    ButtonSegment(
      value: ThemeMode.system,
      icon: Icon(Icons.brightness_auto),
      label: Text('跟随系统'),
    ),
    ButtonSegment(
      value: ThemeMode.light,
      icon: Icon(Icons.light_mode),
      label: Text('亮色'),
    ),
    ButtonSegment(
      value: ThemeMode.dark,
      icon: Icon(Icons.dark_mode),
      label: Text('暗色'),
    ),
  ],
  selected: {currentThemeMode},
  onSelectionChanged: (modes) {
    context.read(themeProvider).setThemeMode(modes.first);
  },
)
```

#### 主题持久化
```dart
// 保存用户主题偏好
class ThemeService {
  static const _key = 'theme_mode';
  
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
  
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key);
    return ThemeMode.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ThemeMode.system,
    );
  }
}
```

#### 组件适配规范
```
- 所有颜色必须从 Theme 获取
- 禁止硬编码颜色值
- 使用 ColorScheme 语义化颜色
- 测试亮色和暗色两种模式
```

```dart
// ✅ 正确 - 使用主题颜色
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Hello',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
    ),
  ),
)

// ❌ 错误 - 硬编码颜色
Container(
  color: Colors.white,
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.black),
  ),
)
```

---

### 字体规范

#### 字体家族
```dart
// 代码字体
fontFamilyCode: 'JetBrains Mono'
fontFamilyCodeFallback: 'Fira Code', 'Consolas', 'Monaco'

// UI 字体
fontFamilyUI: 'Inter'
fontFamilyUIFallback: 'Roboto', 'Segoe UI', 'Arial'
```

#### 字号规范
```dart
// 标题字号
headlineLarge: 28.0
headlineMedium: 24.0
headlineSmall: 20.0

// 正文字号
bodyLarge: 16.0
bodyMedium: 14.0
bodySmall: 12.0

// 标签字号
labelLarge: 14.0
labelMedium: 12.0
labelSmall: 10.0

// 代码字号
codeDefault: 14.0
codeSmall: 12.0
```

#### 行高规范
```dart
// 行高
heightTight: 1.2      // 标题
heightNormal: 1.5     // 正文
heightRelaxed: 1.8    // 宽松
```

---

### 间距规范

#### 基础间距单位
```dart
// 基础单位 4px
const double kSpaceUnit = 4.0;

// 间距梯度
const double kSpace4 = 4.0;    // xs
const double kSpace8 = 8.0;    // sm
const double kSpace12 = 12.0;  // md
const double kSpace16 = 16.0;  // lg
const double kSpace24 = 24.0;  // xl
const double kSpace32 = 32.0;  // 2xl
const double kSpace48 = 48.0;  // 3xl
```

#### 应用场景
```
组件内边距：8px - 16px
组件间距：12px - 24px
页面边距：16px - 32px
区块间距：32px - 48px
```

---

### 圆角规范

```dart
// 圆角梯度
const double kRadiusNone = 0.0;
const double kRadiusSmall = 4.0;    // 按钮、输入框
const double kRadiusMedium = 8.0;   // 卡片、对话框
const double kRadiusLarge = 12.0;   // 大卡片
const double kRadiusFull = 999.0;   // 圆形、胶囊
```

---

### 阴影规范

```dart
// 阴影层级
const List<BoxShadow> kShadowSmall = [
  BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  ),
];

const List<BoxShadow> kShadowMedium = [
  BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  ),
];

const List<BoxShadow> kShadowLarge = [
  BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  ),
];
```

---

## 组件规范

### 按钮

#### 主要按钮
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kRadiusSmall),
    ),
  ),
  onPressed: () {},
  child: Text('保存'),
)
```

#### 次要按钮
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: primary,
    side: BorderSide(color: primary),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kRadiusSmall),
    ),
  ),
  onPressed: () {},
  child: Text('取消'),
)
```

#### 文字按钮
```dart
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: primary,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  onPressed: () {},
  child: Text('了解更多'),
)
```

#### 图标按钮
```dart
IconButton(
  icon: Icon(Icons.add),
  onPressed: () {},
  tooltip: '新建文件',
)
```

---

### 输入框

```dart
TextField(
  decoration: InputDecoration(
    labelText: '文件名',
    hintText: '请输入文件名',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSmall),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
)
```

---

### 卡片

```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(kRadiusMedium),
    side: BorderSide(color: Colors.grey[300]!),
  ),
  child: Padding(
    padding: EdgeInsets.all(kSpace16),
    child: Column(
      children: [...],
    ),
  ),
)
```

---

### 对话框

```dart
AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(kRadiusMedium),
  ),
  title: Text('确认删除'),
  content: Text('确定要删除此文件吗？此操作不可撤销。'),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('取消'),
    ),
    ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: error,
      ),
      child: Text('删除'),
    ),
  ],
)
```

---

## 交互规范

### 悬停效果
```dart
// 悬停高亮
MouseRegion(
  cursor: SystemMouseCursors.click,
  child: Container(
    color: isHovered ? Colors.grey[100] : Colors.transparent,
    child: ...
  ),
)
```

### 点击反馈
```dart
// 涟漪效果
InkWell(
  onTap: () {},
  borderRadius: BorderRadius.circular(kRadiusSmall),
  child: Padding(
    padding: EdgeInsets.all(kSpace8),
    child: Text('点击'),
  ),
)
```

### 焦点状态
```dart
// 焦点边框
Container(
  decoration: BoxDecoration(
    border: Border.all(
      color: hasFocus ? primary : Colors.grey[300]!,
      width: hasFocus ? 2.0 : 1.0,
    ),
    borderRadius: BorderRadius.circular(kRadiusSmall),
  ),
)
```

---

## 动画规范

### 时长规范
```dart
// 动画时长
const Duration kDurationFast = Duration(milliseconds: 150);
const Duration kDurationNormal = Duration(milliseconds: 300);
const Duration kDurationSlow = Duration(milliseconds: 500);
```

### 曲线规范
```dart
// 动画曲线
const Curve kCurveDefault = Curves.easeInOut;
const Curve kCurveEnter = Curves.easeOut;
const Curve kCurveExit = Curves.easeIn;
```

### 常用动画
```dart
// 淡入淡出
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: kDurationNormal,
  curve: kCurveDefault,
  child: child,
)

// 滑动进入
AnimatedSlide(
  offset: isVisible ? Offset.zero : Offset(0, 0.1),
  duration: kDurationNormal,
  curve: kCurveEnter,
  child: child,
)

// 尺寸变化
AnimatedSize(
  duration: kDurationNormal,
  curve: kCurveDefault,
  child: Container(...),
)
```

---

## 响应式设计

### 断点规范
```dart
// 响应式断点
const double kBreakpointMobile = 600;
const double kBreakpointTablet = 900;
const double kBreakpointDesktop = 1200;
const double kBreakpointWide = 1600;
```

### 布局适配
```dart
// 根据屏幕宽度调整布局
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  
  if (width < kBreakpointMobile) {
    return MobileLayout();
  } else if (width < kBreakpointTablet) {
    return TabletLayout();
  } else {
    return DesktopLayout();
  }
}
```

### 侧边栏适配
```dart
// 小屏幕隐藏侧边栏
final showSidebar = width >= kBreakpointTablet;

return Row(
  children: [
    if (showSidebar) FileTreePanel(),
    Expanded(child: EditorPanel()),
  ],
);
```

---

## 可访问性

### 键盘导航
```dart
// 支持键盘快捷键
Shortcuts(
  shortcuts: {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
        SaveIntent(),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
        UndoIntent(),
  },
  child: Actions(
    actions: {
      SaveIntent: CallbackAction<SaveIntent>(
        onInvoke: (_) => _save(),
      ),
      UndoIntent: CallbackAction<UndoIntent>(
        onInvoke: (_) => _undo(),
      ),
    },
    child: Focus(autofocus: true, child: ...),
  ),
)
```

### 语义标签
```dart
// 添加语义信息
Semantics(
  label: '保存文件',
  button: true,
  child: IconButton(
    icon: Icon(Icons.save),
    onPressed: _save,
  ),
)
```

### 颜色对比度
```
- 文字与背景对比度 >= 4.5:1
- 大文字对比度 >= 3:1
- UI 组件对比度 >= 3:1
```

---

## 组件库规划

### 基础组件
- [ ] MFSButton - 按钮
- [ ] MFSInput - 输入框
- [ ] MFSCard - 卡片
- [ ] MFSDialog - 对话框
- [ ] MFSTooltip - 提示框

### 业务组件
- [ ] EditorToolbar - 编辑器工具栏
- [ ] FileTree - 文件树
- [ ] StatusBar - 状态栏
- [ ] MenuBar - 菜单栏

---

*文档版本：v0.1*
*最后更新：2026-06-20*

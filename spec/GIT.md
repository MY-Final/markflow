# MarkFlow - Git 提交规范

## 提交信息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

---

## Type 类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(editor): 添加代码块高亮` |
| `fix` | 修复 Bug | `fix(文件树): 修复目录展开异常` |
| `docs` | 文档更新 | `docs: 更新 README 安装说明` |
| `style` | 代码格式（不影响功能） | `style: 格式化 main.dart` |
| `refactor` | 重构 | `refactor(editor): 重构编辑器状态管理` |
| `perf` | 性能优化 | `perf: 优化 Markdown 渲染性能` |
| `test` | 测试相关 | `test: 添加编辑器单元测试` |
| `chore` | 构建/工具变动 | `chore: 更新依赖版本` |
| `build` | 构建系统 | `build: 配置 Windows 打包` |
| `ci` | CI/CD | `ci: 添加 GitHub Actions` |
| `revert` | 回滚 | `revert: 回滚 v0.1.0 变更` |

---

## Scope 范围（可选）

| 范围 | 说明 |
|------|------|
| `editor` | 编辑器模块 |
| `文件树` | 文件树模块 |
| `菜单栏` | 菜单栏模块 |
| `工具栏` | 工具栏模块 |
| `状态栏` | 状态栏模块 |
| `主题` | 主题相关 |
| `依赖` | 依赖更新 |

---

## 提交信息语言

**默认使用中文**，除非使用 `feat:` 等固定前缀。

### 示例

```
# ✅ 正确
feat(editor): 添加 Markdown 实时预览
fix: 修复文件保存时编码问题
chore: 升级 flutter_markdown_plus 依赖

# ❌ 错误
feat(editor): add markdown preview
fix: fix encoding issue
```

---

## 提交示例

```
feat(editor): 实现所见即所得 Markdown 编辑

- 支持标题、粗体、斜体基础语法
- 支持代码块高亮显示
- 支持列表嵌套

Closes #42
```

```
fix(文件树): 修复深层目录无法展开的问题

原因是递归查询路径拼接错误，已修正路径拼接逻辑。
```

---

## 工具推荐

- **commitlint** - 提交信息校验
- **husky** - Git hooks 管理
- **conventional-changelog** - 自动生成变更日志

---

*文档版本：v0.1*
*最后更新：2026-06-20*

# MarkFlow - 分支策略

## 分支模型

采用 **简化的 Git Flow** 模型：

```
main ─────────────────────────────────────────▶
  │                    ↑           ↑
  └──► develop ────────┴───────────┴─────────▶
        │      ↑
        ├──► feat/editor ──┐
        │                  ├──► PR
        ├──► feat/toolbar ─┘
        │
        └──► fix/save-bug ────► PR
```

---

## 分支类型

| 分支 | 命名 | 说明 | 生命周期 |
|------|------|------|----------|
| 主分支 | `main` | 稳定版本，可发布 | 永久 |
| 开发分支 | `develop` | 日常开发集成 | 永久 |
| 功能分支 | `feat/*` | 新功能开发 | 合并后删除 |
| 修复分支 | `fix/*` | Bug 修复 | 合并后删除 |
| 发布分支 | `release/*` | 版本发布准备 | 发布后删除 |
| 热修复 | `hotfix/*` | 紧急线上修复 | 合并后删除 |

---

## 分支命名规范

### 格式
```
<type>/<description>
```

### 示例
```bash
# 功能分支
feat/editor
feat/file-tree
feat/markdown-preview
feat/toolbar-bold-button

# 修复分支
fix/save-encoding
fix/crash-on-open
fix/sidebar-collapse

# 发布分支
release/v1.0.0
release/v1.1.0-beta

# 热修复分支
hotfix/critical-crash
hotfix/security-patch
```

### 命名规则
```
✅ 使用小写字母
✅ 使用连字符分隔单词
✅ 简短但具有描述性
❌ 避免使用中文
❌ 避免使用特殊字符
❌ 避免过长名称
```

---

## 分支工作流程

### 功能开发流程

```bash
# 1. 从 develop 创建功能分支
git checkout develop
git pull origin develop
git checkout -b feat/editor

# 2. 开发并提交
git add .
git commit -m "feat(editor): 实现基础编辑功能"

# 3. 推送到远程
git push origin feat/editor

# 4. 创建 PR -> develop
# 5. 代码审查通过后合并
# 6. 删除功能分支
git branch -d feat/editor
```

### Bug 修复流程

```bash
# 1. 从 develop 创建修复分支
git checkout develop
git checkout -b fix/save-bug

# 2. 修复并提交
git add .
git commit -m "fix: 修复保存时编码错误"

# 3. 推送并创建 PR
git push origin fix/save-bug
```

### 发布流程

```bash
# 1. 从 develop 创建发布分支
git checkout develop
git checkout -b release/v1.0.0

# 2. 只接受 bug 修复，不添加新功能
git commit -m "fix: 修复发布前发现的问题"

# 3. 合并到 main 并打 tag
git checkout main
git merge release/v1.0.0
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin main --tags

# 4. 合并回 develop
git checkout develop
git merge release/v1.0.0

# 5. 删除发布分支
git branch -d release/v1.0.0
```

### 热修复流程

```bash
# 1. 从 main 创建热修复分支
git checkout main
git checkout -b hotfix/critical-crash

# 2. 修复并提交
git commit -m "fix: 修复关键崩溃问题"

# 3. 同时合并到 main 和 develop
git checkout main
git merge hotfix/critical-crash
git tag -a v1.0.1 -m "Hotfix v1.0.1"

git checkout develop
git merge hotfix/critical-crash

# 4. 删除热修复分支
git branch -d hotfix/critical-crash
```

---

## PR 规范

### PR 标题格式
```
<type>(<scope>): <简要描述>
```

### 示例
```
feat(editor): 添加代码块语法高亮
fix(文件树): 修复深层目录展开问题
docs: 更新安装说明文档
```

### PR 描述模板
```markdown
## 变更说明
[描述本次变更的内容]

## 变更类型
- [ ] 新功能
- [ ] Bug 修复
- [ ] 重构
- [ ] 文档更新
- [ ] 其他

## 测试情况
- [ ] 本地测试通过
- [ ] 添加单元测试
- [ ] 无破坏性变更

## 关联 Issue
Closes #123
```

### PR 检查清单
```
- [ ] 代码符合项目规范
- [ ] 无编译错误
- [ ] 无测试失败
- [ ] 已自测功能
- [ ] 提交信息符合规范
- [ ] 无合并冲突
```

---

## 保护分支规则

### main 分支
```
- 禁止直接 push
- 必须通过 PR 合并
- 需要至少 1 人审查
- 必须通过 CI 检查
- 合并后自动删除源分支
```

### develop 分支
```
- 禁止直接 push
- 必须通过 PR 合并
- 建议进行代码审查
- 必须通过 CI 检查
```

---

## 版本标签

### 语义化版本
```
v<主版本>.<次版本>.<修订号>

v1.0.0  - 正式版本
v1.1.0  - 功能更新
v1.1.1  - Bug 修复
v2.0.0  - 重大更新
```

### 预发布标签
```
v1.0.0-alpha.1  - Alpha 测试
v1.0.0-beta.1   - Beta 测试
v1.0.0-rc.1     - 候选版本
```

### 打标签命令
```bash
# 轻量标签
git tag v1.0.0

# 附注标签
git tag -a v1.0.0 -m "Release v1.0.0"

# 推送标签
git push origin v1.0.0
git push origin --tags
```

---

## 分支清理策略

### 自动清理
```
- PR 合并后自动删除源分支
- GitHub 设置：Settings > General > Automatically delete head branches
```

### 手动清理
```bash
# 查看已合并的本地分支
git branch --merged

# 删除已合并的本地分支
git branch -d feat/old-feature

# 删除已合并的远程分支
git push origin --delete feat/old-feature
```

---

*文档版本：v0.1*
*最后更新：2026-06-20*

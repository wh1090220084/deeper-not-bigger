# ambitious-task-upgrader

把“帮我做一个任务”升级成“帮我实现真正目的”的可移植 AI skill。它会先判断 L1/L2/L3 档位，再把任务提升到机制、原始证据和可验证结果；L2/L3 默认先生成升级版提示词，等用户确认后才执行。

## 目录

```text
ambitious-task-upgrader/
├── SKILL.md                 # 跨客户端通用入口
├── agents/openai.yaml       # Codex UI 元数据
├── manifest.json            # 包名、版本和文件清单
├── scripts/validate_skill.ps1
├── scripts/release.ps1
├── CHANGELOG.md
└── LICENSE
```

## 版本

当前版本：**1.0.0**。版本遵循 SemVer：

- `MAJOR`：工作流不兼容变化；
- `MINOR`：向后兼容的新能力或新适配；
- `PATCH`：文字、示例、校验和文档修复。

## 安装

### Claude Code

将整个目录复制到项目级或用户级 skills 目录：

```powershell
# 当前项目
Copy-Item -Recurse . .claude/skills/ambitious-task-upgrader

# 用户级（Windows，按需替换路径）
Copy-Item -Recurse . "$HOME/.claude/skills/ambitious-task-upgrader"
```

Claude Code 会读取目录中的 `SKILL.md`。调用示例：

```text
/ambitious-task-upgrader
帮我做季度复盘，但我要更深版本，不是更长版本。
```

如果你的 Claude 客户端使用自定义 skills 目录，只需把 `SKILL.md` 放入该目录，并保留 frontmatter 的 `name` 和 `description`。

### Codex

复制到用户级 Codex skills 目录：

```powershell
$codexSkills = if ($env:CODEX_HOME) { Join-Path $env:CODEX_HOME 'skills' } else { Join-Path $HOME '.codex/skills' }
Copy-Item -Recurse . (Join-Path $codexSkills 'ambitious-task-upgrader')
```

Codex 会使用 `SKILL.md`；`agents/openai.yaml` 提供界面名称、默认提示词和自动调用策略。调用示例：

```text
$ambitious-task-upgrader
把我的客户流失分析升级成更深版本，先给升级版提示词。
```

### ChatGPT、Gemini、OpenCode 或其他支持 Markdown 指令的工具

把 `SKILL.md` 的完整内容作为项目级 instruction、system prompt、custom skill 或 workspace rule 导入。若工具支持目录型 skill，直接导入本目录；若只支持单文件，导入 `SKILL.md` 即可。

这份 skill 不依赖 MCP、网络服务、Python 包或厂商私有 API，因此同一份内容可在不同客户端复用。客户端特有的 UI 元数据只放在 `agents/openai.yaml`，不会影响其他工具。

## 第一次使用

先用下面两条请求验证路由：

### L1：单点查询

```text
快速告诉我 2025 年中国 GDP 增速，只要一句话。
```

预期：开头声明 L1；不组梦之队、不启动全量裁判；给出最小必要回答或最小咒语。

### L2：季度复盘

```text
帮我做季度复盘，汇总收入、成本、利润并给改进建议。我想要更深版本，不是更长版本。
```

预期：开头声明 L2 或因“机制/预警/验证”升为 L3；先诊断真实目的，列原始材料、机制和验证方案，再给升级版提示词并等待确认。

### L3：高风险机制

```text
为供应链设计预警机制，要求用过去 8 个季度回测，找出会误报和漏报的情况。
```

预期：声明 L3；要求历史回测、红队或独立盲评；交付时说明外部裁判级别、置信度、反例和未验证项。

## 用户确认分支

- “可以/执行”：开始执行升级版提示词。
- “把原始数据改成订单流水和退款文本”：只修改对应段，复述变更后再次确认。
- “直接做”：可以执行，但结果开头必须标注已跳过提示词确认及方向偏差风险。
- 用户继续追问或沉默：不提前执行，继续澄清目的和成功标准。

## 本地校验与发布

在 PowerShell 中运行：

```powershell
.\scripts\validate_skill.ps1
```

校验 frontmatter、名称、版本、关键工作流段落和清单文件。发布压缩包：

```powershell
.\scripts\release.ps1
```

脚本会先校验，再生成 `dist/ambitious-task-upgrader-v1.0.0.zip`。发布前建议把压缩包解压到临时目录，按上面的 Claude/Codex 步骤完成一次 L1 和一次 L2 验证。

Linux/macOS 可运行对应的 shell 入口：

```bash
./scripts/validate_skill.sh
./scripts/release.sh
```

## 发布到 GitHub/GitLab

```powershell
git init
git add .
git commit -m "release: ambitious-task-upgrader v1.0.0"
git tag v1.0.0
git remote add origin <你的仓库地址>
git push -u origin main --tags
```

随后在 GitHub Release 或 GitLab Release 中上传 `dist/ambitious-task-upgrader-v1.0.0.zip`，并把本 README 的安装段作为 release notes。没有远程仓库时，直接分发 zip 也能安装。

## 适用边界

它适合研究、复盘、策略、诊断、机制设计和提示词升级；纯创意发散、单点事实查询和明确只要快速草稿不应强推 L3。外部裁判能力不足时，至少执行红队自检和用户可执行的最小验证，并明确局限。

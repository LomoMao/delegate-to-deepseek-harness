# delegate-to-deepseek-harness

[English](README.md)

> Codex 负责判断，DeepSeek Harness 负责干活。

`delegate-to-deepseek-harness` 是一个很轻的 Agent Skill：把边界清楚的编码任务交给 DeepSeek Harness 执行，再由 Codex 回来做 review 和最终验收。

它不打算做成一个大而全的调度框架。Skill 只负责把“什么时候该委派、任务怎么交代、回来后怎么验收”这几件事做好；真正的 Worker 可以走 DeepSeek Harness MCP，也可以直接用官方 headless CLI。

## 为什么做这个

很多开发任务真正消耗上下文和时间的，并不是最后那个判断，而是读一大堆代码、机械修改、修测试、迁移 API，或者实现一个已经说得很清楚的小模块。

这个 Skill 希望把分工保持简单：

```text
你 → Codex → DeepSeek Harness → 修改工作区
             ↓
        Codex 再检查
        diff + tests
```

Codex 继续负责范围、风险判断、集成和最后的结论。

**方法论优先，后端可换。** 这个 Skill 真正可复用的是「委派契约 + 验收门禁」这套规则，而不是某一条 Worker 通路。即使 MCP 桥接哪天不可用或接口变了，headless CLI 兜底路径（以及未来任何 Harness 接口）都能让同一套流程继续运转。

## 适合交给 Harness 的事

- 边界清楚的功能实现
- 机械重构、迁移、批量修改
- 修测试、补测试
- 带明确问题的仓库探索
- 需要第二种实现思路时
- 不同 worktree 里的并行任务

不太适合：架构拍板、密钥和敏感操作、部署、破坏性操作，以及根本没办法验证结果的任务。

## 安装

Codex 的用户 Skill 目录是 `$CODEX_HOME/skills`（默认 `~/.codex/skills/`）。

**方式一：用本仓库的安装脚本**

```bash
git clone https://github.com/LomoMao/delegate-to-deepseek-harness.git
cd delegate-to-deepseek-harness
./scripts/install_skill.sh   # 默认装到 $CODEX_HOME/skills（即 ~/.codex/skills）
```

**方式二：手动复制** —— 把 `SKILL.md`、`agents/`、`references/`、`scripts/` 复制到 `$CODEX_HOME/skills/delegate-to-deepseek-harness/`。

**方式三：Codex 内置 Skill 安装器**（仓库公开后）：

```text
$skill-installer install https://github.com/LomoMao/delegate-to-deepseek-harness
```

然后在 Codex 里调用：

```text
$delegate-to-deepseek-harness
```

例如：

```text
Use $delegate-to-deepseek-harness to fix the failing parser tests.
Keep the public API unchanged, then review the diff and rerun the focused tests yourself.
```

## Worker 怎么跑

**优先：** 本地 DeepSeek Harness MCP，提供 `agent_run`、`task_inbox`、`task_result` 这类工具。

**兜底：** DeepSeek Harness 官方的一次性 headless 模式：

```bash
dsh --profile headless "run the tests"
```

当前 MCP 示例和安全配置见 [setup](references/setup.md)。

## 最重要的一条

Worker 说“完成了”，不等于任务真的完成了。

委派结束后，Codex 仍然应该检查工作区、看 diff，并自己跑相关 tests / lint / typecheck / build，再决定能不能向用户说“好了”。

## 当前状态

这是一个早期版本，而且故意保持小。现在已经能用，但 DeepSeek Harness 生态变化很快，MCP 工具名和安装方式后面都有可能调整。本文档里的 MCP 工具名以 `@chushixixin/dsh-harness-mcp-server` v0.1.x 为准，详见 [setup](references/setup.md)。

欢迎提 Issue，也欢迎小而清楚的 PR。

## 安全

Harness Worker 可能拥有文件修改和 shell 执行能力。第三方 Harness 插件应该按“可信本地代码”来对待；MCP 尽量只监听 loopback，并限制可写 workspace。更多见 [SECURITY.md](SECURITY.md)。

## 致谢

这个项目借鉴了 `delegate-skills`、`delegate-to-pi` 等 reviewer/worker 类型项目的思路。

本项目是独立社区项目，与 OpenAI、DeepSeek 官方均无隶属关系。

## License

MIT

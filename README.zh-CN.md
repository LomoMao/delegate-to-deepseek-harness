# delegate-to-deepseek-harness

[English](README.md)

> Codex 负责判断，DeepSeek Harness 负责干活。

```text
Codex              = 编排者 + 验收者
DeepSeek Harness   = Worker
```

```text
用户 → Codex ── 边界清楚的活 ──→ DeepSeek Harness Worker
                                          │
                              改动 + 测试
                                          ↓
                                  Codex 验收 ✓
```

`delegate-to-deepseek-harness` 是一个很轻的 Agent Skill：把边界清楚的编码任务交给 DeepSeek Harness 执行，再由 Codex 回来做 review 和最终验收。

它刻意不做一个框架。没有任务队列，没有看板，没有新的配置格式——就三件事，老老实实回答：**这件事该不该委派、Worker 具体要做什么、结果怎么验证才算数。**

Worker 本身可以走 DeepSeek Harness MCP，也可以直接用官方 headless CLI。哪条路明天坏了，这套流程都不会坏。

## 先试一下

```bash
git clone https://github.com/LomoMao/delegate-to-deepseek-harness.git
cd delegate-to-deepseek-harness
./scripts/install_skill.sh   # 默认装到 $HOME/.agents/skills
```

然后在 Codex 里说：

```text
Use $delegate-to-deepseek-harness to fix the failing parser tests.
Keep the public API unchanged, then review the diff and rerun the focused tests yourself.
```

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

## 其他安装方式

Codex 的用户 Skill 目录是 `$HOME/.agents/skills`（仓库级 Skill 在 `.agents/skills`）。

**手动复制** —— 把 `SKILL.md`、`agents/`、`references/`、`scripts/` 复制到 `$HOME/.agents/skills/delegate-to-deepseek-harness/`。

**Codex 内置 Skill 安装器**：

```text
$skill-installer install https://github.com/LomoMao/delegate-to-deepseek-harness
```

## Worker 怎么跑

**优先：** 本地 DeepSeek Harness MCP，提供 `agent_run`、`task_inbox`、`task_result` 这类工具。

**兜底：** DeepSeek Harness 官方的一次性 headless 模式：

```bash
dsh --profile headless "run the tests"
```

当前 MCP 示例和安全配置见 [setup](references/setup.md)。

## 最重要的一条

Worker 说"完成了"，不等于任务真的完成了。

委派结束后，Codex 仍然应该检查工作区、看 diff，并自己跑相关 tests / lint / typecheck / build，再决定能不能向用户说"好了"。

## 当前状态

这是一个刻意保持小的项目，而且会一直这么小。核心流程——契约、委派、验收——是稳定的；它周围的 DeepSeek Harness 生态变化很快，所以文档里的 MCP 工具名以 `@chushixixin/dsh-harness-mcp-server` v0.1.x 为准（见 [setup](references/setup.md)），升级后可能需要小幅核对。

欢迎提 Issue，也欢迎小而清楚的 PR。

## 安全

Harness Worker 可能拥有文件修改和 shell 执行能力。第三方 Harness 插件应该按"可信本地代码"来对待；MCP 尽量只监听 loopback，并限制可写 workspace。更多见 [SECURITY.md](SECURITY.md)。

## 致谢

这个项目借鉴了 `delegate-skills`、`delegate-to-pi` 等 reviewer/worker 类型项目的思路。

本项目是独立社区项目，与 OpenAI、DeepSeek 官方均无隶属关系。

## License

MIT

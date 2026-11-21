---
layout: post
lang: zh-CN
title: "基于 dsh-agent-teams 的自动开发流：实现、运行结果与问题"
description: "记录基于 dsh-agent-teams 的自动开发流实现与运行结果：角色划分、任务契约、PR 流程，以及约 40 个 PR 后暴露的状态与调度问题。"
tags: [dsh, agent, workflow]
summary: >-
  本文记录基于 dsh-agent-teams 的自动开发流：五类角色、任务契约与 PR 阶段边界；
  流程累计完成约 40 个 PR、一百多个 commit，暴露出状态漂移和调度依赖人工等问题，
  这些问题也是 dsh-auto-workflow 的设计出发点。
---

本文记录使用 `dsh-agent-teams` 搭建自动开发流的一次尝试。该流程将需求、实现、验证、审查与合并拆分为独立角色，并以 GitHub PR 作为阶段边界。流程累计完成约 40 个 PR、一百多个 commit；运行中暴露出状态漂移、调度依赖人工等问题。针对这些问题，本文介绍新插件 `dsh-auto-workflow` 的设计目标。

<figure>
  <a href="{{ '/assets/images/blog/agent-teams-workflow.webp' | relative_url }}" target="_blank" rel="noopener">
    <img src="{{ '/assets/images/blog/agent-teams-workflow.webp' | relative_url }}"
         alt="基于 dsh-agent-teams 的开发流：需求师、工程师、PR、验证师、审查师、待合并池，以及队长和人工合并"
         width="1200" height="520">
  </a>
  <figcaption>图 1：基于 dsh-agent-teams 的开发流。需求、实现、验证、审查与合并由不同角色执行，PR 作为阶段边界。</figcaption>
</figure>

## 实现方式

`dsh-agent-teams` 允许定义长期运行的 agent，并为其配置角色、工具、任务和调度逻辑。本文的流程包含五类角色：

| 角色 | 职责 |
| --- | --- |
| 需求师 | 将需求整理为可执行的规格与验收标准 |
| 工程师 | 在独立 worktree 中实现，并提交 PR |
| 验证师 | 按验收标准执行测试与 CI，结果绑定到具体 commit |
| 审查师 | 独立审查代码、方案与改动边界 |
| 队长 | 负责任务调度、PR 跟进与异常处理 |

每个任务以契约形式描述，包含四项内容：目标说明本次改动要解决的问题，验收给出判定完成的可执行标准，范围限定允许修改的文件或目录，验证列出必须执行的命令与 CI 检查项。

一次任务从需求师提交规格开始。工程师从最新 `main` 创建独立 worktree，完成实现并提交 PR；验证师在 PR 上按验收标准执行测试与 CI，并将结果绑定到具体 commit；审查师独立审查代码、方案与改动边界；通过后进入待合并池，由人工或 Codex 合并。

流程约束如下：

- 每个任务从最新 `main` 创建独立 worktree，不在主目录混改；
- 实现、验证、审查必须由不同 agent 执行；
- 验证必须绑定具体 commit，并以真实 CI 结果为准；
- 审查未通过时返工，返工后重新执行验证与审查；
- 合并权限保留给人工或 Codex，队长与成员不自动合并。

队长负责维护任务状态，包括实现、验证、审查与待合并阶段，并处理冲突、CI 失败与额度不足等异常。

## 运行结果与问题

该流程累计完成约 40 个 PR、一百多个 commit。运行结果表明，多角色协作与 PR 边界可以支撑实际开发，但仍存在以下问题。

第一，无法完全自动化。需求取舍、合并顺序、冲突处理以及验证结论的可信度，仍需人工判断。

第二，状态漂移与运行不稳定。Agent 会失败，上下文会超限，provider 会限流。队长的上下文随任务累积而漂移，其状态与真实仓库逐渐不一致。成员可能因额度或工具问题被移除并重新加入，导致旧任务重新排队。运行过程仍需人工中断、纠正和重新划定边界。

第三，调度依赖人工。自动派发任务并不可靠。任务失败、暂停或成员更换后，需要重新派发。队长实际承担了调度员的工作。

上述问题的共同原因是 workflow 状态依赖队长的会话上下文。为此，本文开发了新插件 [`dsh-auto-workflow`](https://lyingloong.github.io/dsh-auto-workflow/)，其设计目标是将流程状态、任务和调度规则从队长会话中移出，由插件持久化管理。该插件目前仍在开发中；本文记录的是上一版实践的运行结果与问题，不构成 `dsh-auto-workflow` 的发布说明。

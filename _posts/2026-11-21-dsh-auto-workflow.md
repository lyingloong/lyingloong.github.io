---
layout: post
lang: zh-CN
title: "dsh-auto-workflow：把多 agent 工作流从会话里拿出来"
description: "dsh-auto-workflow 是 DSH 的持久化节点图插件。本文介绍它如何调度 agent、并发和 Human 决策，以及仓库自带的 GitHub 开发流示例。"
tags: [dsh, agent, workflow]
translation_key: dsh-auto-workflow
summary: >-
  dsh-auto-workflow 把 agent、命令、HTTP 和 Human 决策放进同一张持久化节点图。
  本文介绍它的运行方式，以及如何用这套运行时搭一个 3+3 的 GitHub 开发流。
---

多 agent 开发流真正难的地方通常不是模型能力，而是状态：任务跑到哪、谁在等谁、失败后怎么继续。如果这些只存在队长（如 [dsh-agent-teams](/2026/11/08/agent-teams-workflow.html) 中的 Captain）的会话里，流程很快就会漂。dsh-auto-workflow 想解决的就是这个问题。

它是 DeepSeek Harness 的插件：agent、command、HTTP 请求和 Human 决策都在同一张图里；新任务以独立 packet 进入，某个 packet 等待 Human 时，其他 packet 继续跑。插件本身只提供通用节点图运行时，Git、PR、需求优先级这些逻辑都在示例应用里。

<figure>
  <a href="{{ '/assets/images/blog/dsh-auto-workflow-architecture.svg' | relative_url }}" target="_blank" rel="noopener">
    <img src="{{ '/assets/images/blog/dsh-auto-workflow-architecture.svg' | relative_url }}"
         alt="dsh-auto-workflow 架构：DSH Host 内的引擎、执行面和接口"
         width="900" height="330">
  </a>
  <figcaption>图 1：dsh-auto-workflow 的运行时结构。引擎负责调度、packet 状态、artifact 和权限；执行面负责 agent、command、HTTP 与 Human 的具体执行。</figcaption>
</figure>

## 它是怎么跑的

从结构上看，一次工作流被拆成三层：run、packet 和 token。run 是持久化的运行容器，绑定一个不可变的项目目录，并使用一份冻结的节点图；packet 是一份独立输入及其图执行，拥有自己的结果和终态；token 是某个 packet 对某个节点的一次执行。节点服务是常驻工作池，状态在 `running`、`idle` 和 `disabled` 之间变化，不会因为一项任务结束而退出。

这三层决定了调度的基本行为。新任务以 packet 进入已有 run，不同 packet 相互隔离；节点按并发上限从队列领取 token；Human 等待不占工作槽，也不会阻塞其他 packet。因此，一个长时间等待审批的任务不会拖住整个 run。

packet 在图中移动时，节点负责具体执行：agent 调用模型子任务，command 执行命令，HTTP 发起请求，Human 等待决策；边根据 outcome 决定下一步，fanout 创建并发分支，join 聚合，gate 控制节奏。输入通过 `$input`、`$prev`、`$nodes.<id>.output` 等表达式映射，动态 worktree 路径可以来自上一节点的输出，而不是硬编码。

调度状态、图定义、artifact 和历史都会落盘；checkpoint 只保存引用，大对象放在业务文件里。command/HTTP 默认拒绝，需要显式授权；agent 的工具权限另算。Human 通过一个带 token 的私有看板查看详情并决策。这样，流程状态不再依赖队长的上下文，而是由 run 自己保存。

中断语义也由这个模型决定。持久化不等于自动恢复：Host 停止或执行中断后，running 任务会保留为证据，不会静默重放；恢复需要人先检查副作用，再显式续接。这样运行时不会把不确定的副作用当作已恢复，恢复责任回到操作者。

## 仓库里的开发流示例

上面的运行时并不绑定具体业务流程。仓库带了一个完整的 GitHub 项目开发流示例，用来展示这套运行时如何承载真实开发。克隆项目后，每个需求拥有稳定 ID、独立的 `auto/req-*` 分支、独立 worktree 和 draft PR；snapshot 把整个分支压成单个 commit，reviewer 对精确 commit 审查，brief 生成 Human/PR 共用的结构化摘要；PR 标记 ready 后，外部 Codex 或人可以直接 merge，工作流只负责验证和清理。

<figure>
  <a href="{{ '/assets/images/blog/dsh-auto-workflow-lifecycle.svg' | relative_url }}" target="_blank" rel="noopener">
    <img src="{{ '/assets/images/blog/dsh-auto-workflow-lifecycle.svg' | relative_url }}"
         alt="开发示例中的需求生命周期：需求、分支、Draft PR、审查、Ready PR、合并、验证"
         width="900" height="180">
  </a>
  <figcaption>图 2：开发示例中的需求生命周期。一个需求对应一个分支、一个 worktree 和一个 PR；审查通过并生成 brief 后标记 ready，外部可直接 merge，超过宽限期后由 Human 批准 self-merge，最后验证并清理。</figcaption>
</figure>

示例使用 3+3 工作池：最多 3 个 engineer、3 个 reviewer，每个需求只分配一位 reviewer；根并发为 6，命令和 miner 也占这 6 个槽位。需求来源有两类：用户 intake 的 priority 为 0，直接进入开发；从已有证据 seed 挖出的需求 priority 为 1..9，低风险直接进入，中高风险先过 Human 需求审批。

一个需求大致这样走：prepare 建分支和 worktree，begin-engineering 进入 engineer 池，snapshot 压成单 commit，publish-pr 创建 draft PR，reviewer 审查，brief 后标记 ready；外部 merge，或超过宽限期后由 Human 批准 self-merge；check-pr 验证 review commit 已进入 base，最后清理 worktree 和本地分支。

这个示例想说明的是插件能承载什么：持续 intake、并发开发、多个 Human 门禁、外部 PR 流程和可验证的合并。插件核心不处理 Git 和 PR，这些都在示例代码里；换成你自己的节点图、角色和合并策略，运行时不需要改。

代码、完整文档和示例在 [GitHub 仓库](https://github.com/lyingloong/dsh-auto-workflow)，项目页在 [lyingloong.github.io/dsh-auto-workflow](https://lyingloong.github.io/dsh-auto-workflow/)。

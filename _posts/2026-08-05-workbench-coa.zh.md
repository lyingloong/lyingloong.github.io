---
layout: post
title: "DR-CoA: Maybe Replanning Is a Good Choice"
description: "在 WorkBench 上复现 CoA 时，一个关于副作用、反思与重新规划的实验记录。"
tags: [agents, tool-use, reflection, workbench]
published: false
---

本文记录在 WorkBench 上参考 OPPO PersonalAI Lab [Chain-of-Agents（CoA）](https://github.com/OPPO-PersonalAI/Agent_Foundation_Models) 的一次实现与观察。CoA 以单个模型模拟多角色协作；本文将其简化为由 `plan`、`tool` 和 `reflection` 组成的受控循环。

<figure>
  <img src="{{ '/assets/images/blog/workbench-pipeline.png' | relative_url }}" alt="WorkBench sandbox, tool execution, and outcome-centric evaluation pipeline">
  <figcaption><em>WorkBench 的沙箱执行与结果导向评测流程。图片来自 <a href="https://github.com/olly-styles/WorkBench">WorkBench</a> 项目（MindsDB，MIT License）。</em></figcaption>
</figure>

## 在 WorkBench 上复现 CoA 时遇到的两个问题

[WorkBench](https://arxiv.org/abs/2405.00823) 在沙箱中执行工具调用，并以最终环境状态进行评测。本文将不带副作用的失败记为 E1，将产生不符合目标状态副作用的失败记为 E2。

第一个观察是，CoA-v1 相较 SingleAgent 将 Acc 从 38.35% 提升至 73.63%，但 E2 也从 5.19% 升至 24.15%。CoA-v1 的失败样本中，E2 占约 92%。因此，工具调用能力增强后，问题不再只是未完成任务，也包括以错误方式改变环境。

第二个观察是计划带来的“轨迹惯性”。计划一旦确定，后续工具选择会以它为依据。若 reflection 只在轨迹中追加判断，却不使旧 `plan` 失效，后续动作仍会沿着原计划展开；当错误来自计划本身时，单纯反思无法改变其方向。由此需要解决两个问题：在执行前拦截不合适的调用；调用被拒绝后，不再沿用旧计划。

DR-CoA（Dual-Reflection CoA）在工具调用前后各加入一次反思，并规定前置反思拒绝动作时必须重新规划。

## reflection 与 replan

模型提出候选工具调用后，调用先暂存为 `pending_tool`，再进入 `pre-reflect`。该阶段检查调用是否与任务和计划一致、是否必要或重复、参数是否正确，以及副作用操作的前提是否已经满足。

`pre-reflect` 返回 `allow` 或 `replan`。前者执行调用；后者丢弃 `pending_tool` 并使旧 `plan` 失效，再返回规划阶段。被拒绝的调用通常暴露的是任务理解、步骤顺序或依赖关系的问题，而非单一参数错误；replan 的作用正是打断这种轨迹惯性。

工具执行后，`post-reflect` 检查 observation 是否支持当前计划；若不支持，同样返回 `plan`。因此，DR-CoA 的重点不是增加反思次数，而是将“拒绝后重新规划”设为明确的状态转移。

## 实验结果

下表给出 WorkBench 测试结果，所有系统均使用 `deepseek-v4-flash` 作为底层模型。DR-CoA-v2 在 v1 的状态机上进一步采用分阶段提示词。

| System | Acc | E1 | E2 |
| --- | ---: | ---: | ---: |
| SingleAgent | 38.35% | 56.46% | 5.19% |
| CoA-v1 | 73.63% | 2.22% | 24.15% |
| DR-CoA-v1 | 84.34% | 2.52% | 13.14% |
| DR-CoA-v2 | 85.03% | 3.01% | 11.96% |

相较 CoA-v1，DR-CoA-v2 的 Acc 从 73.63% 提升至 85.03%，E2 从 24.15% 降至 11.96%。该变化不能完全归因于 replan，因为 DR-CoA 同时引入了前后反思和状态约束；但它支持本文的观察：对于具有副作用的工具调用，若当前动作被判定为不合适，返回 `plan` 重新规划值得优先于在旧轨迹上修补。

---
layout: post
title: "DR-CoA: Maybe Replanning Is a Good Choice"
description: "A WorkBench experiment on side effects, reflection, and replanning in Chain-of-Agents."
tags: [agents, tool-use, reflection, workbench]
---

This post documents an implementation and observation study in WorkBench, informed by OPPO PersonalAI Lab's [Chain-of-Agents (CoA)](https://github.com/OPPO-PersonalAI/Agent_Foundation_Models). CoA uses a single model to simulate multi-role collaboration; here, it is simplified into a controlled loop of `plan`, `tool`, and `reflection` stages.

<figure>
  <img src="{{ '/assets/images/blog/workbench-pipeline.png' | relative_url }}" alt="WorkBench sandbox, tool execution, and outcome-centric evaluation pipeline">
  <figcaption><em>WorkBench's sandbox execution and outcome-centric evaluation flow. Image from the <a href="https://github.com/olly-styles/WorkBench">WorkBench</a> project (MindsDB, MIT License).</em></figcaption>
</figure>

## Two Issues in Reproducing CoA on WorkBench

[WorkBench](https://arxiv.org/abs/2405.00823) executes tool calls in a sandbox and evaluates the resulting environment state. I refer to failures without side effects as E1, and to failures that create side effects inconsistent with the target state as E2.

The first observation is that CoA-v1 raises Acc from 38.35% to 73.63% relative to SingleAgent, while E2 also rises from 5.19% to 24.15%. E2 accounts for about 92% of CoA-v1 failures. With stronger tool use, the problem is no longer only failing to finish a task; it also includes changing the environment in the wrong way.

The second observation is plan-induced trajectory inertia. Once a plan is fixed, later tool choices are conditioned on it. If reflection only appends a judgment to the trajectory without invalidating the old `plan`, subsequent actions can still follow that plan. When the error is in the plan itself, reflection alone cannot change the direction of the trajectory. This creates two requirements: intercept inappropriate calls before execution, and do not retain the old plan when a call is rejected.

DR-CoA (Dual-Reflection CoA) adds one reflection before and one after each tool call, and requires replanning whenever pre-reflection rejects an action.

## Reflection and Replanning

After the model proposes a tool call, it is stored as `pending_tool` and passed to `pre-reflect`. This stage checks task and plan alignment, necessity and redundancy, parameter validity, and whether the prerequisites for a side-effecting action have been met.

`pre-reflect` returns either `allow` or `replan`. The former executes the call; the latter discards `pending_tool`, invalidates the old `plan`, and returns to planning. A rejected call commonly exposes an issue in task interpretation, ordering, or dependencies rather than a single bad parameter. Replanning is intended to break this trajectory inertia.

After execution, `post-reflect` checks whether the observation supports the current plan; otherwise, it also returns to `plan`. The point of DR-CoA is therefore not simply to add more reflection, but to make replanning after rejection an explicit state transition.

## Experimental Results

The table below reports the WorkBench results. All systems use `deepseek-v4-flash` as the underlying model. DR-CoA-v2 further introduces phase-specific prompts on top of the v1 state machine.

| System | Acc | E1 | E2 |
| --- | ---: | ---: | ---: |
| SingleAgent | 38.35% | 56.46% | 5.19% |
| CoA-v1 | 73.63% | 2.22% | 24.15% |
| DR-CoA-v1 | 84.34% | 2.52% | 13.14% |
| DR-CoA-v2 | 85.03% | 3.01% | 11.96% |

Compared with CoA-v1, DR-CoA-v2 raises Acc from 73.63% to 85.03% and lowers E2 from 24.15% to 11.96%. This change cannot be attributed entirely to replanning because DR-CoA also introduces pre- and post-reflection and state constraints. Still, it supports the observation in this post: for tool calls with side effects, when an action is judged inappropriate, returning to `plan` for replanning is worth trying before patching the existing trajectory.

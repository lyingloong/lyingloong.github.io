---
layout: post
title: "DR-CoA: Reflection and Replanning for Tool-Using Agents"
description: "An experiment on tool-call side effects and plan revision in WorkBench."
tags: [agents, tool-use, reflection, workbench]
updated: 2026-11-06
summary: >-
  DR-CoA checks tool calls before and after execution and replans when a proposed
  action is rejected. In this WorkBench experiment, DR-CoA-v2 increases accuracy
  from 73.63% to 85.03% and reduces failures with inconsistent side effects from
  24.15% to 11.96%, compared with CoA-v1.
---

This post reports an implementation and observation study in [WorkBench](https://arxiv.org/abs/2405.00823), informed by OPPO PersonalAI Lab's [Chain-of-Agents (CoA)](https://github.com/OPPO-PersonalAI/Agent_Foundation_Models). CoA uses a single model to simulate multi-role collaboration. Here, it is simplified into a controlled loop of `plan`, `tool`, and `reflection` stages.

<figure>
  <a href="{{ '/assets/images/blog/workbench-pipeline.webp' | relative_url }}" aria-label="Open the WorkBench pipeline figure at full size">
    <img src="{{ '/assets/images/blog/workbench-pipeline.webp' | relative_url }}" alt="WorkBench sandbox, tool execution, and outcome-centric evaluation pipeline" width="1360" height="430">
  </a>
  <figcaption>WorkBench's sandbox execution and outcome-centric evaluation flow. Source: <a href="https://github.com/olly-styles/WorkBench">WorkBench</a> (MindsDB, MIT License). Select the figure to view it at full size.</figcaption>
</figure>

## Motivation

WorkBench executes tool calls in a sandbox and evaluates the resulting environment state. Two observations from reproducing CoA motivated this experiment.

### Failures with side effects

I distinguish two kinds of failure:

- **E1:** failures without side effects.
- **E2:** failures that create side effects inconsistent with the target state.

CoA-v1 raises accuracy from 38.35% to 73.63% relative to SingleAgent, while E2 also rises from 5.19% to 24.15%. E2 accounts for about 92% of CoA-v1 failures. Stronger tool use therefore brings a second concern alongside task completion: changing the environment in the wrong way.

### Plan-induced trajectory inertia

Once a plan is fixed, later tool choices are conditioned on it. If reflection only appends a judgment to the trajectory without invalidating the old `plan`, subsequent actions can still follow that plan. When the error is in the plan itself, reflection alone cannot change the direction of the trajectory.

This suggests two requirements: intercept inappropriate calls before execution, and discard the old plan when a call is rejected.

## Reflection and replanning

DR-CoA (Dual-Reflection CoA) adds reflection before and after each tool call. A rejection before execution requires replanning.

1. **Propose a call.** Store the candidate tool call as `pending_tool`.
2. **Check before execution.** `pre-reflect` checks task and plan alignment, necessity and redundancy, parameter validity, and prerequisites for actions with side effects.
3. **Allow or replan.** An `allow` decision executes the call. A `replan` decision discards `pending_tool`, invalidates the old `plan`, and returns to planning.
4. **Check the outcome.** After execution, `post-reflect` checks whether the observation supports the current plan. If it does not, the system returns to `plan`.

A rejected call commonly exposes an issue in task interpretation, ordering, or dependencies rather than a single bad parameter. Making replanning an explicit state transition is intended to break this trajectory inertia.

## Results on WorkBench

All systems use `deepseek-v4-flash` as the underlying model. DR-CoA-v2 adds phase-specific prompts to the v1 state machine. Acc denotes accuracy; E1 and E2 are the failure categories defined above.

| System | Acc | E1 | E2 |
| --- | ---: | ---: | ---: |
| SingleAgent | 38.35% | 56.46% | 5.19% |
| CoA-v1 | 73.63% | 2.22% | 24.15% |
| DR-CoA-v1 | 84.34% | 2.52% | 13.14% |
| DR-CoA-v2 | **85.03%** | 3.01% | 11.96% |

Compared with CoA-v1, DR-CoA-v2 raises accuracy from 73.63% to 85.03% and lowers E2 from 24.15% to 11.96%.

## Interpretation and limitations

The change cannot be attributed entirely to replanning: DR-CoA also introduces pre- and post-reflection and state constraints, and v2 changes the prompts. This comparison measures the combined system rather than the isolated effect of replanning.

The results support trying a return to `plan` when a proposed action with side effects is judged inappropriate, before patching the existing trajectory.

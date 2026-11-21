---
layout: post
lang: en
title: "Automated Development Workflow with dsh-agent-teams: Implementation, Results, and Issues"
description: "A record of an automated development workflow built with dsh-agent-teams: roles, task contracts, PR boundaries, and the state and scheduling issues exposed after roughly 40 PRs."
tags: [dsh, agent, workflow]
translation_key: agent-teams-workflow
permalink: /2026/11/08/agent-teams-workflow/en.html
summary: >-
  This note documents an automated development workflow built on dsh-agent-teams:
  five roles, task contracts, and PR as the stage boundary. The workflow completed
  roughly 40 PRs and over 100 commits, and exposed state drift and manual
  scheduling; these issues motivated dsh-auto-workflow.
---

This note documents an attempt to build an automated development workflow with `dsh-agent-teams`. The workflow separates requirements, implementation, verification, review, and merging into distinct roles, with GitHub PRs as stage boundaries. It completed roughly 40 PRs and over 100 commits; operation exposed state drift and reliance on manual scheduling. To address these issues, this note introduces the design goals of a new plugin, `dsh-auto-workflow`.

<figure>
  <a href="{{ '/assets/images/blog/agent-teams-workflow-en.svg' | relative_url }}" target="_blank" rel="noopener">
    <img src="{{ '/assets/images/blog/agent-teams-workflow-en.svg' | relative_url }}"
         alt="Automated development workflow with dsh-agent-teams: Requirements, Engineer, Pull Request, Verifier, Reviewer, Merge Queue, and human merge"
         width="1200" height="520">
  </a>
  <figcaption>Figure 1: Automated development workflow with dsh-agent-teams. Requirements, implementation, verification, review, and merging are handled by different roles, with PRs as stage boundaries.</figcaption>
</figure>

## Implementation

`dsh-agent-teams` allows long-running agents to be defined with roles, tools, tasks, and scheduling logic. The workflow uses five roles:

| Role | Responsibility |
| --- | --- |
| Requirements | Turn a request into an executable spec and acceptance criteria |
| Engineer | Implement in an isolated worktree and open a PR |
| Verifier | Run tests and CI against the acceptance criteria, pinned to a specific commit |
| Reviewer | Independently review the code, design, and scope |
| Captain | Coordinate tasks, follow up on PRs, and handle exceptions |

Each task is described as a contract with four fields: the goal states the problem to solve; acceptance defines executable completion criteria; scope limits the files or directories that may be changed; verification lists the commands and CI checks that must run.

A task starts when the Requirements agent submits the spec. The Engineer creates an isolated worktree from the latest `main`, implements the change, and opens a PR. The Verifier runs tests and CI against the PR's acceptance criteria and binds the result to a specific commit. The Reviewer independently reviews the code, design, and scope. Once review passes, the PR enters the merge queue and is merged by a human or Codex.

The workflow enforces the following constraints:

- Each task starts from an isolated worktree created from the latest `main`; no edits are mixed into the main checkout.
- Implementation, verification, and review must be performed by different agents.
- Verification must be pinned to a specific commit and must use real CI results.
- Failed review sends the task back to implementation; verification and review then run again.
- Merge authority stays with a human or Codex; the Captain and members do not merge automatically.

The Captain maintains task state across implementation, verification, review, and merge, and handles conflicts, CI failures, and quota exhaustion.

## Results and Issues

The workflow completed roughly 40 PRs and over 100 commits. The results show that multi-role collaboration and PR boundaries can support real development, but the following issues remain.

First, it is not fully automated. Requirement trade-offs, merge order, conflict resolution, and confidence in verification still require human judgment.

Second, state drifts and operation is unstable. Agents fail, context limits are exceeded, and providers rate-limit. The Captain's context accumulates and drifts, so its state gradually diverges from the repository. Members are removed and re-added because of quota or tooling issues, which forces old tasks to be re-queued. Humans still have to interrupt, correct, and re-establish boundaries.

Third, scheduling depends on humans. Automatic task dispatch is unreliable. After a failure, pause, or member change, tasks must be dispatched again. The Captain effectively becomes a dispatcher.

The common cause is that workflow state depends on the Captain's session context. This motivated `dsh-auto-workflow`, whose goal is to move workflow state, tasks, and scheduling rules out of the Captain session and persist them in the plugin. The plugin is still under development; this note records the results and issues of the previous workflow, not a release announcement for `dsh-auto-workflow`.

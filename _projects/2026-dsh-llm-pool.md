---
show: true
selected: true
group: Engineering
width: 6
date: 2026-11-08
title: dsh-llm-pool
description: A DSH plugin for building configurable model pools from multiple providers — each pool acts as one virtual provider, with session stickiness, load balancing, and pre-first-token failover.
website_url: https://lyingloong.github.io/dsh-llm-pool/
source_url: https://github.com/lyingloong/dsh-llm-pool
---

dsh-llm-pool lets you define multiple model pools from your real providers. Each pool is exposed as a single virtual provider in the model selector, while its members keep their own endpoint, key, and model mapping. Within a pool, sessions stay on one member to reuse the prefix cache, new sessions are balanced by current load, and calls fail over before the first token when a provider hits auth, quota, rate-limit, 5xx, or timeout errors.

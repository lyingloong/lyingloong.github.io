---
show: true
selected: true
group: Engineering
width: 6
date: 2026-11-08
title: dsh-llm-pool
description: A DSH plugin that registers multiple model providers as one unified model pool, with session stickiness, load balancing, and pre-first-token failover.
website_url: https://lyingloong.github.io/dsh-llm-pool/
source_url: https://github.com/lyingloong/dsh-llm-pool
---

dsh-llm-pool turns several real model providers into a single virtual provider. Sessions stay on one member to reuse the prefix cache, new sessions are balanced by current load, and calls fail over to another member before the first token when a provider hits auth, quota, rate-limit, 5xx, or timeout errors.

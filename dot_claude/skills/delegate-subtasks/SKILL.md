---
name: delegate-subtasks
description: Decide what to hand to subagents. Any sub-task that is independent of the work in the main thread and easy to brief — exploration, research, a self-contained change from a clear brief — should be delegated, and independent ones run in parallel. Use when a task splits into parts that could run separately.
user-invocable: true
---

# Delegate sub-tasks

**The test: if a sub-task is independent and easy to brief, delegate it.**

*Independent* means it doesn't need to see the rest of the work to produce its answer, and
the rest of the work doesn't need its answer to carry on. *Easy to brief* means you can
state the goal, the constraints and the shape of the answer you want without
reconstructing the conversation.

Both true → delegate. Both true for several sub-tasks at once → launch them in one
message so they run together.

Apply the test as the work turns up sub-tasks. Don't open a task with a
delegation-planning phase — most tasks show their seams a few steps in, and planning the
split up front costs more than it saves.

## What passes the test

| Sub-task | Handler |
|---|---|
| Find where something lives, or how a pattern is used across the repo | `Explore` |
| Answer a specific question that needs several reads | `Explore` |
| Turn a fuzzy requirement into a concrete plan | `Plan` |
| Build something from a brief you can already write | `general-purpose` |
| Several unrelated questions at once | one message, one agent each |

## What doesn't

- A known file and a known change — read it and edit it.
- One `Grep` or `Glob` answers it.
- The brief would be longer than doing the work.
- It needs back-and-forth with the user.
- You already hold the context in the main thread.

## Conflict decides parallel vs sequential

Two sub-tasks conflict if they edit the same files or the same region, need each other's
output, create the same symbols/routes/config keys, or both start the same long-lived
process.

- Independent → parallel, in a single message with multiple `Agent` calls.
- Conflicting or dependent → sequential, feeding each result into the next brief.

Mixing is normal: two read-only explorations in parallel, then two implementation agents
in sequence because their file sets overlap. Read-only exploration almost never conflicts
— parallel by default. Implementation agents editing nearby code usually do — sequential
unless you've checked the file sets are disjoint.

## Synthesis stays in the main thread

Delegate the work, not the understanding. The main thread reads the reports, reconciles
them and decides. A brief like "based on your findings, implement the fix" hands over the
judgement call along with the labour.

## Briefing an agent

It starts with none of this conversation:

- State the goal, not just the mechanics.
- Give file paths, constraints, and what's already been ruled out.
- Say what form the answer should take ("a list of file paths", "under 200 words").
- For an investigation hand over the question; for a lookup hand over the command.

## Meta

If the user pushes back on over- or under-delegation, save that as a feedback memory and
tune the test here. The goal is to match what they actually want.

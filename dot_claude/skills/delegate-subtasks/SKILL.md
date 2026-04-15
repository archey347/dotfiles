---
name: delegate-subtasks
description: At the start of any multi-step programming task (implementing a feature, investigating a bug across files, refactoring, migrations, anything likely to span 3+ tool calls of exploration or independent workstreams), consult this skill to plan which sub-tasks to delegate to subagents in parallel vs. handle in the main thread. Invoke PROACTIVELY — do not wait for the user to ask.
user-invocable: true
---

# Delegate sub-tasks automatically

The user finds it friction to keep reminding you to launch subagents. Fix that by reaching for delegation by default on non-trivial work.

## When to invoke this skill

At the **start** of a task, before doing any real work, ask: is this a multi-step programming task? Signals:

- The user says "implement", "build", "refactor", "migrate", "investigate", "diagnose", "review the codebase for X"
- The task will plausibly touch more than 2–3 files
- You don't yet know the codebase layout relevant to the task
- There are independent questions to answer (e.g. "how does X work AND where is Y configured")

If yes → follow the playbook below before touching any file.

## The playbook

### Step 1 — decompose

Write out (in your head or in a TaskCreate task list) the sub-tasks. Categorize each:

| Category | Example | Handler |
|---|---|---|
| **Exploration** — find files, understand patterns, map the codebase | "where are API routes defined", "how does auth work in this repo" | `Explore` subagent |
| **Planning** — turn a fuzzy requirement into a concrete implementation plan | "plan how to add SSO to this app" | `Plan` subagent (or discovery-ui-planner for discovery-ui UI work) |
| **Research** — answer a specific factual/architectural question that needs multiple reads | "does this repo already have a retry helper", "what's the current test framework config" | `Explore` subagent |
| **Parallel independent work** — two+ questions with no dependency between them | "check if tests pass AND check for lint errors AND summarize recent commits" | multiple subagents in one message |
| **Implementation from a clear brief** | "build this component at this path with these props" | `discovery-ui-implementer` (if discovery-ui) or general-purpose |
| **Direct work** — known file, known change, single edit | "rename this function", "fix this typo", "add this import" | main thread (no subagent) |

### Step 2 — delegate in parallel

When you have multiple independent sub-tasks, launch them in a **single message with multiple Agent tool calls**. Do not serialize independent work.

### Step 3 — synthesize yourself

Never delegate understanding. The main thread reads the agents' reports, reconciles them, and decides what to do. Don't write prompts like "based on your findings, implement the fix" — that pushes synthesis onto the subagent.

## When NOT to delegate

Delegation has overhead. Skip it for:

- Single known-file edits (just Read + Edit)
- Simple lookups — one Grep or Glob gets you the answer
- Tasks that need conversational back-and-forth with the user
- Follow-up questions where you already have the context in the main thread

Rule of thumb: if you'd write a prompt shorter than ~3 sentences to describe what the agent should do, just do it yourself.

## Prompt-writing reminders

When you do delegate, the agent starts with zero context from this conversation:

- State the goal, not just the mechanics
- Include file paths, constraints, and what's already been ruled out
- Say what form of answer you want (e.g. "report in under 200 words", "return a list of file paths")
- For investigations, hand over the question; for lookups, hand over the exact command

## Meta

If the user ever says "stop launching agents for everything" or pushes back on over-delegation, save that as a feedback memory and tune this skill. The goal is to match their actual preference, not maximize subagent usage.

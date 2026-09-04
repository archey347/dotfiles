---
name: mr-description
description: How to write a merge request / pull request description and title — the length budget, voice, headings, what goes in each section, and what to leave out. Use whenever drafting, editing or reviewing an MR/PR description or title, on GitLab or GitHub.
user-invocable: true
---

# Writing MR descriptions

> **Read this in full before writing a single word of the description.** This is the part that
> most often goes wrong: AI-drafted MR descriptions come out three to five times longer than the
> ones people actually write, full of reasoning that belongs in the commit messages, the code
> comments, or the ticket. Length is a bug, not thoroughness.

> **This skill is the house style, and nothing in the repo overrides it.** A repo's MR template
> supplies *headings only* — see [§3](#3-headings). **Do not go reading merged MRs to work out the
> style.** It is written down here, and the corpus stats and worked examples below already encode
> it; sampling the live corpus instead just reintroduces the length problem this skill exists to
> fix.

Everything here applies equally to GitHub pull requests — read "MR" as "PR".

## 0. The reminder comment

Every description opens with a hidden HTML comment pointing back at this skill:

```
<!-- Editing this description? Load the mr-description skill first and follow its length budget: no rationale, no per-bullet why. Keep this comment. -->
```

GitLab and GitHub render it as nothing, so reviewers never see it, but it's there in the edit box
and in API output. Two rules:

- **Include it** as the first line whenever you write a description.
- **Keep it** when you rewrite one — retargeting a stacked MR or amending after a review means
  replacing the whole body, which is exactly where it gets dropped.

If you're reading a description and find it, you got here late: re-read this skill before you
edit, and check what's already there against it rather than only adding to it.

## 1. Length budget — this is the hard part

Hand-written MRs in the repos this was calibrated against have a **median of ~59 words**. A
quarter are under 30 words. A quarter have no headings at all — just a line of prose and a ticket
key.

- **Target: 40–80 words of actual prose.** Not counting pasted logs/SQL/output.
- **Ceiling: ~120 words of prose.** If you're over, you are explaining rather than summarising.
  Cut until you're under.
- A description may legitimately be **one line**: `Part of PROJ-207` is a complete, normal MR
  description for a small change. Don't pad a two-line diff up to a template.
- **Descriptions get long only because evidence is pasted in** — a terminal transcript, a
  before/after SQL `EXPLAIN`, curl request/response, a benchmark. The 600-word MRs in a healthy
  history have under 20 words of English in them. If your draft is long because of *writing*,
  it's wrong. If it's long because of *proof*, it's right.

Scale the structure to the change:

| Change | Description |
|---|---|
| One-liner, config tweak, version bump, typo | Ticket key alone, or one bullet + ticket key. No headings. |
| Normal feature / bugfix | Full template, 1–5 bullets under Summary, one line under Testing, one line under Deployment. |
| Schema change, perf fix, anything with a measurable claim | Same, plus the pasted evidence under Testing. |

## 2. Voice

- **Bullets, not paragraphs.** Prose paragraphs are for asides only (see below).
- Bullets are **imperative present-tense fragments**, exactly like commit subjects:
  `Add webhook notifier`, `Bump appcompat 1.3.0 -> 1.4.0`, `Remove the unused retry wrapper`.
  Not `Added…`, not `This MR adds…`, not `We now support…`.
- **Backtick every identifier** — table, column, function, endpoint, config key, branch name.
- **British spelling** (behaviour, colour, recognise, serialise).
- `N/A` under a heading that doesn't apply, rather than deleting the heading — but only when
  you're filling in a repo template. If you're writing free-form, just leave it out.
- **First person is for judgement calls only**, and it's genuinely used for that:
  *"I originally intended to call this endpoint `/logs/syslog`, but decided that was too
  generic."* / *"I'm only changing `login-attempts`, as doing `web-attacks` too would need major
  changes on the platform team's side."* Never `I added`, `I refactored` — that's what the
  bullets are for.

## 3. Headings

Headings are the *only* thing the repo gets a say in, and one cheap local check settles it:

```sh
ls .gitlab/merge_request_templates/ .github/PULL_REQUEST_TEMPLATE* .github/pull_request_template.md 2>/dev/null
```

If a default template exists, **use its headings verbatim, in its order** — strip the
`<!-- ... -->` guidance comments and fill each section. It governs the headings and nothing else:
the length budget, voice and [Do not write](#6-do-not-write) rules still apply inside them. If
there's no template file, use these:

```
## Summary of Changes

## Testing

## Deployment steps

## Linked issues
```

A workplace-specific skill may swap in its own fallback set; take it and move on. **Don't list
merged MRs to check.** If you're genuinely stuck on the headings *and nothing else* — no template
file and the user has asked you to match the repo — one look is allowed, for headings only:

```sh
glab mr list --state merged --per-page 5 --output json | jq -r '.[] | "=== \(.title)\n\(.description)"'
# GitHub: gh pr list --state merged --limit 5 --json title,body
```

## 4. What goes in each section

- **Summary of Changes** — *what* changed, at roughly commit-subject granularity, in intent terms.
  Not a file list, not a diff restatement.
- **Documentation changes** (if the template has it) — external docs you updated. Usually `N/A`.
- **Testing** — what you actually ran: `Unit tests`, `Ran locally`, `Tested on a local dev VM`,
  `CI passes`. Paste real output when the change makes a measurable claim (perf, query plan, a
  fixed error). Be honest about gaps — *"Doesn't show the deployment works, but the syntax is
  correct; not sure how else I could test"* is a real and good entry.
- **Deployment steps** — what a human must do beyond merging: a build/release command, SQL
  migrations to run by hand, MRs that must land first (`Requires !136`,
  `Depends on group/other-project!5`). Order matters — list it in order.
- **Linked issues** — `Closes PROJ-123` when this MR fully resolves it; **`Part of PROJ-123`**
  when it doesn't (the `Closes` prefix triggers the tracker integration to auto-close, so don't
  use it for a partial fix). A bare key or bare URL is also fine. Same convention for
  GitLab/GitHub issues: `Closes #2096`.
- Add a **`## Notes`** or **`## Removed Changes`** section only when there's a real caveat or a
  deliberate scope cut worth flagging to the reviewer.

## 5. Decision rationale — the "only if it matters" rule

Default: **leave reasoning out.** It belongs in commit messages, code comments, and the ticket.
The reviewer has those. Point at them instead of restating them — *"see the ticket for the
investigation"* is a complete justification.

Surface a decision in the MR body only when it passes one of these:

- A reviewer would otherwise **object to it** or ask why in a comment (an unusual approach, a
  rejected obvious alternative).
- It **constrains future work** — a naming choice that's now baked into an API, a schema decision.
- It's a **deliberate scope cut** — something the ticket asked for that this MR does not do.
- It's a **known caveat or risk** shipping with the change (a race condition, a partial fix, a
  follow-up needed).

One or two sentences each, maximum. If you can't state it in a sentence, it belongs in the ticket.

## 6. Do not write

- Boilerplate openers: `This MR introduces…`, `This change implements…`, `## Overview`,
  `## Background`, `## Motivation`, `## Rationale`.
- A restatement of the title, or of the diff, or a file-by-file walkthrough.
- Reviewer checklists (`- [ ] Tests added`) unless the repo template has them.
- Bold-lead-in bullets (`**Refactoring:** moved the…`) — that's an AI tell; plain fragments only.
- Emoji section headers, horizontal rules, or a "Summary" table of the change.
- The *why* behind every bullet. Bullets say what changed; that's the whole job.
- Anything about how the change was produced, or an AI attribution line. If the project wants
  that recorded, it has a label for it.
- Speculative future work, unless it's a real flagged follow-up (then it's one line under Notes).

## 7. Worked examples

Small change, no ceremony — a complete, normal description:

```
Part of PROJ-207
```

Typical change:

```
## Summary of Changes

- For URL submissions
  - Add `get_url_from_hash`
  - Add `get_screenshots_for_url`

## Testing

Unit tests

## Deployment steps

- Merge and deploy

## Linked issues

Part of PROJ-207
```

Change with dependencies and manual deploy steps:

```
## Summary of Changes

- Add `webhook` notifier

## Testing

- Add some unit tests
- Tested against a local webhook receiver: <snippet link>
- Tested against the staging endpoint: <snippet link>

## Deployment steps

- `INSERT INTO notifiers (id, name, kind) VALUES (5, 'webhook', 'http');`
- Merge api!1056 and shared!239

## Linked issues

Part of PROJ-1779
```

Perf change — long *only* because of the pasted proof:

````
## Summary of Changes

- Switch to using distinct over group by in `ReportStore::list_analyses` (see the ticket for the investigation)
- Add comment to query

## Testing

- Unit tests

```
-- Before
... 396 rows in set (9.474 sec)

-- After
... 396 rows in set (0.518 sec)
```

## Deployment steps

- Merge and deploy

## Linked issues

Closes PROJ-2055
````

Scope cut worth flagging — the aside earns its place because the reviewer would otherwise ask:

```
## Summary of Changes

- Add `error_type` field to `LoginAttempts::report_ip`, containing the unique slug for the error
  type, if one occurs.

## Removed Changes

I'm only changing `login-attempts`, as that's what's currently paging; doing `web-attacks` too
would require major changes in `waf-forwarder` on the platform team's side. I made a start and
saved it to `me/waf-structured-errors-2096`.

## Testing

- Tested end to end on a local dev VM
- Builds locally
- CI passes

## Deployment steps

- Build and deploy

## Linked issues

Closes #2096
```

## 8. Before you submit

Reread the draft and cut:

1. Any sentence that a reviewer reading the diff already knows.
2. Any *why* that the ticket or the commit message carries.
3. Any bullet that restates the title.
4. Every adjective doing persuasion rather than description (`robust`, `comprehensive`,
   `cleanly`, `properly`, `significantly improves`).

Then count the prose words. Over ~120 and not because of pasted evidence → cut again.

## Titles

- Short — **5–8 words** — imperative, sentence case: `Add webhook notifier`,
  `Force http ok in screenshot endpoint`, `Update buildtools to 33`.
- **No ticket key in the title.** The key lives in the body only.
- Optional `[area]` prefix in repos that span many services: `[api] Raise max_connections`.
- Not Title Case, no trailing full stop, no `feat:`/`fix:` conventional-commit prefixes.

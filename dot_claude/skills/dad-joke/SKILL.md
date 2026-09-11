---
name: dad-joke
description: Generate a single original, safe-for-work, really bad dad joke. Use when the user or another skill asks for a dad joke (e.g. to include in a standup update).
---

# Dad-joke generator

Seed words: !`shuf -n2 /usr/share/dict/words | paste -sd ', '`

Recent jokes (avoid reusing their themes, pivot words, or sentence structures):
!`tail -n 30 /home/archey/.claude/skills/dad-joke/history.log 2>/dev/null || echo "(none yet)"`

**Always delegate joke generation to a subagent** via the Agent tool (`subagent_type: "general-purpose"`). Do not write the joke yourself in the main thread.

Prompt the subagent with exactly this, substituting the seed words and recent-jokes list above:

> Read the full guidance at `/home/archey/.claude/skills/dad-joke/GUIDANCE.md` and follow it to generate a dad joke. Seed words: `<seeds>`. Avoid reusing themes, pivot words, or sentence structures from these recent jokes: `<recent jokes>`. Return **only** the joke text — no preamble, no commentary, no quotes, no markdown.

Relay the subagent's returned joke text verbatim to the user. Do not add commentary.

After relaying, append the joke to `/home/archey/.claude/skills/dad-joke/history.log` as a single line using Bash with a heredoc to handle any quotes safely, e.g. `cat >> /home/archey/.claude/skills/dad-joke/history.log <<'EOF'` followed by the joke and `EOF`.

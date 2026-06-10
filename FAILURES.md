# product-master-data-model — Failure Log

What was attempted that didn't work, why it didn't work, and what was
tried next.

Lower bar than DECISIONS.md — capture failures even when they didn't
produce a durable rule. The whole point: future-you (or future-Claude)
shouldn't re-attempt dead ends because the lesson got lost.

---

## Format

### YYYY-MM-DD — [One-line failure description]

**Attempted:** [What was tried]

**Why it didn't work:** [Concrete reason, not "it broke." If the
failure mode was technical, name the specific issue. If the failure
mode was scope or approach, name that.]

**What we tried instead:** [The next attempt, which may also have
failed and may have its own entry below]

**Status:** Resolved / open / abandoned

**Tags:** [keywords for future text-search — e.g., "rendering, pandoc,
quarto" or "scope, scrollytelling, decoration"]

---

## Entries

### 2026-06-10 — Copy-Item sent through Bash tool fails (PowerShell commands need PowerShell tool)

**Attempted:** Used the Bash tool to run `Copy-Item` (PowerShell cmdlet) to copy slash-command files into `.claude/commands/`.

**Why it didn't work:** The Bash tool runs `/usr/bin/bash`, not PowerShell. `Copy-Item` is not a bash command and returns "command not found."

**What we tried instead:** Switched to the PowerShell tool — worked immediately.

**Status:** Resolved

**Tags:** powershell, bash, copy, tool-selection, windows

---

### 2026-06-10 — Global .gitignore excludes .claude/ — breaks slash command tracking

**Attempted:** Staged `.claude/commands/` as part of the initial project commit.

**Why it didn't work:** `~/.gitignore` contains `.claude/` to exclude Claude Code session artifacts from all repos. This prevented the slash commands from being committed.

**What we tried instead:** Added negation rules to the project-level `.gitignore`:
```
!.claude/
!.claude/commands/
!.claude/commands/*.md
```
This overrides the global ignore for this specific project. Worked correctly.

**Status:** Resolved

**Tags:** gitignore, global-gitignore, .claude, slash-commands, windows, init

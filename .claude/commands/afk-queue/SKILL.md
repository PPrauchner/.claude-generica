---
name: afk-queue
description: Work through a queue of AFK-ready issues unattended, implementing each one in an isolated subagent that starts with a clean context — so nothing from one issue leaks into the next and the orchestrating session never accumulates unrelated history. Use when the user has several issues ready to implement and wants them worked through one at a time (or in parallel via worktrees), e.g. "implement these 4 issues", "work through the ready-for-agent queue".
---

# AFK Queue

Runs a batch of issues to completion, one clean-context subagent per issue, so the
orchestrating session's history never grows past a single issue's worth of work.

The issue tracker must already be configured (`docs/agents/issue-tracker.md`) — if it
isn't, stop and tell the user to run `/setup-matt-pocock-skills`. Every issue is driven
through the issue-based skills (`/start-issue`, `/commit`), so there is no trackerless
mode.

## 1. Resolve the queue

- If the user passed issue references (numbers, URLs, or `#id`) as arguments, use
  exactly those, in the given order.
- Otherwise, query the tracker for open issues in the `ready-for-agent` state (see
  `docs/agents/triage-labels.md`), oldest first. If none exist, say so and stop —
  don't invent work.

## 2. Confirm before starting

This kicks off multiple unattended implementation runs — confirm once, up front,
not per issue. Show the resolved queue (issue #, title), the execution mode
(sequential by default — see [Parallel mode](#parallel-mode) below), and that each
issue ends in a **local commit only** (no push, no PR, nothing force/amended).
Wait for a go-ahead.

## 3. Work the queue

For each issue, in order:

1. Fetch its full body, comments, and any existing "Agent Brief" comment (posted by
   `/triage`).
2. Build a self-contained prompt from the template in [BRIEF.md](BRIEF.md) — fill in
   the issue content directly; the subagent has no access to this conversation.
   The brief has the subagent implement by driving `/start-issue` → `/tdd` →
   `/commit`, the same pipeline used interactively, with an explicit override for
   their "wait for confirmation" checkpoints (see BRIEF.md for exactly which
   checkpoints auto-approve vs. which are real blockers).
3. Spawn it with the `Agent` tool, `subagent_type: general-purpose`.
   - **Sequential (default):** `run_in_background: false` — wait for it to finish
     before starting the next issue, since they share a working tree.
   - **Parallel (opt-in):** see [Parallel mode](#parallel-mode).
4. Take only the subagent's final report as output — do not pull its transcript or
   intermediate tool calls into your own context. That report *is* the handoff;
   there is nothing else to compact or clear.
5. If the report says blocked, record why and move on to the next issue. Never spend
   your own context trying to unblock it — that judgment call belongs to the user.
6. **Sequential only — leave a clean tree before the next issue.** Run `git status`;
   if it isn't clean (a blocked or partial subagent left uncommitted work),
   `git stash push -u -m "afk-queue: #<N> <status>"` and record the stash ref in that
   issue's row of the report. Never start an issue on a dirty tree — that is how one
   issue's changes leak into the next one's commit.

## 4. Report

After the queue drains, present one table: issue, status (done / blocked /
partial), commit hash(es) or stash ref, one-line notes. Call out every
blocked/partial issue by name so the user can triage them.

Then — and only then — offer to run `/open-pr`, which pushes the branch, opens one PR
for the whole batch (its `Closes #N` footers are already in the commits) and moves
those issues to *In review*. **You** ask this, once, after the queue drains: the
subagents run unattended and have no one to ask, which is why they never push.
If the user declines, stop; the commits stay local.

## Parallel mode

Only when the user confirms the queued issues touch disjoint parts of the codebase
(no shared files, no ordering dependency). Spawn each subagent with
`isolation: "worktree"` and `run_in_background: true`, all in one message; each gets
its own branch and working copy. The brief pins every subagent to its own working
tree; the first time you use this mode in a repo, run a single issue through it to
confirm the worktree isolation holds before trusting a batch of N. When all finish,
list the resulting branches/worktree paths instead of commit hashes — the user
reviews and merges each independently.

## Out of scope

- No auto-push, no auto-PR, no auto-merge — always a human decision. Subagents never
  do any of it; the orchestrator only *offers* `/open-pr` at the end (step 4), and
  only after the user says yes.
- Doesn't create branches. All sequential-mode issues land on whatever branch is
  checked out, which is what makes a batch become a single multi-issue PR. Create the
  branch before invoking if you don't want the batch on your current one.
- No cross-issue resumability state file — if the batch is interrupted, re-invoke
  with the remaining issue numbers explicitly; recovery of any partial work is manual
  (check `git log` and `git stash list`).
- Doesn't decide `ready-for-agent` vs `ready-for-human` — that's `/triage`'s job.
  If an issue turns out not to be AFK-safe, the subagent should report blocked, not
  guess.

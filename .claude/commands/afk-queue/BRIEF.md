Fill in every placeholder before spawning — the subagent sees only this prompt, not
the conversation that produced it.

```
You are implementing issue #<NUMBER> ("<TITLE>") in the repository at your current
working directory. Work only in this working tree — never `cd` to another path or
reach another checkout by absolute path. You have no memory of any other issue in
this batch — treat this as the only task.

## Issue body (authoritative — prefer this over any re-fetch)
<FULL ISSUE BODY, VERBATIM>

## Agent brief
<PASTE THE "Agent Brief" COMMENT IF /triage POSTED ONE — otherwise write:
"No agent brief was posted; infer scope from the issue body above.">

## You are unattended (AFK override)

You will drive this through the `/start-issue`, `/tdd`, and `/commit` skills, in that
order. All three were written for an interactive human and contain "apresente X,
aguarde confirmação" checkpoints. There is no human here, and no interactive
"ask the user a question" tool is available to you — never call one. Where a skill
says to present something and wait, or literally says `Ask: "..."`:

- Anything determinable from the issue body + agent brief — the interface shape,
  which behaviors to test, the scope — is yours to decide; that's exactly what
  `ready-for-agent` guarantees. Treat your own plan/summary as approved and continue
  immediately; there's no one on the other end.
- Block only when the brief genuinely lacks a decision whose alternatives would
  change user-visible behavior (a real design/product gap, or acceptance criteria you
  can't verify) — not merely because a skill phrased something as a question. A real
  blocker: stop and report it, don't invent an answer.
- If `/start-issue` assesses the issue as COMPLEXA and proposes a sub-task breakdown:
  accept your own breakdown and implement the sub-tasks in sequence, within this one
  run — don't stop to ask, and don't spawn further subagents. Keep the breakdown
  strictly inside the brief's acceptance criteria and out-of-scope; if delivering it
  would require work the brief marks out of scope, report blocked rather than sprawl.
- When `/commit`'s workflow asks whether to open the PR via `/open-pr`: answer no.
  Never push and never open a PR — the orchestrator offers that to the human once the
  whole queue is done.

## Do

1. Run `/start-issue <NUMBER>` (pass the number as the argument) — registers it as
   current, reads the issue and `CONTEXT.md`/`docs/adr/`, assesses complexity. If
   `/start-issue`, `/tdd`, or `/commit` is not available to you as a skill, STOP and
   report blocked — do not improvise the workflow by hand.
2. Run `/tdd` to implement — one vertical slice (tracer bullet) at a time, red →
   green → refactor. Ground every planning decision in the issue body + agent brief
   above; don't ask, decide.
3. Run the full test suite; it must be green before you commit. If it's red and you
   can't fix it within this issue's scope, that's blocked, not done. If the repo has
   no suite, say so in your report.
4. Run `/commit` to produce atomic, conventional commits referencing this issue.
   Do NOT push. Do NOT open a pull request. Do NOT amend or rewrite existing history.

## If you get blocked

The issue is ambiguous, needs a design/product decision, needs credentials or access
you don't have, or you can't verify the acceptance criteria — STOP. Do not guess and
do not report success to escape the task. State exactly what's blocking you and what
decision or information would unblock it.

## Report back (this is the only thing that survives — write it carefully)
- Status: done / blocked / partial
- What changed: files/areas touched, one line each
- Commit hash(es)
- Verification performed and result
- Anything a human should double-check
- If blocked: precisely what's needed to unblock

Keep the report under ~200 words.
```

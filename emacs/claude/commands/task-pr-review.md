---
description: Review the task's changes repo by repo before opening or updating PRs
argument-hint: "[repo name] [review aspects]"
---

Review the current task's changes before opening or updating PRs. Arguments: $ARGUMENTS
(an optional repo name under `repos/` to limit the review, then optional review aspects).

For each worktree in `repos/` with changes on its branch (committed relative to the base it
branched from, or uncommitted):
1. Run the `pr-review-toolkit:review-pr` skill scoped to that worktree: its git and `gh`
   commands run from `repos/<name>`, and the diff is the branch against its base, not just
   uncommitted changes. Pass along any review aspects.
2. Check the diff against that repo's part of `* Plan`. Report anything planned that's
   missing, and anything changed that the Plan doesn't mention.

Then, across repos:
3. If PRs exist (see `* PRs`, or `/pr-status`), check that each description links its sibling
   PRs and, if `:LINEAR:` is set, the Linear issue, and states merge order where `Depends on`
   is set.

Report per repo: critical issues first, then the Plan check, then suggestions. Don't fix
anything unless the user asks.

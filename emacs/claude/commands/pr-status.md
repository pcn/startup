---
description: Refresh the task's PRs table from GitHub and flag merge-order problems
---

Refresh `* PRs` in the current task's `task.org`.

For each worktree in `repos/` (skip symlinked live checkouts unless the PRs table lists them),
find the PR for its current branch: `gh pr view --json number,url,state,isDraft,reviewDecision,mergeable,statusCheckRollup`
run from that worktree. A branch with no PR gets "no PR".

Rewrite the table rows: Repo, PR (as an org link `[[url][#N]]`), Status (draft / open, review
state, checks passing or failing / merged / closed), and Depends on (keep what's there unless
it's clearly wrong). Then flag merge-order problems: a PR that is ready or merged while
something it depends on isn't, or dependencies that aren't mentioned in the PR descriptions.

Log a status change (opened, approved, merged, checks failing) with `worklog_add`, one entry
per change. Don't log when nothing changed.

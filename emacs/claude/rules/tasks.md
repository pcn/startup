# Task workspaces

Work tasks live in `~/dvcs/netlify/tasks/<id>/` (in the container: `/home/pcn/netlify/tasks/<id>/`).
IDs: a Linear identifier (`ENG-123`), or `inc-YYYYMMDD-slug` / `adhoc-YYYYMMDD-slug` for work without an issue.

Personal tasks (`:TYPE: personal`) live in `~/dvcs/pcn/tasks/<id>/`, outside the container's view,
so `cx` can't reach them. IDs: `YYYYMMDD-slug`, created with `task new <id> --type personal`. Bare
repo names given to `task add-repo` resolve under `~/dvcs/pcn`. Netlify-specific rules (Linear,
Slack, `cx`) don't apply to them unless the task says so. Ids are unique across both roots, and
every other `task` subcommand finds a task in either root.

## Layout
- `task.org` is the source of truth: Context, Plan, PRs, Threads, Decisions, Log. Durable information
  goes there; the chat transcript is disposable.
- `repos/` holds git worktrees (or links to live checkouts) of separate repos, each possibly
  with its own CLAUDE.md. The task directory itself is a small git repo for task.org and the
  platypus scaffold; it ignores `repos/`.
- Repos are added and removed with the `task` CLI (`task add-repo`, `task drop-repo`). Don't run
  `git worktree` by hand in a task directory.

## Working in a task
- Read `task.org` first. Follow its Plan; if the work needs to deviate, propose a Plan change before doing it.
- Keep the Plan and PRs sections current as things change (edits via the Edit tool, like any file).
- Record decisions and their reasons under Decisions.

## Logging milestones
Log with the `worklog_add` tool (emacs-tools MCP server; arguments: one-line `summary`, optional
`task_id` that defaults to the session's task, optional `detail`).
It writes a timestamped entry under today's date in the task's Log, and the user's yearly log
links that day to the task's entries: "Netlify Work <year> Log" for work tasks, "<year> - Personal
Log" for personal ones. Log when:
- a plan is agreed,
- a repo is added or dropped,
- a PR is opened or changes status,
- a finding is confirmed (incidents, investigations),
- you are blocked on something or someone,
- work stops for the day.

Keep summaries to one line, past tense, specific ("Opened PR #412 in ksg-cli for the cache flag").
If the tool isn't available, say so and give the user the line to log; don't write to the daily file directly.
---
description: Fill a task's Context and agree its Plan, then add the repos it needs
argument-hint: "[extra context]"
---

Plan the current task. The task is the directory holding `task.org` at or above the working
directory; its name is the task id. Extra context from the user: $ARGUMENTS

1. Read `task.org`. If `:LINEAR:` is set, fetch that issue and its comments with the Linear
   tools (`get_issue`, `list_comments`), including its suggested git branch name.
2. Fill `* Context`: acceptance criteria, the issue description in brief, comments that matter,
   links. For an incident: symptom, start time, impact. Keep it short; link rather than copy.
3. Draft `* Plan`: per-repo changes, the order to do them in, PR dependencies, and open
   questions. Show it, then ask questions until the user agrees. Don't add repos or start
   changes before then.
4. Ask which repos to add. For each, run `task add-repo <task-id> <repo> --branch <branch>`,
   using Linear's suggested branch for Linear tasks (omit `--branch` otherwise). Use
   `--link` only for repos whose live checkout must change (dotfiles and the like).
5. Log "Plan agreed: <one-line gist>" with `worklog_add`.

Edit `task.org` with the Edit tool, one section per edit.

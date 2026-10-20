# Working rules (all repos and tasks)

## Explain, then edit
- Before each edit, say in a sentence or two what is changing and why. After a batch of edits, summarize what changed.
- Change files only with the Edit/Write tools, so every change shows up in ediff for review. Never modify files with `sed -i`, heredocs, `tee`, redirection, or scripts.
- Make one logical change per edit. If the user rejects an edit, skip that change and continue with the next one.

## Things that always need explicit approval
- Never `git commit` or `git push`. The user reviews and commits.
- Never post, comment, or change status in Linear or Slack without approval of the exact text.
- Never mark a platypus backlog item or task complete (`complete_backlog_item`, `complete_worker_task`, `finish_work`). Report that it looks done and let the user decide.

## Where commands run
See @rules/commands.md. Short version: `tailscale ssh` runs on the host; gcloud, aws, okta, and kubectl run in the dev container via `cx …`, never directly on the host.

## Tasks
If a `task.org` exists in the working directory or a parent, read it before doing anything else and follow its Plan. Details: @rules/tasks.md.

## Netlify conventions
@rules/netlify-conventions.md

## Pull requests
Before opening any PR, run `/task-pr-review` (in a task) or `/pr-review-toolkit:review-pr` (outside one).
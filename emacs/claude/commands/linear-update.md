---
description: Draft a Linear comment or status change for the task; post only after approval
argument-hint: "[what to focus on]"
---

Draft an update for the current task's Linear issue (`:LINEAR:` in `task.org`; if it's empty,
say so and stop). Focus, if given: $ARGUMENTS

1. Read `* Plan`, `* PRs`, and the `* Log` entries since the last update. Read the issue and its
   recent comments with the Linear tools so you don't repeat what's already there.
2. Draft a short comment: what's done (with PR links), what's next, and blockers or questions.
   If the work warrants a status change (e.g. In Progress -> In Review), propose it separately.
3. Show the exact comment text and any status change, and wait. Post only what the user
   approves, word for word (`save_comment`; `save_issue` for status). If they edit it, show the
   final text again before posting.
4. After posting, log "Posted Linear update: <gist>" with `worklog_add`.

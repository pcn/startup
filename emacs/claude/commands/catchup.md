---
description: Catch up on the task's tracked threads since they were last read
---

Catch up on every heading in `* Threads` of the current task's `task.org`.

For each one, read only what is newer than its `:LAST_READ:`:
- Slack: `slack_read_thread` with `oldest` set to `:LAST_READ:` (skip the message at exactly
  that ts).
- incident.io: `incident_update_list` and `incident_show`, keeping updates after `:LAST_READ:`.

If nothing is new, say so in one line. Otherwise summarize decisions, questions or asks aimed
at the user, and changes in plan or status. Then:
1. Log anything that changes the task with `worklog_add` (one entry per real change, not per
   thread).
2. Update the thread's one-line summary if its state changed, and set `:LAST_READ:` to the
   newest item read.

If a source can't be read, say which and leave its `:LAST_READ:` alone. End with a short
"Things that need you" list, or "Nothing needs you."

---
description: Track a Slack thread or incident record in the task's Threads
argument-hint: "<slack permalink | incident id or URL>"
---

Add $ARGUMENTS to `* Threads` in the current task's `task.org`.

**Slack permalink** (`https://<ws>.slack.com/archives/<channel>/p<digits>[?thread_ts=<ts>]`):
the channel id is the path segment after `archives/`. The parent ts is `thread_ts` if present,
otherwise the `p` digits with a dot before the last six (`p1792017294316769` ->
`1792017294.316769`). Read it with `slack_read_thread`. If Slack isn't available or the read
fails, ask the user to paste the thread.

**Incident** (incident.io id or URL): read it with the incident.io tools (`incident_show`, and
`incident_update_list` for updates).

Add one heading per thread, under `* Threads`:

```org
** <short title>
   :PROPERTIES:
   :URL:       <permalink or incident URL>
   :LAST_READ: <ts of the newest message read, or the newest update's timestamp>
   :END:
   <one-line summary: what it's about and where it stands>
```

If the URL is already there, say so and stop. Then log "Tracking thread: <short title>" with
`worklog_add`.

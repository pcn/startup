# Claude Code permission profiles

How a Claude session in a task starts. `my/task-open` (task-workflow.el) asks which profile to
use when it starts a session, merges `common.json` with the profile's file, and passes the
result as `--settings`, along with `--permission-mode`:

| Profile     | Mode    | Adds to common.json                                         |
|-------------|---------|-------------------------------------------------------------|
| plan        | plan    | nothing                                                     |
| investigate | default | read-only cloud queries through `cx` (aws, gcloud, kubectl) |
| implement   | default | test, lint and validate commands that don't rewrite files   |

`common.json`: GitHub reads, `task list`, read-only Linear/Slack/incident.io/Datadog/CircleCI
MCP tools; denies `git commit`/`git push`; always asks before platypus completion.

Rules worth knowing (Claude Code permissions docs):
- `*` matches any text, including spaces. Keep it at the end of a rule, after a fixed service and
  verb: `cx aws * describe-*` would also match `cx aws ec2 terminate-instances ... describe-x`.
- Compound commands are split on `&&`, `||`, `;`, `|`; every part must match a rule.
- Deny and ask beat allow, from any settings file. Built-in read-only commands (ls, grep, git
  reads, ...) never prompt.
- Nothing here allows Edit/Write, so every file edit prompts and shows in ediff. Commands that
  rewrite files (`make fmt`, `--fix`) are left out on purpose for the same reason.

Outside Emacs: `claude --permission-mode default --settings "$(jq -s '{permissions: {allow: (map(.permissions.allow // []) | add), ask: (map(.permissions.ask // []) | add), deny: (map(.permissions.deny // []) | add)}}' common.json investigate.json)"`.

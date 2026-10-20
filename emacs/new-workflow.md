# Task-centric Claude Code + Emacs workflow: implementation plan

This document is a brief for a Claude Code session. It describes a workflow the user has designed and the phases to implement it. Work phase by phase. At the start of each phase, inspect the user's existing setup (Emacs config, `~/.claude/`, shell scripts, container setup, and their existing "platypus" task tooling) before changing anything. Follow the user's existing conventions over the examples here. Show diffs for every edit and do not commit. The user reviews and commits.

## Environment facts

- Host: Linux + Docker. Emacs, Claude Code, git worktrees, and `tailscale ssh` run on the host.
- A persistent dev container mounts the user's main work directory. gcloud, aws, and Okta auth live inside it. A wrapper already exists for running container commands from the host (find it; it is referred to here as `cx`).
- Emacs frontend: `claude-code-ide.el` (keep it). Diff review happens in ediff and must keep working.
- Perspectives: the user uses Emacs perspectives (identify whether persp-mode or perspective.el).
- Daily log: org-roam dailies.
- Task state between Claude sessions: the user's existing "platypus" task tooling. Integrate with it, don't replace it. Ask the user how it stores state before wiring it in.
- Issue tracker: Linear. Ad-hoc work (incidents, "is there an incident?" investigations) often has no Linear issue.
- Slack: threads are a major source of context. Slack MCP availability is unknown and may need org approval.

## Design principles

1. The unit of work is a task, not a repo. One task = one directory, one `task.org`, one perspective, one named Claude session.
2. Task directories start bare. Repos are added as git worktrees when needed and removed when done.
3. `task.org` is the shared state between the user and Claude. Anything durable goes there; the chat transcript is disposable.
4. The daily work log is derived, not written. Claude logs milestones to the task, and each log entry also produces a one-line linked entry in the org-roam daily.
5. Diffs are visible by default. No `acceptEdits` default, no edits via shell. Plan mode for design, default mode for implementation.
6. Cross-repo rules live centrally in `~/.claude/`. Repeatable procedures are slash commands, not prose.

## Target layout

Put the tasks root inside the container-mounted work directory, so container commands can see worktrees at the same paths. Make it configurable; confirm the path with the user.

```
$TASKS_ROOT/
  ENG-123/                    # Linear issue ID
    task.org                  # org-roam node; source of truth
    CLAUDE.md                 # thin: points at task.org
    .task                     # project.el root marker
    service-a/                # worktree, branch from Linear's suggested branch name
    infra/                    # worktree
  inc-20261014-msk-lag/       # incident / investigation, may stay bare
  adhoc-20261014-slug/        # other ad-hoc work
  .archive/                   # closed tasks (task.org kept; worktrees removed)
```

ID conventions: Linear tasks use the issue identifier. Ad-hoc tasks use `inc-YYYYMMDD-slug` or `adhoc-YYYYMMDD-slug`.

---

## Phase 1: Central Claude Code configuration

Goal: rules that apply in every repo and task, and settings that keep diffs visible.

1. Audit `~/.claude/settings.json`, and any `.claude/settings.json` / `.claude/settings.local.json` in the user's main repos. Report any of these to the user and propose removing them:
   - a `defaultMode` of `acceptEdits` or auto,
   - allow rules for `Edit` / `Write`,
   - accumulated broad allow rules.
2. Write `~/.claude/CLAUDE.md` (keep it under ~100 lines) and topic files under `~/.claude/rules/`. Required content:
   - **Explain before acting.** Before each edit, state what is changing and why. Summarize after a batch of edits.
   - **Edit only through the edit tool.** Never modify files via `sed`, heredocs, `tee`, or scripts.
   - **Never commit or push.** Never post to Linear or Slack without explicit approval.
   - **Where commands run.** `tailscale ssh` runs on the host. gcloud, aws, and okta run via `cx …`. Never run cloud CLIs on the host directly.
   - **Task awareness.** If a `task.org` exists in the working directory or above, read it first. Follow its plan. Log milestones with the worklog tool (Phase 5).
   - **Internal modules and conventions.** Ask the user for this list; leave a clearly marked placeholder until they provide it.
   - **Before opening any PR, run `/review`.**
3. Any repo that uses `AGENTS.md` but has no `CLAUDE.md` gets a one-line `CLAUDE.md` containing `@AGENTS.md`. Propose this per repo; don't do it silently.
4. Verify `claude-code-ide-use-ide-diff` is non-nil in the Emacs config.

Check: start a session in any repo and confirm with `/context` that the user memory and rules are loaded. Make a trivial edit and confirm it appears in ediff for approval.

## Phase 2: MCP servers

1. **Linear.** Run `claude mcp add --transport http --scope user linear https://mcp.linear.app/mcp`, then authenticate via `/mcp`. If a claude.ai-provided Linear connector also shows up in Claude Code, tell the user, so they can decide which to keep and avoid duplicate tools.
2. **Slack.** Check `claude mcp list` and the org's connector situation. If a Slack MCP is usable, add it at user scope. If it needs approval, draft a short request message for the user to send, and make every Slack-dependent command degrade gracefully (store the permalink; ask the user to paste content).
3. If the incident tracker in use has an MCP server, note it as optional for `/catchup`.

Check: in a session, Claude can fetch a known Linear issue with its comments, and (if available) read a known Slack thread.

## Phase 3: Task lifecycle CLI

A shell script `task`, on PATH and usable by both Emacs and Claude. All subcommands are idempotent and print what they did.

- **`task new <id> [--title "…"] [--type linear|incident|adhoc]`.** Creates the directory, `.task`, the thin `CLAUDE.md`, and `task.org` from the template below. Generates a fresh org `:ID:`. No worktrees. Registers with platypus (method TBD with the user).
- **`task add-repo <id> <repo-path> [--branch name]`.** Runs `git fetch`, then `git worktree add` into the task directory. Default branch: Linear's suggested branch name if available (pass it in), else `<id-lowercase>-<slug>`. Appends the repo to `:REPOS:` in `task.org`.
- **`task drop-repo <id> <repo-name>`.** Refuses if the worktree has uncommitted or unpushed work. Otherwise runs `git worktree remove` and updates `:REPOS:`.
- **`task list`.** Prints id, type, title, repos, and last Log date.
- **`task archive <id>`.** Requires all worktrees to be clean. Removes the worktrees, moves the directory to `.archive/`, and sets `:STATUS: done`. Keep `task.org` so org-roam links don't break: either update the roam index or keep archived files indexed.

Thin task `CLAUDE.md`:

```markdown
This is a task workspace. Read ./task.org first. It holds the context, plan, PRs, threads, and log.
Subdirectories are git worktrees of separate repos; each may have its own CLAUDE.md.
Log milestones with the worklog tool. Keep task.org's Plan and PRs sections current.
```

`task.org` template:

```org
:PROPERTIES:
:ID:       <generated>
:TYPE:     linear|incident|adhoc
:LINEAR:   <issue id or empty>
:REPOS:
:STATUS:   active
:END:
#+title: <id>: <title>
#+filetags: :task:

* Context
  AC, issue description, relevant comments, links. For incidents: symptom, start time, impact.
* Plan
  Per-repo changes, order, PR dependencies, open questions.
* PRs
  | Repo | PR | Status | Depends on |
  |------+----+--------+------------|
* Threads
  One heading per Slack thread or incident record:
  permalink, one-line summary, :LAST_READ: property.
* Decisions
* Log
  Datetree: entries filed under the date they happened.
```

Check: create a test task, add and drop a repo, archive it. Confirm that refusals trigger on dirty worktrees.

## Phase 4: Emacs layer

Write this as a separate file (e.g. `task-workflow.el`) loaded from the user's config. Match their package manager and keybinding style.

1. **Project root.** Add `.task` to `project-vc-extra-root-markers`, so that from the task root, project.el (and therefore claude-code-ide) treats the task directory as the project.
2. **`my/task-new`.** Prompts for an ID (offer the current Linear issue if the user provides one) and type. Calls `task new`, then `my/task-open`.
3. **`my/task-open`.** Switches to or creates a perspective named after the task ID. Opens `task.org` and a dired of the task directory. Starts or resumes a claude-code-ide session from the task root and renames it to the task ID. For a new Linear task, starts in plan mode (find how claude-code-ide passes CLI flags; the target is `--permission-mode plan`).
4. **`my/task-add-repo` / `my/task-drop-repo`.** Wrap the CLI with completion over the user's known repos (from `project-known-project-roots` or a configured list).
5. **Clocking.** On perspective switch to a task perspective, `org-clock-in` on the task's top heading (make this toggleable).
6. **Agenda.** Add `$TASKS_ROOT/*/task.org` to `org-agenda-files`.

Check: `my/task-new` → perspective appears → Claude session named after the task, rooted at the task directory → session can see all worktrees.

## Phase 5: org-roam and the worklog tool

1. **Indexing.** The user wants `task.org` files to stay in the task directories and be indexed by org-roam. Because worktrees contain arbitrary repo content, index only `task.org` files:
   - Preferred approach: symlink `$TASKS_ROOT` into `org-roam-directory`, and set `org-roam-file-exclude-regexp` so only `<task-id>/task.org` (and archived ones) are indexed, not anything inside worktrees.
   - Verify that `org-roam-list-files` actually follows the symlink with the user's configured file-listing backend. If it doesn't, propose alternatives (e.g. adjusting the listing command) and ask the user.
   - Run `org-roam-db-sync` and confirm task nodes appear and worktree org files don't.
2. **`my/worklog-add (task-id summary &optional detail)`:**
   - Finds the task's `task.org` (by directory or org ID).
   - Inserts a timestamped entry (time + summary + optional detail) under today's date in the `* Log` datetree.
   - Appends one line to today's org-roam daily: `- HH:MM [[id:<task-uuid>][<task-id>]] <summary>`. Create the daily if needed, using the user's dailies template, without opening windows or stealing focus.
   - Saves both buffers. Must work when the files are or aren't already open.
3. **Expose it to Claude.** Make `my/worklog-add` callable through claude-code-ide's Emacs MCP tools (`claude-code-ide-mcp-server-tools`; read the package README for the current way to define a tool). Fallback: `emacsclient --eval`. Document the tool name in the central CLAUDE.md task-awareness rule.
4. **Milestone rule** (already in Phase 1): log when a plan is agreed, a repo is added, a PR is opened or changes status, a finding is confirmed, Claude is blocked on something, or work stops for the day. Optional later: a Stop hook that nudges Claude if the Log wasn't updated during a long session. Only add it if logging gets neglected.

Check: call the tool from a Claude session. Today's daily gets a linked line. The task Log has the full entry under today's date. The task node's backlinks show today's daily. Repeat the next day and confirm both days appear.

## Phase 6: Slash commands

Create these in `~/.claude/commands/`. Each should be short and refer to `task.org` sections by name.

- **`/task-plan`.** Reads Linear (if `:LINEAR:` is set) and existing context. Fills Context. Drafts Plan (per-repo changes, order, PR dependencies, open questions) and asks questions until agreed. Asks which repos to add, then runs `task add-repo` for each. Logs "plan agreed".
- **`/log <text>`.** Manual worklog entry via the tool.
- **`/thread-add <permalink>`.** Fetches the thread (Slack MCP, or asks the user to paste it). Adds a Threads heading with a summary and `:LAST_READ:`. Logs it.
- **`/catchup`.** For each thread, reads only messages after `:LAST_READ:`. Summarizes decisions, asks of the user, and changes into the Log. Updates `:LAST_READ:`. Ends with "things that need you".
- **`/pr-status`.** For each worktree, finds the PR for its branch (`gh pr view` / `gh pr checks`). Refreshes the PRs table. Flags merge-order problems.
- **`/review`.** The user's review checklist. Ask them for it; start with: diff matches plan, tests run, no stray debug code, internal modules used, PR description cross-links sibling PRs and the Linear issue.
- **`/linear-update`.** Drafts a Linear comment or status change from Plan, PRs, and Log, and posts it only after approval.

Check: run each command in a test task.

## Phase 7: Container browser bridge (no more copy-paste auth)

Goal: gcloud, aws, and Okta auth started inside the container open a tab in the host browser and complete without copy-paste. Avoid recreating the persistent container.

1. **Inspect** the container's network mode (`docker inspect -f '{{.HostConfig.NetworkMode}}' <container>`) and how each auth flow is invoked today. Report findings before building anything.
2. **URL forwarding (needed in all cases):**
   - Host: a systemd user service listening on a Unix socket placed inside the already-mounted work directory (e.g. `<workdir>/.host-bridge/open.sock`), so no new mount is needed. It reads one URL per connection, accepts only `http://` / `https://`, and opens it with `xdg-open`. Make sure the service has the graphical session environment (`DISPLAY` / `WAYLAND_DISPLAY`, e.g. via `systemctl --user import-environment`).
   - Container: a script `host-open` that sends its argument to the socket. Set `BROWSER=host-open` in the container's shell environment, and register it as the default handler wherever a tool ignores `BROWSER`.
3. **Localhost callbacks** (gcloud's loopback flow, AWS SSO's authorization-code flow):
   - If the container uses host networking, step 2 is sufficient.
   - Otherwise, preferred: device-code flows where the tool supports them (e.g. `aws sso login --use-device-code`; check the Okta tooling in use). With URL forwarding these become click-to-approve.
   - Fallback for flows that require a callback: when `host-open` sees a `redirect_uri` on `localhost:<port>`, it starts a short-lived forwarder in the container (container IP:port → 127.0.0.1:port) and asks the host service to start one (host 127.0.0.1:port → container IP:port). Both forwarders exit after the callback or a timeout. Only build this if the simpler options don't cover the user's flows.
4. Document the result in the central CLAUDE.md "where commands run" rule, so Claude knows it can trigger auth via `cx` and wait for the user to approve in the browser.

Check: from a fresh container shell, run each auth flow (`gcloud auth login`, `gcloud auth application-default login`, the AWS SSO login, the Okta flow). A host browser tab opens and the CLI completes with no pasted codes or URLs.

## Phase 8: Permission profiles

Define how each mode starts. The aim is fewer prompts for safe reads, never at the cost of losing diff review.

- **Plan:** `--permission-mode plan`. The default for new Linear tasks.
- **Investigate** (incidents): default mode, plus allow rules for read-only commands (`cx gcloud … list/describe`, `cx aws … describe/get/list`, `kubectl get/describe/logs` if used, `gh` read commands). No write allows.
- **Implement:** default mode. Edits always prompt, so ediff appears. Allow the test and lint commands for the repos involved.

Implement these as settings files passed at launch (or the closest mechanism claude-code-ide supports), and offer a choice in `my/task-open`.

Check: in investigate mode, a read-only cloud query runs without prompting. A mutating command prompts. In every mode, file edits show in ediff.

---

## Out of scope for now

- Switching from claude-code-ide (agent-shell via ACP is the alternative to re-evaluate later).
- Automatic posting to Linear or Slack.
- Multi-agent orchestration.

## Questions to ask the user during implementation

- Tasks root path, and how platypus stores task state.
- Internal modules and conventions list for the central CLAUDE.md.
- Their `/review` checklist.
- Which Okta CLI tool they use, and whether it supports device authorization.
- Whether Slack MCP needs an approval request.

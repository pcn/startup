;;; package --- Summary  -*- lexical-binding: t -*-
;;; Task workspaces: one perspective, task.org and Claude session per task

;;; Commentary:
;;; Wraps the `task' CLI (startup/emacs/bin/task).  Each task directory under
;;; a scope's root (`my/task-scopes': work and personal) gets a perspective
;;; named after the task id, showing
;;; task.org, a dired of the task directory, and a claude-code-ide session
;;; rooted there.  See emacs/new-workflow.md.
;;;
;;; Keys are under the perspective prefix: C-M-p t n (new), t o (open),
;;; t a (add repo, C-u to link), t k (drop repo), t l (worklog entry),
;;; t c (toggle clock-in).

;;; Code:

(require 'dired)
(require 'seq)
(require 'subr-x)

;; Let-bound below, so they must be special before perspective or
;; claude-code-ide is loaded.
(defvar claude-code-ide-cli-extra-flags)
(defvar persp--suppress-project-prompt)
(defvar perspective-map)
(defvar project-vc-extra-root-markers)
(defvar org-clock-marker)
(declare-function claude-code-ide "claude-code-ide")
(declare-function claude-code-ide-continue "claude-code-ide")
(declare-function claude-code-ide-switch-to-buffer "claude-code-ide")
(declare-function claude-code-ide--get-buffer-name "claude-code-ide")
(declare-function persp-curr "perspective")
(declare-function persp-name "perspective")
(declare-function persp-names "perspective")
(declare-function persp-switch "perspective")
(declare-function persp--add-project-to-perspective "perspective-settings")
(declare-function persp--get-perspective-projects "perspective-settings")
(declare-function persp--normalize-project-path "perspective-settings")
(declare-function persp-remove-project-from-perspective "perspective-settings")
(declare-function org-clock-in "org-clock")
(declare-function org-clocking-p "org-clock")
(declare-function org-roam-db-update-file "org-roam-db")
(declare-function org-roam-node-from-title-or-alias "org-roam-node")
(declare-function org-roam-node-file "org-roam-node")
(declare-function org-datetree-find-date-create "org-datetree")
(declare-function calendar-current-date "calendar")
(declare-function org-end-of-subtree "org")
(declare-function org-current-level "org")
(declare-function claude-code-ide-make-tool "claude-code-ide-mcp-server")
(declare-function claude-code-ide-mcp-server-get-session-context "claude-code-ide-mcp-server")

(defvar my/task-scopes
  `((work :root ,(expand-file-name "~/dvcs/netlify/tasks/")
          :repos-root ,(expand-file-name "~/dvcs/netlify/")
          :worklog-title "Netlify Work %Y Log"
          :worklog-heading "Daily Log")
    (personal :root ,(expand-file-name "~/dvcs/pcn/tasks/")
              :repos-root ,(expand-file-name "~/dvcs/pcn/")
              :worklog-title "%Y - Personal Log"
              :worklog-heading "Logs"))
  "Task scopes, each with its own directories and yearly log.
:root holds the task workspaces and :repos-root the git checkouts
`my/task-add-repo' offers.  The task CLI has the same roots built in.
:worklog-title is a `format-time-string' format for the title of the
year's log note, and :worklog-heading the top-level heading in it whose
day headings link to task Log entries.  Personal tasks (type personal)
go in the personal scope, everything else in work.")

(defun my/task--roots ()
  "Tasks roots of all scopes."
  (mapcar (lambda (s) (plist-get (cdr s) :root)) my/task-scopes))

(defun my/task--scope (file)
  "Plist of the scope whose tasks root holds FILE, or nil."
  (let ((path (expand-file-name file)))
    (seq-some (lambda (s) (and (string-prefix-p (plist-get (cdr s) :root) path) (cdr s)))
              my/task-scopes)))

(defvar my/task-program (or (executable-find "task") (expand-file-name "~/bin/task"))
  "Path to the task CLI.")

(defvar my/task-profiles-dir
  (expand-file-name "~/dvcs/pcn/startup/emacs/claude/profiles/")
  "Claude permission profiles: common.json plus one file per profile.")

(defvar my/task-clock-in-on-switch nil
  "When non-nil, switching to a task's perspective clocks in to its task.org.")

(defvar my/task-clock-heading "Log"
  "Top-level task.org heading that `my/task-clock-in-on-switch' clocks in to.")

;;;; Project root and symlinks

;; Task dirs are git repos, so this only matters before `task new' has run
;; git init.  Worktrees inside a task are still their own projects.
(with-eval-after-load 'project
  (add-to-list 'project-vc-extra-root-markers ".task"))

(defun my/task--under-root-p (file)
  "Non-nil if FILE is inside a tasks root."
  (and file (my/task--scope file) t))

(defun my/task--keep-symlinked-paths ()
  "Visit files in a task's linked checkouts through the link.
That keeps them inside the task's project instead of jumping to the
live checkout."
  (when (my/task--under-root-p buffer-file-name)
    (setq-local vc-follow-symlinks nil)))

;; Must run before `vc-refresh-state', which is where the link gets followed.
(add-hook 'find-file-hook #'my/task--keep-symlinked-paths -50)

;;;; Task lookup

(defun my/task--find-dir (id)
  "Directory of active task ID in any tasks root, or nil."
  (seq-some (lambda (root)
              (let ((dir (file-name-as-directory (expand-file-name id root))))
                (and (file-exists-p (expand-file-name "task.org" dir)) dir)))
            (my/task--roots)))

(defun my/task--dir (id)
  "Directory of active task ID."
  (or (my/task--find-dir id) (user-error "No task %s" id)))

(defun my/task--org-file (id)
  "task.org of task ID."
  (expand-file-name "task.org" (my/task--dir id)))

(defun my/task--subdirs (dir)
  "Full paths of DIR's non-hidden subdirectories.
Callers look inside these, so archives have to be ruled out first:
checking a path like foo.tar.gz/.git makes tramp-archive mount it."
  (when (file-directory-p dir)
    (seq-filter #'file-directory-p (directory-files dir t "\\`[^.]"))))

(defun my/task--ids ()
  "Ids of the active (not archived) tasks in all tasks roots."
  (mapcar #'file-name-nondirectory
          (seq-filter (lambda (d) (file-exists-p (expand-file-name "task.org" d)))
                      (mapcan #'my/task--subdirs (my/task--roots)))))

(defun my/task--prop (id prop)
  "Value of property PROP in task ID's task.org, or nil."
  (with-temp-buffer
    (insert-file-contents (my/task--org-file id))
    (when (re-search-forward (format "^:%s:[ \t]*\\(.*\\)$" prop) nil t)
      (string-trim (match-string 1)))))

(defun my/task--perspective-id ()
  "Task id of the current perspective, or nil if it isn't a task's."
  (and (bound-and-true-p persp-mode) (persp-curr)
       (car (member (persp-name (persp-curr)) (my/task--ids)))))

(defun my/task--current-id ()
  "Task id for the current directory or perspective, or nil."
  (or (let* ((dir (expand-file-name default-directory))
             (root (plist-get (my/task--scope dir) :root)))
        (when root
          (car (member (car (split-string (substring dir (length root)) "/"))
                       (my/task--ids)))))
      (my/task--perspective-id)))

(defun my/task--read-id ()
  "Read a task id, defaulting to the current task."
  (let ((current (my/task--current-id)))
    (completing-read (format-prompt "Task" current) (my/task--ids) nil t nil nil current)))

(defun my/task--target-id ()
  "The current perspective's task, or one read with completion."
  (or (my/task--perspective-id) (my/task--read-id)))

;;;; Running the CLI

(defun my/task--run (&rest args)
  "Run the task CLI with ARGS, logging to *task* and echoing its output."
  (with-current-buffer (get-buffer-create "*task*")
    (goto-char (point-max))
    (insert (format "$ task %s\n" (mapconcat #'shell-quote-argument args " ")))
    (let* ((start (point))
           (status (apply #'call-process my/task-program nil t nil args))
           (output (string-trim (buffer-substring start (point)))))
      (unless (eql status 0)
        (display-buffer (current-buffer))
        (user-error "task %s failed: %s" (car args) output))
      (message "%s" output))))

(defun my/task--revert-dired (id)
  "Refresh dired buffers showing task ID's directory."
  (dolist (buf (dired-buffers-for-dir (my/task--dir id)))
    (with-current-buffer buf (revert-buffer))))

;;;; Perspective projects

(defun my/task--sync-perspective (id)
  "Make the current perspective's projects match task ID's repos.
Entries inside the task directory that are no longer in :REPOS: are
removed; other projects in the perspective are left alone.  The task
directory is added last so it stays the perspective's primary project,
which claude-code-ide falls back to."
  (when (equal (my/task--perspective-id) id)
    (let* ((root (persp--normalize-project-path (my/task--dir id)))
           (repos (mapcar (lambda (r)
                            (file-name-as-directory
                             (persp--normalize-project-path
                              (expand-file-name r (expand-file-name "repos" root)))))
                          (split-string (or (my/task--prop id "REPOS") "")))))
      (dolist (p (persp--get-perspective-projects))
        (let ((np (file-name-as-directory (persp--normalize-project-path p))))
          (when (and (string-prefix-p root np)
                     (not (equal np root))
                     (not (seq-some (lambda (r) (string-prefix-p r np)) repos)))
            (persp-remove-project-from-perspective p))))
      (dolist (r repos)
        (persp--add-project-to-perspective r))
      (persp--add-project-to-perspective root))))

(defun my/task--sync-current-perspective (&rest _)
  "Sync the current perspective's projects if it belongs to a task.
This catches repos added outside Emacs, e.g. by Claude running
`task add-repo'."
  (when-let* ((id (my/task--perspective-id)))
    (my/task--sync-perspective id)))

;;;; Claude session

(defun my/task--has-conversation-p (dir)
  "Non-nil if Claude Code has a saved conversation for DIR."
  (let ((store (expand-file-name
                (replace-regexp-in-string "[^[:alnum:]]" "-"
                                          (directory-file-name (expand-file-name dir)))
                "~/.claude/projects/")))
    (and (file-directory-p store)
         (directory-files store nil "\\.jsonl\\'" t 1))))

(defun my/task--profile-flags (profile)
  "Claude CLI flags for permission PROFILE (plan, investigate or implement).
common.json and PROFILE.json from `my/task-profiles-dir' are merged
and passed inline as --settings, with the profile's --permission-mode."
  (let* ((read (lambda (name)
                 (let ((file (expand-file-name (concat name ".json") my/task-profiles-dir)))
                   (alist-get 'permissions
                              (json-parse-string
                               (with-temp-buffer (insert-file-contents file) (buffer-string))
                               :object-type 'alist :array-type 'list)))))
         (common (funcall read "common"))
         (own (funcall read profile))
         (merged (mapcar (lambda (key)
                           (cons key (vconcat (alist-get key common) (alist-get key own))))
                         '(allow ask deny))))
    (format "--permission-mode %s --settings %s"
            (if (equal profile "plan") "plan" "default")
            (shell-quote-argument (json-serialize `((permissions . ,merged)))))))

(defun my/task--read-profile (dir)
  "Read a permission profile for a session in task directory DIR.
The default follows the task's type: investigate for incidents,
implement otherwise."
  (let* ((id (file-name-nondirectory (directory-file-name dir)))
         (default (if (equal (my/task--prop id "TYPE") "incident") "investigate" "implement")))
    (completing-read (format-prompt "Claude profile for %s" default id)
                     '("plan" "investigate" "implement") nil t nil nil default)))

(defun my/task--claude (dir &optional profile)
  "Show DIR's Claude session, continuing or starting one if none is running.
A session started here uses permission PROFILE (see `my/task-profiles-dir');
when PROFILE is nil, ask for one."
  (require 'claude-code-ide)
  (let ((default-directory dir))
    (if (get-buffer (claude-code-ide--get-buffer-name dir))
        (claude-code-ide-switch-to-buffer)
      (let ((claude-code-ide-cli-extra-flags
             (string-trim (concat claude-code-ide-cli-extra-flags " "
                                  (my/task--profile-flags
                                   (or profile (my/task--read-profile dir)))))))
        (if (my/task--has-conversation-p dir)
            (claude-code-ide-continue)
          (claude-code-ide))))))

;;;; Commands

(defun my/task--linear-id-at-point ()
  "A Linear issue id at point or at the head of the kill ring, or nil."
  (seq-find (lambda (s) (and s (string-match-p "\\`[A-Z][A-Z0-9]*-[0-9]+\\'" s)))
            (list (thing-at-point 'symbol t)
                  (ignore-errors (string-trim (current-kill 0 t))))))

(defun my/task--guess-type (id)
  "Task type the CLI would infer from ID."
  (cond ((string-prefix-p "inc-" id) "incident")
        ((string-match-p "\\`[A-Z][A-Z0-9]*-[0-9]+\\'" id) "linear")
        (t "adhoc")))

(defun my/task-new (id type title)
  "Create task ID of TYPE with TITLE using the task CLI, then open it.
A Linear issue id at point or in the kill ring is offered as the default.
Type personal puts the task in the personal scope (`my/task-scopes').
New Linear tasks start their Claude session with the plan profile."
  (interactive
   (let* ((guess (my/task--linear-id-at-point))
          (id (read-string (format-prompt "Task id" guess) nil nil guess))
          (type (completing-read "Type: " '("linear" "incident" "adhoc" "personal") nil t nil nil
                                 (my/task--guess-type id)))
          (title (read-string "Title: ")))
     (list id type title)))
  (let ((new (not (my/task--find-dir id))))
    (apply #'my/task--run "new" id "--type" type
           (unless (string-empty-p title) (list "--title" title)))
    (my/task-switch id (and new (equal type "linear") "plan"))))

(defun my/task-switch (id &optional profile)
  "Switch to task ID's perspective and show its Claude session.
A new perspective is laid out with task.org above a dired of the task
directory.  If no Claude session is running, one is started with
permission PROFILE, asking for it when PROFILE is nil."
  (interactive (list (my/task--read-id)))
  (let ((dir (my/task--dir id))
        (existing (member id (persp-names))))
    (let ((persp--suppress-project-prompt t))
      (persp-switch id))
    (my/task--sync-perspective id)
    (unless existing
      (delete-other-windows)
      (find-file (my/task--org-file id))
      (with-selected-window (split-window-below)
        (dired dir)))
    (my/task--claude dir profile)))

(defun my/task--repos-root (id)
  "Repos root of task ID's scope."
  (plist-get (my/task--scope (my/task--dir id)) :repos-root))

(defun my/task--repo-candidates (id)
  "Git checkouts directly under task ID's repos root."
  (mapcar #'file-name-nondirectory
          (seq-filter (lambda (d) (file-directory-p (expand-file-name ".git" d)))
                      (my/task--subdirs (my/task--repos-root id)))))

(defun my/task-add-repo (id repo &optional branch link)
  "Add REPO to task ID as a git worktree on BRANCH.
REPO is a checkout name under the task scope's :repos-root or a path.
An empty BRANCH lets the CLI pick its default.  With prefix argument
LINK, link the live checkout instead of adding a worktree."
  (interactive
   (let* ((id (my/task--target-id))
          (link current-prefix-arg)
          (repo (completing-read (format "%s repo to %s: " (if link "Link" "Add") id)
                                 (my/task--repo-candidates id)))
          (branch (unless link (read-string "Branch (empty for default): "))))
     (list id repo branch link)))
  (apply #'my/task--run "add-repo" id (expand-file-name repo (my/task--repos-root id))
         (append (when link (list "--link"))
                 (unless (or link (string-empty-p (or branch ""))) (list "--branch" branch))))
  (my/task--sync-perspective id)
  (my/task--revert-dired id))

(defun my/task-drop-repo (id repo)
  "Remove REPO's worktree or link from task ID.
The CLI refuses if work would be lost."
  (interactive
   (let ((id (my/task--target-id)))
     (list id (completing-read (format "Drop from %s: " id)
                               (split-string (or (my/task--prop id "REPOS") "")) nil t))))
  (my/task--run "drop-repo" id repo)
  (my/task--sync-perspective id)
  (my/task--revert-dired id))

;;;; Clocking

(defun my/task--clock-in ()
  "Clock in to the current task perspective's task.org, if enabled."
  (when-let* ((my/task-clock-in-on-switch)
              (id (car (member (persp-name (persp-curr)) (my/task--ids)))))
    (require 'org-clock)
    (with-current-buffer (find-file-noselect (my/task--org-file id))
      (unless (and (org-clocking-p) (eq (marker-buffer org-clock-marker) (current-buffer)))
        (save-excursion
          (save-restriction
            (widen)
            (goto-char (point-min))
            (when (re-search-forward (format "^\\* %s\\b" (regexp-quote my/task-clock-heading)) nil t)
              (org-clock-in))))))))

(defun my/task-toggle-clock-in ()
  "Toggle clocking in when switching to a task perspective."
  (interactive)
  (setq my/task-clock-in-on-switch (not my/task-clock-in-on-switch))
  (message "Task clock-in on perspective switch %s" (if my/task-clock-in-on-switch "on" "off")))

;;;; Agenda

(defun my/task--add-agenda-files (files)
  "Append active task.org files to FILES, unless the agenda is restricted."
  (if (get 'org-agenda-files 'org-restrict)
      files
    (append files (seq-difference (mapcar #'my/task--org-file (my/task--ids)) files))))

;; org-agenda-files names a file list, so add tasks to what the function returns.
(with-eval-after-load 'org
  (advice-add 'org-agenda-files :filter-return #'my/task--add-agenda-files))

;;;; org-roam indexing

;; task.org files stay in their task directories.  Rather than symlinking
;; the tasks root into `org-roam-directory' (find -L would walk every
;; worktree, and files would have two paths), org-roam is told about
;; exactly these files, at their real paths.

(defun my/task--org-file-p (file)
  "Non-nil if FILE is an active or archived task's task.org."
  (when-let* ((root (plist-get (my/task--scope file) :root)))
    (string-match-p "\\`\\(?:\\.archive/\\)?[^/]+/task\\.org\\'"
                    (file-relative-name (expand-file-name file) root))))

(defun my/task--all-org-files ()
  "task.org files of active and archived tasks in all tasks roots."
  (seq-filter #'file-exists-p
              (mapcar (lambda (d) (expand-file-name "task.org" d))
                      (mapcan (lambda (root)
                                (append (my/task--subdirs root)
                                        (my/task--subdirs (expand-file-name ".archive" root))))
                              (my/task--roots)))))

(defun my/task--roam-add-files (files)
  "Add every task.org to org-roam's FILES."
  (append files (seq-difference (my/task--all-org-files) files)))

(defun my/task--roam-file-p (orig &optional file)
  "Count task.org files as org-roam files; otherwise defer to ORIG with FILE."
  (let ((path (or file (buffer-file-name (buffer-base-buffer)))))
    (or (and path (my/task--org-file-p path))
        (funcall orig file))))

(with-eval-after-load 'org-roam
  (advice-add 'org-roam-list-files :filter-return #'my/task--roam-add-files)
  (advice-add 'org-roam-file-p :around #'my/task--roam-file-p))

;;;; Worklog

(defun my/task--find-org-file (id)
  "task.org of task ID, active or archived, in any tasks root, or nil."
  (seq-find #'file-exists-p
            (mapcan (lambda (root)
                      (list (expand-file-name (concat id "/task.org") root)
                            (expand-file-name (concat ".archive/" id "/task.org") root)))
                    (my/task--roots))))

(defun my/task--edit-file (file fn)
  "Call FN in a widened buffer visiting FILE, then save FILE.
If FILE's buffer already had unsaved changes, the edit is left unsaved
too, so the user's own work isn't saved behind their back.  A buffer
opened only for this is killed afterwards, so no window changes."
  (let* ((existing (get-file-buffer file))
         (buf (or existing (find-file-noselect file)))
         (pending (buffer-modified-p buf)))
    (unwind-protect
        (with-current-buffer buf
          (save-excursion
            (save-restriction
              (widen)
              (funcall fn)))
          (if pending
              (message "worklog: added to %s, which has unsaved changes; not saved"
                       (buffer-name))
            (save-buffer)))
      (unless existing (kill-buffer buf)))))

(defun my/worklog--file (scope time)
  "File of SCOPE's log note for TIME's year, or nil if there is none."
  (require 'org-roam)
  (when-let* ((node (org-roam-node-from-title-or-alias
                     (format-time-string (plist-get scope :worklog-title) time))))
    (org-roam-node-file node)))

(defun my/worklog--index-task (scope task-id uuid time)
  "Link TASK-ID's Log entries for TIME's day from SCOPE's yearly log.
Under SCOPE's :worklog-heading, finds or creates the day heading (newest
first) and adds a link to the task's datetree day, unless the task is
already linked there.  UUID is the task's org ID.  Returns the log file,
or nil if the year has no log note."
  (when-let* ((file (my/worklog--file scope time)))
    (let ((heading (plist-get scope :worklog-heading))
          (day-re (format "^\\*\\* <%s" (format-time-string "%Y-%m-%d" time)))
          (link (format "- [[id:%s::*%s][%s]]"
                        uuid (format-time-string "%Y-%m-%d %A" time) task-id)))
      (my/task--edit-file
       file
       (lambda ()
         (goto-char (point-min))
         (unless (re-search-forward (format "^\\* %s\\b" (regexp-quote heading)) nil t)
           (user-error "No * %s heading in %s" heading file))
         (let ((log-end (save-excursion (or (re-search-forward "^\\* " nil t) (point-max)))))
           (if (re-search-forward day-re log-end t)
               (beginning-of-line)
             ;; New day: above the newest existing day.
             (forward-line 1)
             (if (re-search-forward "^\\*\\* " log-end t)
                 (beginning-of-line)
               (goto-char log-end)
               (unless (bolp) (insert "\n")))
             (insert (format-time-string "** <%Y-%m-%d %a>\n" time))
             (forward-line -1)))
         ;; Point is at the day heading.  Links go right under it, after
         ;; earlier links; anything else under the day is left alone.
         (let ((day-end (save-excursion (org-end-of-subtree t t) (point))))
           (unless (save-excursion
                     (search-forward (format "[[id:%s::" uuid) day-end t))
             (forward-line 1)
             (while (looking-at "- \\[\\[id:") (forward-line 1))
             (insert link "\n")))))
      (condition-case err
          (org-roam-db-update-file file)
        (error (message "worklog: org-roam DB update failed: %s" (error-message-string err))))
      file)))

(defun my/worklog-add (task-id summary &optional detail)
  "Log SUMMARY, and optional DETAIL, for TASK-ID.
The task's * Log gets a timestamped entry under today's date, and the
year's log note of the task's scope (`my/task-scopes') links today to
that task's Log entries, once per task per day.  Returns a description
of what was written."
  (interactive
   (let* ((id (my/task--target-id))
          (summary (read-string (format "Log for %s: " id)))
          (detail (read-string "Detail (optional): ")))
     (list id summary (unless (string-empty-p detail) detail))))
  (require 'org-datetree)
  (let ((file (or (my/task--find-org-file task-id) (user-error "No task %s" task-id)))
        (time (format-time-string "%H:%M"))
        uuid worklog)
    (my/task--edit-file
     file
     (lambda ()
       (goto-char (point-min))
       (setq uuid (and (re-search-forward "^:ID:[ \t]+\\(\\S-+\\)" nil t) (match-string 1)))
       (unless uuid (user-error "No :ID: in %s" file))
       (goto-char (point-min))
       (unless (re-search-forward "^\\* Log\\b" nil t)
         (user-error "No * Log heading in %s" file))
       (beginning-of-line)
       (org-datetree-find-date-create (calendar-current-date) 'subtree-at-point)
       (let ((indent (make-string (1+ (org-current-level)) ?\s)))
         (org-end-of-subtree t)
         (skip-chars-backward " \t\n")
         (end-of-line)
         (insert "\n" indent "- " time " " summary)
         (when detail
           (dolist (line (split-string (string-trim detail) "\n"))
             (insert "\n" indent "  " line))))))
    (condition-case err
        (org-roam-db-update-file file)
      (error (message "worklog: org-roam DB update failed: %s" (error-message-string err))))
    (setq worklog (my/worklog--index-task (my/task--scope file) task-id uuid (current-time)))
    (if worklog
        (format "Logged to %s; linked from %s" (abbreviate-file-name file)
                (abbreviate-file-name worklog))
      (format "Logged to %s; no \"%s\" note, so the yearly log was skipped"
              (abbreviate-file-name file)
              (format-time-string (plist-get (my/task--scope file) :worklog-title))))))

;;;; worklog_add MCP tool

(defun my/worklog-add-tool (summary &optional task_id detail)
  "MCP entry point for `my/worklog-add' with SUMMARY and DETAIL.
TASK_ID defaults to the task the Claude session is rooted in."
  (let ((id (if (and task_id (not (string-empty-p task_id)))
                task_id
              (let ((default-directory
                     (or (plist-get (claude-code-ide-mcp-server-get-session-context) :project-dir)
                         default-directory)))
                (my/task--current-id)))))
    (unless id
      (error "This session is not in a task directory; pass task_id"))
    (my/worklog-add id summary (unless (equal detail "") detail))))

(with-eval-after-load 'claude-code-ide
  (claude-code-ide-make-tool
   :function #'my/worklog-add-tool
   :name "worklog_add"
   :description "Log a task milestone: adds a timestamped entry under today's date in the task's task.org * Log, and links that day's entries from the user's yearly log (the work log for work tasks, the personal log for personal ones). Use for: plan agreed, repo added or dropped, PR opened or changed status, finding confirmed, blocked, stopping for the day. Keep the summary to one line, past tense, specific."
   :args '((:name "summary"
            :type string
            :description "One-line, past-tense summary of the milestone")
           (:name "task_id"
            :type string
            :description "Task id (directory name under a tasks root); defaults to the session's task"
            :optional t)
           (:name "detail"
            :type string
            :description "Optional extra detail, a few lines at most"
            :optional t))))

;;;; Keys

(defvar my/task-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "n") #'my/task-new)
    (define-key map (kbd "s") #'my/task-switch)
    (define-key map (kbd "a") #'my/task-add-repo)
    (define-key map (kbd "k") #'my/task-drop-repo)
    (define-key map (kbd "c") #'my/task-toggle-clock-in)
    (define-key map (kbd "l") #'my/worklog-add)
    map)
  "Task workspace commands.")

(with-eval-after-load 'perspective
  (define-key perspective-map (kbd "t") my/task-map)
  (add-hook 'persp-switch-hook #'my/task--clock-in)
  ;; Before `persp--maybe-switch-to-project' offers the project list.
  (add-hook 'persp-switch-hook #'my/task--sync-current-perspective -10)
  (advice-add 'persp-projectile-switch-project :before #'my/task--sync-current-perspective))

(provide 'task-workflow)
;;; task-workflow.el ends here

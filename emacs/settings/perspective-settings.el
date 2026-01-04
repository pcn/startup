;;; package --- Summary
;;; Settings for perspective workspace management

;;; Commentary:
;;; Configuration for perspective.el to manage multiple workspaces
;;; with separate project lists per perspective

;;; Code:

(elpaca perspective (use-package perspective
  :init
  ;; Running `persp-mode' multiple times resets the perspective list...
  (unless (equal persp-mode t)
    (persp-mode))
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))
  ;; Enable perspective persistence
  (persp-state-default-file (expand-file-name "~/.emacs.d/perspective-state"))
  :hook
  ;; Save and restore perspective state
  (kill-emacs . persp-state-save)
  :config
  ;; Load perspective state after everything is set up
  (when (file-exists-p persp-state-default-file)
    (persp-state-restore persp-state-default-file))
  ;; Activate perspective mode in config after initialization
  (persp-mode 1)))

;; Separate projectile known-projects per perspective
(defvar persp--projectile-known-projects-alist nil
  "Alist mapping perspective names to their projectile-known-projects.")

(defun persp--get-perspective-projects ()
  "Get projects for current perspective."
  (when (and (bound-and-true-p persp-mode) (persp-curr))
    (alist-get (persp-name (persp-curr)) persp--projectile-known-projects-alist nil nil #'equal)))

(defun persp-remove-project-from-perspective (project)
  "Remove PROJECT from current perspective's project list."
  (interactive 
   (list (projectile-completing-read
          "Remove project from perspective: " 
          (persp--get-perspective-projects))))
  (when (and (bound-and-true-p persp-mode) (persp-curr))
    (let* ((persp-name (persp-name (persp-curr)))
           (current-projects (alist-get persp-name persp--projectile-known-projects-alist nil nil #'equal))
           (updated-projects (remove project current-projects)))
      (setf (alist-get persp-name persp--projectile-known-projects-alist nil nil #'equal)
            updated-projects)
      (message "Removed project '%s' from perspective '%s'" 
               (file-name-nondirectory (directory-file-name project))
               persp-name))))

(defun persp-switch-with-saved ()
  "Switch to perspective, including saved perspectives from persp--projectile-known-projects-alist.
This allows switching to perspectives that have been saved but are not currently active."
  (interactive)
  (let* ((active-names (persp-names))
         (saved-names (mapcar #'car persp--projectile-known-projects-alist))
         (all-names (delete-dups (append active-names saved-names)))
         (selected (completing-read "Switch to perspective: " all-names)))
    (persp-switch selected)))

(defun persp--normalize-project-path (project)
  "Normalize PROJECT path to a consistent format (abbreviated)."
  (abbreviate-file-name (expand-file-name project)))

(defun persp--add-project-to-perspective (project)
  "Add PROJECT to current perspective's project list."
  (when (and (bound-and-true-p persp-mode) (persp-curr))
    (let* ((persp-name (persp-name (persp-curr)))
           ;; Normalize the project path to avoid duplicates
           (normalized-project (persp--normalize-project-path project))
           (current-projects (alist-get persp-name persp--projectile-known-projects-alist nil nil #'equal)))
      ;; Remove any existing entries with different path formats for the same project
      (setq current-projects 
            (seq-remove (lambda (existing-project)
                         (string= (persp--normalize-project-path existing-project)
                                 normalized-project))
                       current-projects))
      ;; Add the normalized version
      (setf (alist-get persp-name persp--projectile-known-projects-alist nil nil #'equal)
            (cons normalized-project current-projects)))))

;; Custom project action dispatcher
(defun persp--project-action-dispatcher (project)
  "Show a custom dispatcher for project actions after selecting PROJECT."
  (let ((default-directory project)
        (project-name (file-name-nondirectory (directory-file-name project))))
    (message "Project: %s | [f]ind file  [d]irectory  [b]uffer  [r]oot  [RET]search | " project-name)
    (let ((key (read-key)))
      (cond
       ((eq key ?f) (counsel-projectile-find-file))
       ((eq key ?d) (counsel-projectile-find-dir))
       ((eq key ?b) (counsel-projectile-switch-to-buffer))
       ((eq key ?r) (projectile-dired))
       ((or (eq key ?\r) (eq key ?\n)) (counsel-projectile))
       (t (message "Invalid key. Use f/d/b/r/RET"))))))

;; Custom perspective-aware project switching
(defun persp-projectile-switch-project (&optional arg)
  "Switch to a project, respecting perspective boundaries when perspective mode is active."
  (interactive "P")
  (if (and (bound-and-true-p persp-mode) (persp-curr))
      ;; In perspective mode - use perspective-specific projects
      (let ((projects (persp--get-perspective-projects)))
        (if projects
            (projectile-completing-read
             "Switch to project: " projects
             :action #'persp--project-action-dispatcher)
          (message "No projects in current perspective '%s'. Navigate to project directories to add them."
                   (persp-name (persp-curr)))))
    ;; Not in perspective mode - use normal projectile behavior
    (projectile-switch-project arg)))

;; Persistence for our custom perspective-project associations
(defun persp--save-perspective-projects ()
  "Save perspective-project associations to file."
  (when persp--projectile-known-projects-alist
    (with-temp-file (expand-file-name "~/.emacs.d/perspective-projects")
      (prin1 persp--projectile-known-projects-alist (current-buffer)))))

(defun persp--load-perspective-projects ()
  "Load perspective-project associations from file."
  (let ((file (expand-file-name "~/.emacs.d/perspective-projects")))
    (when (file-exists-p file)
      (with-temp-buffer
        (insert-file-contents file)
        (setq persp--projectile-known-projects-alist (read (current-buffer)))))))

;; Hook to automatically add projects to current perspective and bind our custom function
(with-eval-after-load 'perspective
  (with-eval-after-load 'projectile
    (advice-add 'projectile-add-known-project :after
                (lambda (project-root)
                  ;; Always normalize the path before adding to perspective
                  (persp--add-project-to-perspective (persp--normalize-project-path project-root))))
    ;; Override the projectile switch-project keybinding to use our perspective-aware version
    (define-key projectile-command-map (kbd "p") 'persp-projectile-switch-project)
    ;; Load saved perspective-project associations
    (persp--load-perspective-projects)
    ;; Save perspective-project associations on exit
    (add-hook 'kill-emacs-hook #'persp--save-perspective-projects))
  ;; Override the default persp-switch binding to use our enhanced version
  ;; that includes saved perspectives in the completion list
  (define-key perspective-map (kbd "s") 'persp-switch-with-saved))

;; Recommendation from the perspective page to reduce the
;; amount of window-splitting
(customize-set-variable 'display-buffer-base-action
  '((display-buffer-reuse-window display-buffer-same-window)
    (reusable-frames . t)))
(customize-set-variable 'even-window-sizes nil)     ; avoid resizing

;; Optional: integrate with switch-to-buffer to show perspective-aware buffer list
(global-set-key (kbd "C-x C-b") (lambda (arg)
                                  (interactive "P")
                                  (if (fboundp 'persp-bs-show)
                                      (persp-bs-show arg)
                                    (bs-show "all"))))

(provide 'perspective-settings)
;;; perspective-settings.el ends here

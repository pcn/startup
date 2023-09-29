;;; package --- Summary
;;; Make org-mode a bit easier to use for multi-day/multi-project workflows

;;; Commentary:
;;; Starting with https://orgmode.org/worg/org-tutorials/org-meeting-tasks.html
;;;

;;; Code:




;; Code from  https://orgmode.org/worg/org-tutorials/org-meeting-tasks.html
(defcustom org-mactions-numbered-action-format "TODO Action #%d "
  "Default structure of the headling of a new action.
    %d will become the number of the action."
  :group 'org-edit-structure
  :type 'string)

(defcustom org-mactions-change-id-on-copy t
  "Non-nil means make new IDs in copied actions.
If an action copied with the command `org-mactions-collect-todos-in-subtree'
contains an ID, that ID will be replaced with a new one."
  :group 'org-edit-structure
  :type 'string)

(defun org-mactions-new-numbered-action (&optional inline)
  "Insert a new numbered action, using `org-mactions-numbered-action-format'.
    With prefix argument, insert an inline task."
  (interactive "P")
  (let* ((num (let ((re "\\`#\\([0-9]+\\)\\'"))
                (1+ (apply 'max 0
                           (mapcar
                            (lambda (e)
                              (if (string-match re (car e))
                                  (string-to-number (match-string 1 (car e)))
                                0))
                            (org-get-buffer-tags))))))
         (tag (concat "#" (number-to-string num))))
    (if inline
        (org-inlinetask-insert-task)
      (org-insert-heading 'force))
    (unless (eql (char-before) ?\ ) (insert " "))
    (insert (format org-mactions-numbered-action-format num))
    (org-toggle-tag tag 'on)
    (if (= (point-max) (point-at-bol))
        (save-excursion (goto-char (point-at-eol)) (insert "\n")))
    (unless (eql (char-before) ?\ ) (insert " "))))

(defun org-mactions-collect-todos-in-subtree ()
  "Collect all TODO items in the current subtree into a flat list."
  (interactive)
  (let ((buf (get-buffer-create "Org TODO Collect"))
        (cnt 0) beg end string s)
    (with-current-buffer buf (erase-buffer) (org-mode))
    (org-map-entries
     (lambda ()
       (setq beg (point) end (org-end-of-subtree t t) cnt (1+ cnt)
             string (buffer-substring beg end)
             s 0)
       (when org-mactions-change-id-on-copy
         (while (string-match "^\\([ \t]*:ID:\\)[ \t\n]+\\([^ \t\n]+\\)[ \t]*$"
                              string s)
           (setq s (match-end 1)
                 string (replace-match (concat "\\1 "
                                               (save-match-data (org-id-new)))
                                       t nil string))))
       (with-current-buffer buf (org-paste-subtree 1 string)
                            (goto-char (point-max))))
     (format "TODO={%s}" (regexp-opt org-not-done-keywords))
     'tree)
    (if (= cnt 0)
        (message "No TODO items in subtree")
      (message "%d TODO entries copied to kill ring" cnt)
      (prog1 (with-current-buffer buf
               (kill-new (buffer-string)))
        (kill-buffer buf)))))


;; TODO: an org-mode settings file 
;; org-mode configuration based on
;; Recommended by https://orgmode.org/manual/Activation.html
(global-set-key (kbd "C-c o l") 'org-store-link)
(global-set-key (kbd "C-c o a") 'org-agenda)
(global-set-key (kbd "C-c o c") 'org-capture)

(use-package org
  :after (counsel)  ;; leaning on counsel functions for indexes
  :general
  (:keymaps 'org-mode-map
            "C-c n n" 'org-mactions-new-numbered-action
            "C-c l l h" 'counsel-org-link) ;; work with IDs and links better, from https://zzamboni.org/post/how-to-easily-create-and-use-human-readable-ids-in-org-mode-and-doom-emacs/
  :config
  (setq org-directory "~/Dropbox/Orgmode" )
  (setq org-return-follows-link t)
  (setq org-todo-keywords '((sequence "TODO" "WAITING" "DOING" "|" "DONE" "WONTDO" "TOOLATE"))))


(use-package emacsql)

(use-package emacsql-sqlite )

;; Also try to do org-roam for bidirectional links?
(use-package org-roam
  ;; :ensure t
  ;;:after (org)
  :init
  ;; Avoid the v1->v2 upgrade messages
  (setq org-roam-v2-ack t)  
  :custom
  (org-roam-directory (file-truename "~/Dropbox/Orgmode/org-roam"))
  (org-roam-completion-everywhere t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n x" . org-insert-todo-heading)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today)
         :map org-mode-map
         ("C-M-i" . completion-at-point)  ;; Seems about the same as 
         )
  :config
  (org-roam-setup)
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol))

;; This intereferes with rustic first intializing in a way that brings up the org agenda
;; instead of the main rust file I'm trying to load up. Ick.
;; (use-package org-super-agenda
;;   :after (org)
;;   :init
;;   (org-agenda-list))


(setq org-tag-alist '(("@work" . ?w) ("@home" . ?h) ("NETLIFY_RELIABILITY" .  ?r)))
(setq org-agenda-files (file-truename "~/Dropbox/Orgmode/agenda-files"))
(setq org-agenda-time-grid '((daily today require-timed) "----------------------" nil)
      org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-include-deadlines t
      org-agenda-include-diary t
      org-agenda-block-separator nil
      org-agenda-compact-blocks t
      org-agenda-start-with-log-mode t)

(setq org-agenda-custom-commands
      '(("z" "Super zaen view"
         ((agenda "" ((org-agenda-span 'day)
                      (org-super-agenda-groups
                       '((:name "Today"
                                :time-grid t
                                :date today
                                :todo "TODAY"
                                :scheduled today
                                :order 1)))))
          (alltodo "" ((org-agenda-overriding-header "")
                       (org-super-agenda-groups
                        '((:name "Next to do"
                                 :todo "NEXT"
                                 :order 1)
                          (:name "Important"
                                 :tag "Important"
                                 :priority "A"
                                 :order 6)
                          (:name "Due Today"
                                 :deadline today
                                 :order 2)
                          (:name "Due Soon"
                                 :deadline future
                                 :order 8)
                          (:name "Overdue"
                                 :deadline past
                                 :order 7)
                          (:name "Issues"
                                 :tag "Issue"
                                 :order 12)
                          (:name "Projects"
                                 :tag "Project"
                                 :order 14)
                          (:name "Research"
                                 :tag "Research"
                                 :order 15)
                          (:name "To view"
                                 :tag "View"
                                 :order 30)
                          (:name "Waiting"
                                 :todo "WAITING"
                                 :order 20)
                          (:name "trivial"
                                 :priority<= "C"
                                 :tag ("Trivial" "Unimportant")
                                 :todo ("SOMEDAY" )
                                 :order 90)
                          (:discard (:tag ("Chore" "Routine" "Daily")))))))))))




(provide 'org-mode-settings)
;;; org-mode-settings.el ends here

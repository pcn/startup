;;; package --- Summary
;;; Settings for using github copilot and other ai coding assist tools

;;; Commentary:
;;; Use a module to LLMs in emacs


;;; Code:

;;; First, use elpaca to define the copilot.el package since it's not avialable from elpa or melpa.

;; (elpaca-recipe '(copilot :inherit t :source "https://github.com/copilot-emacs/copilot.el"))


; When using company, 
; complete by copilot first, then company-mode
;; (defun my-company-tab ()
;;   (interactive)
;;   (or (copilot-accept-completion)
;;       (company-indent-or-complete-common nil)))

;; When using corfu, the same?
(defun my-corfu-tab ()
  (interactive)
  (if (copilot-suggestion-available-p)
      (corfu-complete)))

(defun _my-corfu-tab ()
  (interactive)
  (or (copilot-accept-completion)
      (corfu-next)))


;; With help from teh AIs.
(defun my/copilot-tab-fallback ()
  "Try to complete with copilot first, falling back to default tab behavior if no completion is available."
  (interactive)
  (or (copilot-accept-completion)
      (let ((tab-binding (keymap-lookup (current-active-maps) (kbd "TAB"))))
        ;; Ensure we don't call ourselves recursively
        (when (and tab-binding (not (eq tab-binding 'my/copilot-tab-fallback)))

          (call-interactively tab-binding)))))

;; Get a newer track-changes than what's included in emacs
;; copilot wants track-changes version 1.4 or newer, and I guess that
(elpaca (track-changes :host elpa)
  (use-package track-changes))


(elpaca (copilot :host github :repo "copilot-emacs/copilot.el"
                 :files ("*.el")
                 :protocol ssh)
  (use-package copilot
    :hook prog-mode
    :config
    (setq copilot-indent-offset-warning-disable t)    
    (defun my/copilot-complete-or-accept ()
      "Command that either triggers a completion or falls back o standard tab indentation."
      (interactive)
    (unless (and copilot-mode (copilot-accept-completion))
        (indent-for-tab-command)))
    
    :general
    (:keymaps 'prog-mode-map
              "TAB" 'my/copilot-complete-or-accept)))


(elpaca (eat :host codeberg :repo "akib/emacs-eat" :wait t)
  (use-package eat
    :hook
    (eat-mode . (lambda () (display-line-numbers-mode -1)))))


;; When using this in a terminal, C-c C-e invokes the emacs-eat terminal's
;; ability to drop out of terminal mode for e.g. copying text using emacs'
;; normal keystrokes. It calls this "emacs" input mode.
;; To resume the normal "char" input mode that claude-code expsects, use C-c M-d
(elpaca (claude-code-ide :host github :repo "manzaltu/claude-code-ide.el" :wait t)
  (use-package claude-code-ide
    :config
    (claude-code-ide-emacs-tools-setup)
    (setq claude-code-ide-terminal-backend 'eat)
    (setq claude-code-ide-focus-claude-after-ediff nil)
    ;; Theoretically keep ediff control buffer in the same frmae
    (setq ediff-window-setup-function 'ediff-setup-windows-plain)
    ;; Dn't create a seprate buffer for the control frame
    (setq ediff-control-frame-parameters nil)
    (global-auto-revert-mode 1)
    (defun claude-code-ide-restart-session ()
      "Stop current Claude Code session and resume it.
Compensates for the terminal reflow glitch (upstream bug #826) by
restarting the CLI process with a fresh terminal state."
      (interactive)
      (if (claude-code-ide--has-active-session-p)
          (let ((working-dir (claude-code-ide--get-working-directory)))
            (claude-code-ide-stop)
            (run-with-timer 0.5 nil
                            (lambda ()
                              (let ((default-directory working-dir))
                                (claude-code-ide-resume)))))
        (message "No active Claude Code session to restart")))
    (transient-append-suffix 'claude-code-ide-menu "q"
      '("R" "Restart session (stop + resume)" claude-code-ide-restart-session))
    :general
    (:keymaps 'global
                  "C-c C-'" 'claude-code-ide-menu)))


;; ;; ECA is a different way of interacting with/using editor plugins
;; ;; Summary: don't like it
;; (elpaca (eca-emacs :host github :repo "editor-code-assistant/eca-emacs" :wait t)
;;   (use-package eca-emacs))

;; For agent-shell https://github.com/xenodium/agent-shell
(elpaca (shell-maker :host github :repo "xenodium/shell-maker" :wait t)
  (use-package shell-maker))

(elpaca (acp :host github :repo "xenodium/acp.el" :wait t)
  (use-package acp))

(elpaca (agent-shell :host github :repo "xenodium/agent-shell" :wait t :depends-on (shell-maker acp))  
  (use-package agent-shell
    :ensure-system-package
    ((claude . "npm install -g @anthropic-ai/claude-code")
     (claude-code-acp . "npm install -g @zed-industries/claude-code-acp"))
    :config
    ;; I'm trying this to anticipate needing tools like npm which I install with asdf
    (setq agent-shell-make-environment-variables (agent-shell-make-environment-variables :inherit-env t))
    (setq agent-shell-anthropic-authentication (agent-shell-anthropic-make-authentication :login t))
    ;; Shell-maker config
    (shell-maker-define-major-mode
     'agent-shell-anthropic-claude-code-major-mode
     "agent-shell-anthropic-claude-code"
     (agent-shell-anthropic-claude-code-make-shell-maker-config))
    ))



(elpaca dimmer
  (use-package dimmer
    :config
    (dimmer-mode 1)
    (dimmer-configure-magit)
    (dimmer-configure-org)
    (dimmer-configure-which-key)
    (setq dimmer-fraction 0.3)
    (let ((dimmer-mode-on-p))
      (add-hook 'ediff-before-setup-hook
                (lambda ()
                  (setq dimmer-mode-on-p dimmer-mode)
                  (dimmer-mode (if dimmer-mode-on-p 0 1))))
      (add-hook 'ediff-cleanup-hook
                (lambda ()
                  (dimmer-mode (if dimmer-mode-on-p 1 0)))))))



(elpaca (gemini-cli :host github :repo "linchen2chris/gemini-cli.el" :wait t)
  (use-package gemini-cli
    :config
    (gemini-cli-mode)
    :general
    (:keymaps 'global
                  "C-c g" 'gemini-cli-command-map)))



;; This binds audio recording and transcription! It can be
;; used with claude-code-ide!
(elpaca (whisper :host github :repo "natrys/whisper.el" :wait t)
  (use-package whisper
    :bind ("C-c M-l" . whisper-run)  ;; mnemonic: C'Mere, listen
    :config
    (setq
     whisper-install-directory "~/.local/share/whisper"
     whisper-model "base"
     whisper-language "en"
     whsiper-translate nil
     whisper-use-threads (/ (num-processors) 4))))



;; (elpaca agent-shell
;;   (use-package agent-shell
;;     :ensure-system-package
;;     ;; Add agent installation configs here
;;     ((claude . "npm install -g @anthropic-ai/claude-code")
;;      (claude-code-acp . "npm install -g @zed-industries/claude-code-acp"))))
         

;; ;; star test
;; ;; Make the ediff buffer more noticiable for claude-code-id
;; (defvar-local my-ediff-control-overlay nil)

;; (defun my-ediff-control-focus-change ()
;;   (when (and (boundp 'ediff-control-buffer) 
;;              (buffer-live-p ediff-control-buffer))
;;     (with-current-buffer ediff-control-buffer
;;       (when my-ediff-control-overlay
;;         (delete-overlay my-ediff-control-overlay))
      
;;       (setq my-ediff-control-overlay (make-overlay (point-min) (point-max)))
      
;;       (let ((is-focused (eq (selected-window) (get-buffer-window))))
;;         (overlay-put my-ediff-control-overlay 'face 
;;                     (if is-focused
;;                         '(:background "red")
;;                       '(:background "green")))
        
;;         ;; Fill the rest of the window
;;         (overlay-put my-ediff-control-overlay 'after-string
;;                     (propertize (make-string 50 ?\n) 
;;                               'face (if is-focused
;;                                       '(:background "red")
;;                                     '(:background "green"))))))))

;; ; modify company-mode behaviors
;; (with-eval-after-load 'company
;;   ; disable inline previews
;;   (delq 'company-preview-if-just-one-frontend company-frontends)
;;                                         ; enable tab completion
;;   (define-key company-mode-map (kbd "<tab>") 'my-company-tab)
;;   (define-key company-mode-map (kbd "TAB") 'my-company-tab)
;;   (define-key company-active-map (kbd "<tab>") 'my-company-tab)
;;   (define-key company-active-map (kbd "TAB") 'my-company-tab) )


;; More configuration from https://github.com/rksm/copilot-emacsd/blob/master/init.el

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

;; (defun rk/copilot-tab ()
;;   "Tab command that will complet with copilot if a completion is
;; available. Otherwise will try company, yasnippet or normal
;; tab-indent."
;;   (interactive)
;;   (or (copilot-accept-completion)
;;       (company-yasnippet-or-completion)
;;       (indent-for-tab-command)))

;; (defun rk/copilot-complete-or-accept ()
;;   "Command that either triggers a completion or accepts one if one
;; is available. Useful if you tend to hammer your keys like I do."
;;   (interactive)
;;   (if (copilot--overlay-visible)
;;       (progn
;;         (copilot-accept-completion)
;;         (open-line 1)
;;         (next-line))
;;     (copilot-complete)))

;; (defun rk/copilot-quit ()
;;   "Run `copilot-clear-overlay' or `keyboard-quit'. If copilot is
;; cleared, make sure the overlay doesn't come back too soon."
;;   (interactive)
;;   (condition-case err
;;       (when copilot--overlay
;;         (lexical-let ((pre-copilot-disable-predicates copilot-disable-predicates))
;;           (setq copilot-disable-predicates (list (lambda () t)))
;;           (copilot-clear-overlay)
;;           (run-with-idle-timer
;;            1.0
;;            nil
;;            (lambda ()
;;              (setq copilot-disable-predicates pre-copilot-disable-predicates)))))
;;     (error handler)))

;; (defun rk/copilot-complete-if-active (next-func n)
;;   (let ((completed (when copilot-mode (copilot-accept-completion))))
;;     (unless completed (funcall next-func n))))

;; (defun rk/no-copilot-mode ()
;;   "Helper for `rk/no-copilot-modes'."
;;   (copilot-mode -1))

;; (defvar rk/no-copilot-modes '(shell-mode
;;                               inferior-python-mode
;;                               eshell-mode
;;                               term-mode
;;                               vterm-mode
;;                               comint-mode
;;                               compilation-mode
;;                               debugger-mode
;;                               dired-mode-hook
;;                               compilation-mode-hook
;;                               flutter-mode-hook
;;                               minibuffer-mode-hook)
;;   "Modes in which copilot is inconvenient.")

;; (defvar rk/copilot-manual-mode nil
;;   "When `t' will only show completions when manually triggered, e.g. via M-C-<return>.")

;; (defvar rk/copilot-enable-for-org nil
;;   "Should copilot be enabled for org-mode buffers?")



;; (defun rk/copilot-enable-predicate ()
;;   ""
;;   (and
;;    (eq (get-buffer-window) (selected-window))))

;; (defun rk/copilot-disable-predicate ()
;;   "When copilot should not automatically show completions."
;;   (or rk/copilot-manual-mode
;;       (member major-mode rk/no-copilot-modes)
;;       (and (not rk/copilot-enable-for-org) (eq major-mode 'org-mode))
;;       (company--active-p)))

;; (defun rk/copilot-change-activation ()
;;   "Switch between three activation modes:
;; - automatic: copilot will automatically overlay completions
;; - manual: you need to press a key (M-C-<return>) to trigger completions
;; - off: copilot is completely disabled."
;;   (interactive)
;;   (if (and copilot-mode rk/copilot-manual-mode)
;;       (progn
;;         (message "deactivating copilot")
;;         (global-copilot-mode -1)
;;         (setq rk/copilot-manual-mode nil))
;;     (if copilot-mode
;;         (progn
;;           (message "activating copilot manual mode")
;;           (setq rk/copilot-manual-mode t))
;;       (message "activating copilot mode")
;;       (global-copilot-mode))))

;; (defun rk/copilot-toggle-for-org ()
;;   "Toggle copilot activation in org mode. It can sometimes be
;; annoying, sometimes be useful, that's why this can be handly."
;;   (interactive)
;;   (setq rk/copilot-enable-for-org (not rk/copilot-enable-for-org))
;;   (message "copilot for org is %s" (if rk/copilot-enable-for-org "enabled" "disabled")))

;; ;; load the copilot package
;; ;; (elpaca (copilot :host github :repo "copilot-emacs/copilot.el"
;; ;;                  :files ("*.el")
;; ;;                  :protocol ssh)
;; ;;   (use-package copilot
;; ;;     ;; :load-path (lambda () (expand-file-name "copilot.el" user-emacs-directory))

;; ;;     ;;   :diminish ;; don't show in mode line (we don't wanna get caught cheating, right? ;)

;; ;;   :config
;; ;;   ;; keybindings that are active when copilot shows completions
;; ;;   (define-key copilot-mode-map (kbd "M-C-<next>") #'copilot-next-completion)
;; ;;   (define-key copilot-mode-map (kbd "M-C-<prior>") #'copilot-previous-completion)
;; ;;   (define-key copilot-mode-map (kbd "M-C-<right>") #'copilot-accept-completion-by-word)
;; ;;   (define-key copilot-mode-map (kbd "M-C-<down>") #'copilot-accept-completion-by-line)

;; ;;   ;; global keybindings
;; ;;   (define-key global-map (kbd "M-C-<return>") #'rk/copilot-complete-or-accept)
;; ;;   (define-key global-map (kbd "M-C-<escape>") #'rk/copilot-change-activation)

;; ;;   ;; Do copilot-quit when pressing C-g
;; ;;   (advice-add 'keyboard-quit :before #'rk/copilot-quit)

;; ;;   ;; complete by pressing right or tab but only when copilot completions are
;; ;;   ;; shown. This means we leave the normal functionality intact.
;; ;;   (advice-add 'right-char :around #'rk/copilot-complete-if-active)
;; ;;   (advice-add 'indent-for-tab-command :around #'rk/copilot-complete-if-active)

;; ;;   ;; deactivate copilot for certain modes
;; ;;   (add-to-list 'copilot-enable-predicates #'rk/copilot-enable-predicate)
;; ;;   (add-to-list 'copilot-disable-predicates #'rk/copilot-disable-predicate)))

;; ;; ;; (eval-after-load 'copilot
;; ;; ;;   '(progn
;; ;; ;;      ;; Note company is optional but given we use some company commands above
;; ;; ;;      ;; we'll require it here. If you don't use it, you can remove all company
;; ;; ;;      ;; related code from this file, copilot does not need it.
;; ;; ;;      (require 'company)
;; ;; ;;      (global-copilot-mode)))

;; ;; ;; (copilot-login)

(provide 'copilot-settings)
;;; copilot-settings.el ends here



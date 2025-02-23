;;; package --- Summary
;;; My early settings for miscaleanous things

;;; Commentary:
;;;
;;; Try to have the 'use-package' package do as much work as possible and experiment with elpaca
;;; 

;;; Summary:
;;;
;;; Settings that should happen early, but which also should be wrapped up so elpaca-use-package defers it

;;; Code:

;; Put backup files in ~ not in the directory being worked in
(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
  backup-by-copying t    ; Don't delink hardlinks
  version-control t      ; Use version numbers on backups
  delete-old-versions t  ; Automatically delete excess backups
  kept-new-versions 20   ; how many of the newest versions to keep
  kept-old-versions 5)    ; and how many of the old
  

;; Default to not using tabs at all
(setq-default indent-tabs-mode nil)

;; Move the customizations into a file in the settings dir. I am not using the ".el" extension
;; because I tried to use parinfer-rust and that broke, so I don't want to try to use it again.
(setq custom-file (expand-file-name "~/.emacs.d/settings/custom-settings"))
(add-hook 'elpaca-after-init-hook (lambda () (load custom-file)))


;; Fira has become a pita; the glyphs it provides just don't seem to be useful 90% of the time
;; Note- set the fira font in ~/.fonts via instructions in
;; https://github.com/johnw42/fira-code-emacs/blob/master/fira-code.el
;; the use of the custom ligatures need to be activated via `fira-code-mode`
;; in individual buffers unless/until I make it automatic
;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(default ((t (:weight normal :width normal :family "FiraEmacs")))))


;; https://orgmode.org/worg/org-tutorials/org4beginners.html
;; Set to f if I want the splash screen for some reason.
(setq inhibit-splash-screen t)
(transient-mark-mode 1)

;;; Use C-c left/right to undo/redo window splits etc.
(winner-mode 1)

;; I want general to do lazy binding of keys with use-package
(elpaca (general :host github :repo "noctuid/general.el" :wait t)
        (use-package general
  :ensure t
;; As of 2025-02-21 it seems like this allows general to be loaded before more use-package forms are evaluated
  :demand t ))


;; (elpaca-wait)  ;; general adds a keyword to use-package, so I want it to be loaded before I try to use it with use-package, I think


;; TODO: move these to the development settings file, and use-package
;; (use-package rainbow-delimiters
;;   ;;  :ensure t
;;   :config 
;;   (add-hook 'prog-mode-hook rainbow-delimiters-mode)
;;   )


;; (add-hook 'after-init-hook 'global-company-mode)

;; Always run terraform fmt from now on
(elpaca terraform-mode (use-package terraform-mode
;;  :;; ensure t
  :config
  (add-hook 'terraform-mode-hook #'terraform-format-on-save-mode)))

;; end
(elpaca rg (use-package rg
  ;; :ensure t
  :config
  (rg-enable-menu)))


;; High-dpi screen means long nyan bar

;; (use-package nlinum
;;   :config
;;   (nlinum-mode t))

(global-display-line-numbers-mode 1)

(elpaca nyan-mode (use-package nyan-mode
  ;; :ensure t
  :init
  (setq nyan-animate-nyancat t)
  (setq nyan-bar-length 30)
  (setq nyan-wavy-trail t)
  :config
  (nyan-mode)))

;; Windmove allows for shift-arrow key moving around windows on the screen
;; (windmove-default-keybindings)

;; ask vc/magit/whatever to show branches in the modeline
(setq auto-revert-check-vc-info t)

;; Salt states mode
;; (use-package 'mmm-auto
;;   :ensure t)
;; (setq mmm-global-mode 'auto)
;; (add-to-list
;;  ;;; Something for saltstack,
;;  ;;; Though it would be worthwhile to look for the special python
;;  ;;; modes we use for some things
;;  'auto-mode-alist '("\\.sls\\'" . yaml-mode))
;; (mmm-add-mode-ext-class 'html-mode "\\.sls\\'" 'mako)


;; (use-package counsel-projectile
;;   ;; :ensure t
;;   :config
;;   (counsel-projectile-mode))

;; (use-package persp-projectile
;;   ;; :ensure t
;;   )
  

;; (use-package perspective
;;   ;; :ensure t
;;   :init (persp-mode)
;;   ;; :config
;;   ;; ;; Let's try perspectives again.
;;   ;; ;; From https://medium.com/@cmacrae/emacs-making-neotree-work-with-perspectives-964638b5666e
;;   ;; (defun my/persp-neo ()
;;   ;;   "Make neotree follow the perspective"
;;   ;;   (interactive)
;;   ;;   (let ((cw  (selected-window))
;;   ;;         (path (buffer-file-name))) ;;; save current window/buffer
;;   ;;     (progn
;;   ;;       (when (and (fboundp 'projectile-project-p)
;;   ;;                  (projectile-project-p)
;;   ;;                  (fboundp 'projectile-project-root))
;;   ;;         (neotree-dir (projectile-project-root)))
;;   ;;       (neotree-find-path) ;; Should this be neotree-find? )
;;   ;;     (select-window cw)))
;;   ;; :hook
;;   ;; (persp-switch . my/persp-neo))
;;   )

;; ;; Recommendation from the perspective page to reduce the
;; ;; amount of window-splitting
;; (customize-set-variable 'display-buffer-base-action
;;   '((display-buffer-reuse-window display-buffer-same-window)
;;     (reusable-frames . t)))
;; (customize-set-variable 'even-window-sizes nil)     ; avoid resizing

;; Just a note that using perspective/persp-mode handles keeping different window layouts
;; available
;; See https://github.com/nex3/perspective-el
;; (use-package perspective
;;   :config
;;   (persp-mode)
;;   (global-set-key (kbd "C-x C-b") (lambda (arg)
;;                                   (interactive "P")
;;                                   (if (fboundp 'persp-bs-show)

;;                                       1(persp-bs-show arg)
;;                                     (bs-show "all")))))



;; (require 'yasnippet)

;; (add-to-list 'yas-snippet-dirs "~/.live-packs/spacey-pack/snippets")
;; (yas-global-mode 1)

;; pyenv support for working with salt, maybe others?
;; This is at the top so that e.g. aws can be found
;; when using kubernetes mode
;; (use-package pyenv-mode-auto
;;   :requires pyenv-mode)
;; (use-package pyenv-mode)

;; (defun projectile-pyenv-mode-set ()
;;   "Set pyenv version matching project name."
;;   (let ((project (projectile-project-name)))
;;     (if (member project (pyenv-mode-versions))for
;;         (pyenv-mode-set project)
;;       (pyenv-mode-unset))))

;; (add-hook 'projectile-switch-project-hook 'projectile-pyenv-mode-set)

;; More projectile configuration for neotree this time
;; from  https://www.emacswiki.org/emacs/NeoTree#h5o-8
(setq projectile-switch-project-action 'projectile-find-file)



;; 
;; Optionally
;; Use the solarized theme
;; (load-theme 'solarized t)
;; (add-hook 'after-init-hook (lambda () (load-theme 'solarized)))
;; (setq frame-background-mode 'dark)

(global-set-key (kbd "C-x g") 'magit-status)

;; Turn a buffer of filenames into a dired buffer for creating a "workspace"
(defun dired-virtual-vanilla ()
  (interactive)
  (dired (cons "*Dired*" (split-string (buffer-string) "\n" t))))

;; auto-yasnippet to do some good stuff
;; https://github.com/abo-abo/auto-yasnippet
(global-set-key (kbd "C-c a y w") #'aya-create)
(global-set-key (kbd "C-c a y y") #'aya-expand)


;; I want yasnippet to insert snippets that I store in a project so I
;; can follow the local idiom of a book that I'm learning from.
;; Found at https://www.reddit.com/r/emacs/comments/57i41t/projectlocal_snippets/daw67dd/
(setq crshd--default-yas-snippet-dirs
      '((expand-file-name "~/.emacs.d/snippets/")
        yas-installed-snippets-dir
        (expand-file-name "~/etc/emacs/layers/+completion/auto-completion/local/snippets")
        (expand-file-name "~/etc/spacemacs/snippets")))

(defun crshd/set-projectile-yas-dir ()
  "Append a projectile-local YAS snippet dir to yas-snippet-dirs."
  (interactive)
  (let ((local-yas-dir (concat (projectile-project-root) ".snippets")))
    (setq yas-snippet-dirs (cons local-yas-dir
                                 crshd--default-yas-snippet-dirs))))

(add-hook 'projectile-find-file-hook 'crshd/set-projectile-yas-dir)


;; Use copmany to pop up yasnippets
(global-set-key (kbd "C-c a c y") #'yas-insert-snippet)
(global-set-key (kbd "C-c a c e") #'yas-expand)


;; Golang setup per https://github.com/cockroachdb/cockroach/wiki/Ben%27s-Go-Emacs-setup

;; (setq exec-path '("/home/spacey/.cargo/bin" "/home/spacey/bin" "/opt/OpenPrinting-Gutenprint/sbin" "/opt/OpenPrinting-Gutenprint/bin" "/usr/local/sbin" "/usr/local/bin" "/usr/sbin" "/usr/bin" "/sbin" "/bin" "/usr/games" "/usr/local/games" "/snap/bin" "/home/spacey/bin" "/home/spacey/bin" "/home/spacey/.emacs.d/gotools/bin" "/home/spacey/bin" "/home/spacey/go/bin" "/home/spacey/bin" "/home/spacey/go/bin" "/home/spacey/bin" "/home/spacey/go/bin" "/usr/lib/emacs/25.2/x86_64-linux-gnu"))
; As-you-type error highlighting
;; (add-hook 'after-init-hook #'global-flycheck-mode)
(setq-default indent-tabs-mode nil)

;; Using i3wm means that I don't get my global default ssh-agent vars.
;; Enter https://emacs.stackexchange.com/questions/17866/magit-how-to-use-systems-ssh-agent-and-dont-ask-for-password
;; exec-path-from-shell
(elpaca exec-path-from-shell
  ;; :ensure t
  (exec-path-from-shell-copy-env "SSH_AGENT_PID")
  (exec-path-from-shell-copy-env "SSH_AUTH_SOCK")
  )


;; ace-window for making switching windows easier and faster
(elpaca ace-window (use-package ace-window
  ;; :ensure t
  ))
(global-set-key (kbd "M-o") 'ace-window)

(server-start)

(global-set-key (kbd "C-c <C-tab>") 'nswbuff-switch-to-previous-buffer)
(global-set-key (kbd "C-c <C-iso-lefttab>") 'nswbuff-switch-to-next-buffer)

;; Load fira-mode from .emacs.d, which should be a symlink from a clone of the repo
;; Tell emacs where your personal elisp lib dir is
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/"))
;; (add-to-list 'load-path "/home/spacey/emacs/27.1/share/emacs/27.1/lisp/org")
;; load the packaged named xyz.
;; (load "fira-code") ;; best not to include the ending “.el” or “.elc”
;; (load "git-timemachine")

(elpaca smart-tab (use-package smart-tab))


;; (add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/general.el"))
;; (require 'general)

(elpaca git-link (use-package git-link))
(elpaca git-timemachine (use-package git-timemachine))


(elpaca inkpot-theme 
  (use-package inkpot-theme
    :demand t
    :config
    (load-theme 'inkpot t )))

;; (add-hook 'elpaca-after-init-hook (lambda () (load-theme 'inkpot t)))

;; TODO: Change this to using the python-mode hooks in the python configuration
(defun whitespace-sucks ()
  "Do a whitespace cleanup on python code, maybe other modes too?."
  (interactive)
  (when (eq major-mode 'python-mode)
    (whitespace-cleanup)))

;; (defun my-previous-window ()
;;   "Select the previous window, the opposite of other-window"
;;   (interactive)
;;   (other-window -1))
;; (global-set-key (kbd "C-M-x o") my-previous-window)


;; https://emacs.stackexchange.com/questions/3458/how-to-switch-between-windows-quickly
(windmove-default-keybindings 'meta) ;; Note - I almost never make use of this.

    
(add-hook 'after-save-hook #'whitespace-sucks)
;; Do not let C-z do the usual thing it does
(put 'suspend-frame 'disabled t)



(elpaca dumb-jump (use-package dumb-jump
  :hook (xref-backend-functions . dumb-jump-xref-activate)))


(elpaca eterm-256color (use-package eterm-256color
  :hook (term-mode . eterm-256color-mode)))

;; ;; popper to help with popup buffers, from https://github.com/karthink/popper
;; (use-package popper
;;   :ensure t ; or :straight t
;;   :bind (("C-`"   . popper-toggle-latest)
;;          ("M-`"   . popper-cycle)
;;          ("C-M-`" . popper-toggle-type))
;;   :init
;;   (setq popper-reference-buffers
;;         '("\\*Messages\\*"
;;           "Output\\*$"
;;           "\\*Async Shell Command\\*"
;;           help-mode
;;           compilation-mode))
;;   (popper-mode +1)
;;   (popper-echo-mode +1))  
;; ;; https://www.emacswiki.org/emacs/TrampMode

(elpaca dirvish (use-package dirvish
  :config
  (dirvish-override-dired-mode)))


(provide 'early-misc)
;;; lsp-settings.el ends here

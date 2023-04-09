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

;; Note- set the fira font in ~/.fonts via instructions in
;; https://github.com/johnw42/fira-code-emacs/blob/master/fira-code.el
;; the use of the custom ligatures need to be activated via `fira-code-mode`
;; in individual buffers unless/until I make it automatic
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:weight normal :width normal :family "FiraEmacs")))))


;; https://orgmode.org/worg/org-tutorials/org4beginners.html
;; Set to f if I want the splash screen for some reason.
(setq inhibit-splash-screen t)
(transient-mark-mode 1)

;;; Use C-c left/right to undo/redo window splits etc.
(winner-mode 1)

;; TODO: move these to the development settings file, and use-package
(use-package rainbow-delimiters
;;  :ensure t
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
  )


;; (add-hook 'after-init-hook 'global-company-mode)

;; Always run terraform fmt from now on
(use-package terraform-mode
;;  :;; ensure t
  :config
  (add-hook 'terraform-mode-hook #'terraform-format-on-save-mode))

;; end
(use-package rg
  ;; :ensure t
  :config
  (rg-enable-menu))


;; High-dpi screen means long nyan bar

(use-package nlinum
  ;; :ensure t
  :config
  (nlinum-mode t))
(use-package nyan-mode
  ;; :ensure t
  :init
  (setq nyan-animate-nyancat t)
  (setq nyan-bar-length 30)
  (setq nyan-wavy-trail t)
  :config
  (nyan-mode))

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


(use-package counsel-projectile
  ;; :ensure t
  :config
  (counsel-projectile-mode))

(use-package persp-projectile
  ;; :ensure t
  )
  

(use-package perspective
  ;; :ensure t
  :init (persp-mode)
  :config
  ;; Let's try perspectives again.
  ;; From https://medium.com/@cmacrae/emacs-making-neotree-work-with-perspectives-964638b5666e
  (defun my/persp-neo ()
    "Make neotree follow the perspective"
    (interactive)
    (let ((cw  (selected-window))
          (path (buffer-file-name))) ;;; save current window/buffer
      (progn
        (when (and (fboundp 'projectile-project-p)
                   (projectile-project-p)
                   (fboundp 'projectile-project-root))
          (neotree-dir (projectile-project-root)))
        (neotree-find-path) ;; Should this be neotree-find? )
      (select-window cw)))
  :hook
  (persp-switch . my/persp-neo)))

;; Recommendation from the perspective page to reduce the
;; amount of window-splitting
(customize-set-variable 'display-buffer-base-action
  '((display-buffer-reuse-window display-buffer-same-window)
    (reusable-frames . t)))
(customize-set-variable 'even-window-sizes nil)     ; avoid resizing

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
(setq projectile-switch-project-action 'neotree-projectile-action)



;; flycheck with pycheckers to enable checking.
(use-package flycheck
  ;; :ensure t
  (setq global-flycheck-mode 1)
  )
(with-eval-after-load 'flycheck
      (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)))

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


;; Paren
(setq show-paren-mode 1)
(setq show-paren-delay 0)
(show-paren-mode)

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
(use-package ace-window
  ;; :ensure t
  )
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

(use-package smart-tab
  ;; :ensure t
  )

;; I want general to do lazy binding of keys with use-package
(use-package general
  ;; :ensure t
  )

;; (add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/general.el"))
;; (require 'general)

(use-package git-link
  ;; :ensure t
  )
(use-package git-timemachine
  ;; :ensure t
  )

;; (use-package flatui-theme :ensure :defer)
;; (use-package nyx-theme :ensure :defer)
;; (use-package zenburn-theme :ensure t :defer)
;; (use-package afternoon-theme :ensure t :defer)
;; (load-theme 'afternoon t)
;; (add-hook 'after-init-hook (lambda () (load-theme 'afternoon)))


(use-package inkpot-theme
  ;; :ensure t
  )
(add-hook 'elpaca-after-init-hook (lambda () (load-theme 'inkpot t)))

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
(windmove-default-keybindings 'meta)

    
(add-hook 'after-save-hook #'whitespace-sucks)
;; ;;; Treemacs config as of 2019-12-06
;; ;;; this is everything at the defaults from https://github.com/Alexander-Miller/treemacs
;; (use-package treemacs
;;   :ensure t
;;   :defer t
;;   :init
;;   (with-eval-after-load 'winum
;;     (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
;;   :config
;;   (progn
;;     (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
;;           treemacs-deferred-git-apply-delay      0.5
;;           treemacs-display-in-side-window        t
;;           treemacs-eldoc-display                 t
;;           treemacs-file-event-delay              5000
;;           treemacs-file-extension-regex          treemacs-last-period-regex-value
;;           treemacs-file-follow-delay             0.2
;;           treemacs-follow-after-init             t
;;           treemacs-git-command-pipe              ""
;;           treemacs-goto-tag-strategy             'refetch-index
;;           treemacs-indentation                   2
;;           treemacs-indentation-string            " "
;;           treemacs-is-never-other-window         nil
;;           treemacs-max-git-entries               5000
;;           treemacs-missing-project-action        'ask
;;           treemacs-no-png-images                 nil
;;           treemacs-no-delete-other-windows       t
;;           treemacs-project-follow-cleanup        nil
;;           treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
;;           treemacs-position                      'left
;;           treemacs-recenter-distance             0.1
;;           treemacs-recenter-after-file-follow    nil
;;           treemacs-recenter-after-tag-follow     nil
;;           treemacs-recenter-after-project-jump   'always
;;           treemacs-recenter-after-project-expand 'on-distance
;;           treemacs-show-cursor                   nil
;;           treemacs-show-hidden-files             t
;;           treemacs-silent-filewatch              nil
;;           treemacs-silent-refresh                nil
;;           treemacs-sorting                       'alphabetic-desc
;;           treemacs-space-between-root-nodes      t
;;           treemacs-tag-follow-cleanup            t
;;           treemacs-tag-follow-delay              1.5
;;           treemacs-width                         35)

;;     ;; The default width and height of the icons is 22 pixels. If you are
;;     ;; using a Hi-DPI display, uncomment this to double the icon size.
;;     ;;(treemacs-resize-icons 44)

;;     (treemacs-follow-mode t)
;;     (treemacs-filewatch-mode t)
;;     (treemacs-fringe-indicator-mode t)
;;     (pcase (cons (not (null (executable-find "git")))
;;                  (not (null treemacs-python-executable)))
;;       (`(t . t)
;;        (treemacs-git-mode 'deferred))
;;       (`(t . _)
;;        (treemacs-git-mode 'simple))))
;;   :bind
;;   (:map global-map
;;         ("M-0"       . treemacs-select-window)
;;         ("C-x t 1"   . treemacs-delete-other-windows)
;;         ("C-x t t"   . treemacs)
;;         ("C-x t B"   . treemacs-bookmark)
;;         ("C-x t C-t" . treemacs-find-file)
;;         ("C-x t h" . treemacs-helpful-hydra)        
;;         ("C-x t M-t" . treemacs-find-tag)))

;; (use-package treemacs-projectile
;;   :after treemacs projectile
;;   :ensure t)

;; (use-package treemacs-icons-dired
;;   :after treemacs dired
;;   :ensure t
;;   :config (treemacs-icons-dired-mode))

;; (use-package treemacs-magit
;;   :after treemacs magit
;;   :ensure t)
;; M-x t h h 

;; Do not let C-z do the usual thing it does
(put 'suspend-frame 'disabled t)



;; Try org-brain to see if its ability to organized and concept map works
;; Allows you to edit entries directly from org-brain-visualize
;; (use-package polymode
;;   :ensure t
;;   :config
;;   (add-hook 'org-brain-visualize-mode-hook #'org-brain-polymode))

(use-package dumb-jump
  ;; :ensure t
  )

(use-package eterm-256color
  :hook (term-mode . eterm-256color-mode))

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


(provide 'early-misc)
;;; lsp-settings.el ends here

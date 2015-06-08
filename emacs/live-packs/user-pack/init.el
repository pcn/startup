;; User pack init file
;;
;; Use this file to initiate the pack configuration.
;; See README for more information.

;; Load bindings config
(live-load-config-file "bindings.el")

;; Packages to be installed for my use:
;; company-mode
;; company-anaconda
;; anaconda
;; cider 0.7
;; virtualenvwrapper
;; And disable autocomplete in the emacs-live setup.


;; Switch out iswitchb for ido mode.  iswitchb is depricated
(setq org-completion-use-ido t)

;; Add melpa
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

;; Load bindings config
(live-load-config-file "bindings.el")

;; (require 'rust-mode)


;; Enable auto-complete in rust-mode, using M-/
(require 'auto-complete)
(require 'auto-complete-config)
(add-to-list 'ac-modes 'rust-mode)
;; (global-auto-complete-mode t)
;; (ac-set-trigger-key "TAB")
(ac-set-trigger-key "M-/")
;; (setq ac-auto-start nil)
(setq ac-auto-start 'true)

; (setq ac-dwim nil) ; To get pop-ups with docs even if a word is uniquely completed

;; Make completion happen on C-return instead of return
;; so crazy things don't happen at the end of a line
(define-key ac-completing-map (kbd "RET") nil)
(define-key ac-completing-map [return] nil)
(define-key ac-completing-map [(control return)] 'ac-complete)

;; map magit-status to C-c g instead of C-x g?
;; (global-set-key (kbd "C-c g") 'magit-status)


;; Enable projectile
(require 'helm-projectile)
(helm-projectile-on)
(projectile-global-mode)

;; Enable flx-ido to make ido better
(require 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)
;; disable ido faces to see flx highlights.
(setq ido-enable-flex-matching t)
(setq ido-use-faces nil)

;; Make elpy active
;; Failing with:
;;
;; Symbol's function definition is void: elpy-modules-global-init
;; So look into this later
;; (elpy-enable)


;;
(server-start)

;; Enable company-mode for completion
;; (add-hook 'after-init-hook 'global-company-mode)
;; python backend
;; (add-to-list 'company-backends 'company-anaconda)

;;python virtualenvs
;; (require 'virtualenvwrapper)
;; (venv-initialize-interactive-shells) ;; if you want interactive shell support
;; (venv-initialize-eshell) ;; if you want eshell support
;; (setq venv-location "~/venv") ;; Use with M-x venv-workon
;;
;; (add-hook 'python-mode-hook (lambda ()
;;                               (hack-local-variables)
;;                               (when (boundp 'project-venv-name)
;;                                 (venv-workon project-venv-name))))
;;
;; (setq-default mode-line-format
;;               (cons '(:exec venv-current-name) mode-line-format))
;;

;; Use ido-mode
;; (setq org-completion-use-ido t)

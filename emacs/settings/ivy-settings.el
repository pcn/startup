;;; package --- Summary
;;; the settings for ivy, projectile, swiper etc.

;;; Commentary:
;;; Non-default narrowing and project jumping pieces


;;; Code:
;; ivy 0.9.0 adds some cool stuff
(elpaca ivy (use-package ivy
  ;; :ensure t
;;  (ivy-mode 1)
  :config 
  (setq ivy-use-virtual-buffers t)
  ))

(global-set-key (kbd "C-s") 'swiper)
;; (global-set-key "\C-r" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-c P") 'counsel-package)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "C-c r g") 'counsel-rg)
(global-set-key (kbd "C-M-j") 'ivy-immediate-done)
(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)


  ;; Don't use the default switch-to-buffer, use counsel's switch-to-buffer which provides a
  ;; preview of buffers.
  (global-set-key (kbd "C-x b") 'counsel-switch-buffer)
  


;; (use-package company-box
;;   :hook (company-mode . company-box-mode)
;;   :defer 0.5)

(elpaca all-the-icons (use-package all-the-icons
  :defer 0.5))

;; (setq all-the-icons-ivy-file-commands
;;       '(counsel-find-file counsel-file-jump counsel-recentf
;;                           counsel-projectile-find-file
;;                           counsel-projectile-find-dir))


;; ;; And avy
;; (avy-setup-default)
;; (global-set-key (kbd "C-c C-j") 'avy-resume)
;; (global-set-key (kbd "C-'") 'avy-goto-char-timer)
;; (global-set-key (kbd "M-g f") 'avy-goto-line)

;; Some ivy posframe customizations
;; this just installs and load the package, use require, use-package...
;; (package! 'ivy-posframe t)  ;; Which I haven't implemented -PCN
;; I'm disabling this to see if it's interfering with how
;; lsp-ui is working
;; (require 'ivy-posframe)
;; (setf (alist-get t ivy-posframe-display-functions-alist)
;;       'ivy-posframe-display-at-frame-bottom-left)
;; (setf (alist-get 'ivy-completion-in-region ivy-posframe-display-functions-alist)
;;       'ivy-posframe-display-at-point)
;; (setq ivy-posframe-parameters '((left-fringe . 2)
;;                                 (right-fringe . 2)
;;                                 (internal-border-width . 1)))
;; (setq ivy-posframe-width (frame-width))
;; (ivy-posframe-mode 1)

(setq completion-in-region-function #'ivy-completion-in-region)


;; Having trouble in emacs 30, updating config etc, trying out projction instead
;; ;; Referencing https://github.com/syl20bnr/spacemacs/issues/4207,
;; ;; Maybe shell startup is killing me
;; ;; (setq shell-file-name "/bin/sh")
(elpaca projectile (use-package projectile
  :config
  (projectile-mode +1)
  ;; (projectile-enable-caching t) ;; Causes an error as of 2025-02-21
  ;; (projectile-global t)
  :general
  ("C-c p" 'projectile-command-map)))


(defun my-ivy-completing-read (&rest args)
  (let ((ivy-sort-functions-alist '((t . nil))))
    (apply 'ivy-completing-read args)))

(setq magit-completing-read-function 'my-ivy-completing-read)
(setq projectile-completion-system 'ivy)


;; (elpaca projection
;;   (use-package projection
;;     :ensure t
;;     :hook (after-init . global-projection-hook-mode)
;;     :config
;;     (with-eval-after-load 'project
;;       (require 'projection))
;;     :config
;;     :bind-keymap
;;     ("C-c p" . projection-map)))
  
;; (elpaca projection-multi
;;   (use-package projection-multi
;;   :ensure t
;;   :bind ( :map projection-prefix-map
;;           ("RET" . projection-multi-compile))))

;; (elpaca projection-multi-embark (use-package projection-multi-embark
;;   :ensure t
;;   :after embark
;;   :after projection-multi
;;   :demand t
;;   ;; Add the projection set-command bindings to `compile-multi-embark-command-map'.
;;   :config (projection-multi-embark-setup-command-map)))

(provide 'ivy-settings)

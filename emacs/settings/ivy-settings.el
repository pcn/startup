;; ivy 0.9.0 adds some cool stuff
(use-package ivy
  ;; :ensure t
  (ivy-mode 1)
  
  (setq ivy-use-virtual-buffers t)
  )

(global-set-key (kbd "C-s") 'swiper)
;; (global-set-key "\C-r" 'swiper)
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-c P") 'counsel-package)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "C-c r g") 'counsel-rg)
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)

  ;; Don't use the default switch-to-buffer, use counsel's switch-to-buffer which provides a
  ;; preview of buffers.
  (global-set-key (kbd "C-x b") 'counsel-switch-buffer)
  


;; (use-package company-box
;;   :hook (company-mode . company-box-mode)
;;   :defer 0.5)

(use-package all-the-icons :defer 0.5)

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

;; Referencing https://github.com/syl20bnr/spacemacs/issues/4207,
;; Maybe shell startup is killing me
;; (setq shell-file-name "/bin/sh")
(use-package projectile-mode
  (projectile-mode +1)
  (setq projectile-enable-caching t)
  (projectile-global-mode)
  )
(global-set-key (kbd "C-c p") 'projectile-command-map)

(defun my-ivy-completing-read (&rest args)
  (let ((ivy-sort-functions-alist '((t . nil))))
    (apply 'ivy-completing-read args)))

(setq magit-completing-read-function 'my-ivy-completing-read)
(setq projectile-completion-system 'ivy)

(provide 'ivy-settings)

;; ivy 0.9.0 adds some cool stuff
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(global-set-key "\C-s" 'swiper)
(global-set-key "\C-r" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key [f6] 'ivy-resume)
(global-set-key (kbd "C-c P") 'counsel-package)
(global-set-key (kbd "C-c r g") 'counsel-rg)

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
;; (setq completion-in-region-function #'ivy-completion-in-region)

;; Referencing https://github.com/syl20bnr/spacemacs/issues/4207,
;; Maybe shell startup is killing me
;; (setq shell-file-name "/bin/sh")
(projectile-mode +1)
(setq projectile-enable-caching t)
(projectile-global-mode)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

(defun my-ivy-completing-read (&rest args)
  (let ((ivy-sort-functions-alist '((t . nil))))
    (apply 'ivy-completing-read args)))

(setq magit-completing-read-function 'my-ivy-completing-read)
(setq projectile-completion-system 'ivy)

(provide 'ivy-settings)

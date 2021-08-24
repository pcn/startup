;;; package --- Summary
;;; the settings I use for golang programming

;;; Commentary:
;;; Golang language behavior that I want as a default


;;; Code:


;; (require 'lsp-mode)
;; (add-hook 'go-mode-hook #'lsp-deferred)

;; ;; Set up before-save hooks to format buffer and add/delete imports.
;; ;; Make sure you don't have other gofmt/goimports hooks enabled.
;; (defun lsp-go-install-save-hooks ()
;;   (add-hook 'before-save-hook #'lsp-format-buffer t t)
;;   (add-hook 'before-save-hook #'lsp-organize-imports t t))
;; (add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

(use-package go-mode
 :defer t
 :ensure t
 :mode ("\\.go\\'" . go-mode)
 :init
  (setq compile-command "echo Building... && go build -v && echo Testing... && go test -v && echo Linter... && golint")
  (setq compilation-read-command nil)
  (setq compilation-window-height 14)
  (setq compilation-scroll-output t)
  (setq lsp-gopls-use-placeholders t)
  (setq lsp-gopls-hover-kind "FullDocumentation")

  
;;  (add-hook 'go-mode-hook 'custom-go-mode)
  :hook
  (go-mode . compile)
  (go-mode . gotest)
  (go-mode . lsp)
  (go-mode . my-go-mode-hook)
  (go-mode . my-go-compilation-hook)
  (go-mode . smartparens-mode)
  (go-mode . rainbow-delimiters-mode)
  :general 
  (:keymaps 'go-mode-map
            "M-," 'compile
            "M-." 'godef-jump))

(defun my-go-compilation-hook ()
  (when (not (get-buffer-window "*compilation*"))
    (save-selected-window
      (save-excursion
        (let* ((w (split-window-vertically))
                (h (window-height w)))
          (select-window w)
          (switch-to-buffer "*compilation*")
          (shrink-window (- h compilation-window-height)))))))

(defun my-go-mode-hook ()
  (setq tab-width 2 indent-tabs-mode 1)
  ;; eldoc shows the signature of the function at point in the status bar.
  ;; (go-eldoc-setup)
  (local-set-key (kbd "M-.") #'godef-jump)
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t)
;;   (add-hook 'before-save-hook 'gofmt-before-save)

  ;; extra keybindings from https://github.com/bbatsov/prelude/blob/master/modules/prelude-go.el
  (let ((map go-mode-map))
    (define-key map (kbd "C-c r t p") 'go-test-current-project) ;; current package, really
    (define-key map (kbd "C-c r t f") 'go-test-current-file)
    (define-key map (kbd "C-c r t t") 'go-test-current-test)
    (define-key map (kbd "C-c r r") 'go-run)))

;; "projectile" recognizes git repos (etc) as "projects" and changes settings
;; as you switch between them. 
;; (projectile-global-mode 1)
(projectile-mode 1)
(require 'go-projectile)

; gotest defines a better set of error regexps for go tests, but it only
; enables them when using its own functions. Add them globally for use in
(require 'compile)
(require 'gotest)
(dolist (elt go-test-compilation-error-regexp-alist-alist)
  (add-to-list 'compilation-error-regexp-alist-alist elt))
(defun prepend-go-compilation-regexps ()
  (dolist (elt (reverse go-test-compilation-error-regexp-alist))
    (add-to-list 'compilation-error-regexp-alist elt t)))
(add-hook 'go-mode-hook 'prepend-go-compilation-regexps)


(provide 'golang-settings)
;;; golang-settings.el ends here

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

(elpaca go-mode (use-package go-mode
 :defer t
 ;; :ensure t
 :mode ("\\.go\\'" . go-mode)
 :init
  (setq compile-command "echo Building... && go build -v && echo Testing... && go test -v && echo Linter... && golint")
  (setq compilation-read-command nil)
  (setq compilation-window-height 14)
  (setq compilation-scroll-output t)

  
;;  (add-hook 'go-mode-hook 'custom-go-mode)
  :general
  ;; M-. is deliberately NOT bound here: it stays on the global
  ;; `xref-find-definitions', which eglot backs with gopls. It used to be bound
  ;; to `godef-jump' both here and in my-go-mode-hook, which shadowed eglot's
  ;; navigation with a tool that is not installed.
  (:keymaps '(go-mode-map go-ts-mode-map)
            "M-," 'compile)))

;; Hook these onto BOTH go-mode and go-ts-mode: treesit-auto remaps go-mode ->
;; go-ts-mode now that the Go grammar is installed, and go-mode-hook then never
;; runs at all -- which would silently drop eglot.
;;
;; Two entries that used to live here are deliberately gone, because both
;; signalled errors from the mode hook. An error in a mode hook aborts
;; `run-mode-hooks' BEFORE it reaches `after-change-major-mode-hook', which is
;; where `global-font-lock-mode' turns font-lock on -- so a throwing hook left
;; Go buffers with no syntax highlighting at all, and skipped every later hook:
;;   * `gotest' -- a package name, not a function; "Autoloading ... failed to
;;     define function gotest" on every Go file visit.
;;   * `my-go-compilation-hook' -- compilation window management wired to a
;;     file-visit hook; raised "Cannot split side window" depending on layout.
;; my-go-compilation-hook is still defined below for use from compilation.
(dolist (hook '(go-mode-hook go-ts-mode-hook))
  (add-hook hook #'eglot-ensure)
  (add-hook hook #'my-go-mode-hook)
  (add-hook hook #'smartparens-mode)
  (add-hook hook #'rainbow-delimiters-mode)
  (add-hook hook #'subword-mode))

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
  (add-hook 'before-save-hook #'eglot-format-buffer t t)
  (add-hook 'before-save-hook (lambda () (eglot-code-actions nil nil "source.organizeImports" t)) t t)
;;   (add-hook 'before-save-hook 'gofmt-before-save)

  ;; extra keybindings from https://github.com/bbatsov/prelude/blob/master/modules/prelude-go.el
  ;; Bound in the buffer's local map rather than go-mode-map, so they apply
  ;; under go-ts-mode too (go-mode-map is not active there).
  (local-set-key (kbd "C-c r t p") 'go-test-current-project) ;; current package, really
  (local-set-key (kbd "C-c r t f") 'go-test-current-file)
  (local-set-key (kbd "C-c r t t") 'go-test-current-test)
  (local-set-key (kbd "C-c r r") 'go-run))

;; Install go-projectile dependencies explicitly
(elpaca go-guru (use-package go-guru))
(elpaca go-rename (use-package go-rename))

;; "projectile" recognizes git repos (etc) as "projects" and changes settings
;; as you switch between them. 
;; (projectile-global-mode 1)
(elpaca go-projectile (use-package go-projectile
  ;; :ensure t
  :config
  (setq projectile-mode 1)
  :after (go-guru go-rename)
  ))

; gotest defines a better set of error regexps for go tests, but it only
; enables them when using its own functions. Add them globally for use in
;; (use-package compile
  ;; :ensure t
;;   )
(elpaca gotest (use-package gotest
  ;; :ensure t
  :config
  (dolist (elt go-test-compilation-error-regexp-alist-alist)
    (add-to-list 'compilation-error-regexp-alist-alist elt))
  (defun prepend-go-compilation-regexps ()
    (dolist (elt (reverse go-test-compilation-error-regexp-alist))
      (add-to-list 'compilation-error-regexp-alist elt t)))
  (add-hook 'go-mode-hook 'prepend-go-compilation-regexps)))


(provide 'golang-settings)
;;; golang-settings.el ends here

;;; package --- Summary
;;; My settings for lsp and dap and other dev prerequisites

;;; Commentary:
;;;
;;; Try to have the 'package' package do as much work as possible
;;; as well as customize

;;; Summary:
;;;
;;; Settings specific to LSP, and less so to the languages that will use it

;;; Code:
;; (use-package helm-lsp :commands helm-lsp-workspace-symbol)
(use-package projectile :ensure t)
(use-package counsel :ensure t)
(use-package lsp-treemacs :ensure t :commands lsp-treemacs-errors-list)

(use-package marginalia :ensure t)  ;; Does this play nicely with ivy/swiper?

;; better smart parens than paredit, maybe?
;; Based on https://www.wisdomandwonder.com/article/9897/use-package-smartparens-config-ensure-smartparens
(use-package smartparens
  :ensure t
  :config
  (smartparens-global-mode-enable-in-buffers)
  (require 'smartparens-config)
  :general
  (:keymaps 'smartparens-mode-map
            "M-p s r" 'sp-forward-slurp-sexp
            "M-p s l" 'sp-backward-slurp-sexp
            "M-p b r" 'sp-forward-barf-sexp
            "M-p b l" 'sp-backward-barf-sexp
            "M-p p f" 'sp-forward-sexp
            "M-p p b" 'sp-backward-sexp ))

(use-package tree-sitter
  :ensure t)
(use-package tree-sitter-langs
  :ensure t)



;; optionally if you want to use debugger
(use-package dap-mode
  :ensure t )


;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; ;; TODO: include lsp-ui?
;; (require 'lsp-mode)


;; lsp-mode
;; https://github.com/emacs-lsp/lsp-mode/blob/master/README.org#performance
;; Let emacs gather more garbage before collecting using the gc magic hack
;; https://github.com/emacsmirror/gcmh
;; (use-package gcmh)
;; https://emacs-lsp.github.io/lsp-mode/page/performance/
;; (setq read-process-output-max (* 1024 1024 5)) ;; 5mb
;; In case I ever invoke 'lsp-mode' again:
;; https://github.com/emacs-lsp/lsp-mode/issues/523
;; Based on https://github.com/emacs-lsp/lsp-mode#use-package
(use-package lsp-mode
;;  :init (setq lsp-keymap-prefix "C-c l")
  :ensure t
  :commands lsp
  :config
;;   (require 'lsp-clients)
  ;; change nil to 't to enable logging of packets between emacs and the LS
  ;; this was invaluable for debugging communication with the MS Python Language Server
  ;; and comparing this with what vs.code is doing
  ;; (setq lsp-enable-snippet t)
  ;; (setq lsp-ui-doc-max-height 8)
  ;; (setq lsp-ui-sideline-delay 2)
  (setq lsp-print-io nil)
  (setq lsp-idle-delay 0.500))

;; Use the language server protocol module when possible
;; (with-eval-after-load 'lsp-mode
;;     (require 'lsp-flycheck))


;; Working off of
;; https://github.com/daviwil/emacs-from-scratch/blob/210e517353abf4ed669bc40d4c7daf0fabc10a5c/Emacs.org
(use-package lsp-ui
  :ensure t
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom)
  (lsp-ui-sideline-delay 2)
  (lsp-ui-sikdeline-show-hover t)
  (lsp-ui-doc-max-height 8))

(use-package flycheck :ensure)


;; (use-package lsp-ui
;;   :ensure t
;;   :config
;; ;;   (setq lsp-ui-sideline-ignore-duplicate t)
;;   (add-hook 'lsp-mode-hook 'lsp-ui-mode))  ;;I changed this. -->  :commands lsp-ui-mode)
;; ;; Sideline just doesn't seem to DTRT for me.
;; (setq lsp-ui-sideline-enable nil)
;; ;; install LSP company backend for LSP-driven completion
;; ;; (use-package company-lsp
;; ;;   :ensure t
;; ;;   :config
;; ;;   (push 'company-lsp company-backends))

;; ;; ;; Recommended company settings from https://github.com/TommyX12/company-tabnine
;; ;; (use-package company-tabnine :ensure t)
;; ;; ;; Trigger completion immediately.
;; ;; (setq company-idle-delay 0)
;; ;; (add-to-list 'company-backends #'company-tabnine)

;; Number the candidates (use M-1, M-2 etc to select completions).

(use-package lsp-ivy
  :after lsp)

(use-package lsp-treemacs
  :after lsp)


(use-package yasnippet
  :ensure
  :config
  (yas-reload-all)
  ;; (add-hook 'prog-mode-hook 'yas-minor-mode)
  ;; (add-hook 'text-mode-hook 'yas-minor-mode)
  :commands yas-minor-mode
  ;; :hook (go-mode . yas-minor-mode)
  ;;  (rustic-mode . yas-minor-mode))
  :hook (prog-mode-hook . yas-minor-mode)
  (text-mode-hook . yas-minor-mode))

(use-package company
  :ensure t)
;;   :bind
;;  (add-hook 'after-init-hook 'global-company-mode))
  ;; (:map company-active-map
  ;;       ("C-n". company-select-next)
  ;;       ("C-p". company-select-previous)
  ;;       ("M-<". company-select-first)
  ;;       ("M->". company-select-last)))

;; Copying https://github.com/pcn/emacs-rust-config/blob/master/init.el
(defun check-expansion ()
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
        (backward-char 1)
        (if (looking-at "::") t nil)))))


(defun do-yas-expand ()
  (let ((yas/fallback-behavior 'return-nil))
    (yas/expand)))

;; (defun tab-indent-or-complete ()
;;   (interactive)
;;   (if (minibufferp)
;;       (minibuffer-complete)
;;     (if (or (not yas/minor-mode)
;;             (null (do-yas-expand)))
;;         (if (check-expansion)
;;             (company-complete-common)
;;           (indent-for-tab-command)))))

(use-package toml-mode :ensure)

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;; setting up debugging support with dap-mode

(use-package exec-path-from-shell
  :ensure
  :init (exec-path-from-shell-initialize))

;; Originally relied on lldb-mi, but that appears to no
;; longer be shipped as part of llvm, so, well, what to do?
(when (executable-find "rust-gdb")
  (use-package dap-mode
    :ensure
    :config
    (dap-ui-mode 1)
    (dap-tooltip-mode 1)
    (tooltip-mode 1)
    (dap-ui-controls-mode 1)

    (require 'dap-lldb)
    (require 'dap-gdb-lldb)
    ;; installs .extension/vscode
    (dap-gdb-lldb-setup)
    (dap-register-debug-template "Rust::GDB Run Configuration"
                             (list :type "gdb"
                                   :request "launch"
                                   :name "GDB::Run"
                           :gdbpath "rust-gdb"
                                   :target nil
                                   :cwd nil))
    ;; (dap-register-debug-template
    ;;  "Rust::LLDB Run Configuration"
    ;;  (list :type "lldb"
    ;;        :request "launch"
    ;;        :name "LLDB::Run"
    ;;        :gdbpath "rust-lldb"
    ;;        ;; uncomment if lldb-mi is not in PATH
    ;;        ;; :lldbmipath "path/to/lldb-mi"
    ;;        ))
    ))

;; Nicer blame mode
(use-package mo-git-blame
  :ensure t)

(provide 'development-settings)
;;; lsp-settings.el ends here

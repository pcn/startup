;;; package --- Summary
;;; My settings for lsp

;;; Commentary:
;;; 
;;; Try to have the 'package' package do as much work as possible
;;; as well as customize

;;; Summary:
;;; 
;;; Settings specific to LSP, and less so to the languages that will use it

;;; Code:
(use-package lsp-ui
  :ensure t
  :config
;;   (setq lsp-ui-sideline-ignore-duplicate t)
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))  ;;I changed this. -->  :commands lsp-ui-mode)
;; Sideline just doesn't seem to DTRT for me.
(setq lsp-ui-sideline-enable nil)
;; install LSP company backend for LSP-driven completion
(use-package company-lsp
  :ensure t
  :config
  (push 'company-lsp company-backends))
;; (use-package helm-lsp :commands helm-lsp-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
;; optionally if you want to use debugger
;; (use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; ;; TODO: include lsp-ui?
;; (require 'lsp-mode)
;; (require 'lsp-rust)
(add-hook 'rust #'lsp-mode-deferred)
(add-hook 'rust-mode-hook 'cargo-minor-mode)
;; This and more from
;; https://vxlabs.com/2018/11/19/configuring-emacs-lsp-mode-and-microsofts-visual-studio-code-python-language-server/
(use-package lsp-python-ms
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-python-ms)
                          (lsp-deferred))))  ; or lsp-deferred
;; lsp-mode
;; https://github.com/emacs-lsp/lsp-mode/blob/master/README.org#performance
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq lsp-idle-delay 0.500)
;; In case I ever invoke 'lsp-mode' again:
;; https://github.com/emacs-lsp/lsp-mode/issues/523
;; Based on https://github.com/emacs-lsp/lsp-mode#use-package
(use-package lsp-mode
;;  :init (setq lsp-keymap-prefix "C-c l")
  :ensure t
  :commands lsp
  :config
  (require 'lsp-clients)
  ;; change nil to 't to enable logging of packets between emacs and the LS
  ;; this was invaluable for debugging communication with the MS Python Language Server
  ;; and comparing this with what vs.code is doing
  (setq lsp-print-io nil))

;; Use the language server protocol module when possible
;; (with-eval-after-load 'lsp-mode
;;     (require 'lsp-flycheck))

(provide 'lsp-settings)
;;; lsp-settings.el ends here

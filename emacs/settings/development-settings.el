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
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
;; optionally if you want to use debugger
;; (use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; ;; TODO: include lsp-ui?
;; (require 'lsp-mode)


;; lsp-mode
;; https://github.com/emacs-lsp/lsp-mode/blob/master/README.org#performance
;; Let emacs gather more garbage before collecting using the gc magic hack
;; https://github.com/emacsmirror/gcmh
(use-package gcmh)
;; https://emacs-lsp.github.io/lsp-mode/page/performance/
(setq read-process-output-max (* 1024 1024 5)) ;; 5mb
(setq lsp-idle-delay 0.500)
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
  (setq lsp-print-io nil))

;; Use the language server protocol module when possible
;; (with-eval-after-load 'lsp-mode
;;     (require 'lsp-flycheck))


;; Working off of
;; https://github.com/daviwil/emacs-from-scratch/blob/210e517353abf4ed669bc40d4c7daf0fabc10a5c/Emacs.org
(use-package lsp-ui
  :ensure t
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-ui
  :ensure t
  :config
;;   (setq lsp-ui-sideline-ignore-duplicate t)
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))  ;;I changed this. -->  :commands lsp-ui-mode)
;; Sideline just doesn't seem to DTRT for me.
(setq lsp-ui-sideline-enable nil)
;; install LSP company backend for LSP-driven completion
;; (use-package company-lsp
;;   :ensure t
;;   :config
;;   (push 'company-lsp company-backends))

;; ;; Recommended company settings from https://github.com/TommyX12/company-tabnine
;; (use-package company-tabnine :ensure t)
;; ;; Trigger completion immediately.
;; (setq company-idle-delay 0)
;; (add-to-list 'company-backends #'company-tabnine)

;; Number the candidates (use M-1, M-2 etc to select completions).
(setq company-show-numbers t)

(use-package lsp-ivy
  :after lsp)

(use-package lsp-treemacs
  :after lsp)


(provide 'development-settings)
;;; lsp-settings.el ends here

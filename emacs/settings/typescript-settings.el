;;; package --- Summary
;;; the settings I use for typescript programming

;;; Commentary:
;;; Typescript language behavior that I want as a default


;;; Code:

;; Parinfer-rust works with emacs with dynamic module support, which
;; should be default for 27.1 and newer Note
;; Need to install: clang, clang-dev
;; Why isn't this in the rust settings??
;; (use-package parinfer-rust-mode
;;   ;; :ensure t
;;   )

;;; typescript ide apparently? Similar to CIDER for clojure, I guess?
(elpaca tide (use-package tide
  ;; :ensure t
  :hook
  ;; Both variants: treesit-auto remaps typescript-mode -> typescript-ts-mode
  ;; now that the TypeScript/TSX grammars are installed.
  (typescript-mode . smartparens-strict-mode)
  (typescript-ts-mode . smartparens-strict-mode)
  (tsx-ts-mode . smartparens-strict-mode)
  ;; (typescript-mode . fira-code-mode)
;;  (typescript-mode . parinfer-rust-mode)
  :general
  (:keymaps '(typescript-mode-map typescript-ts-mode-map)
            "M-p s r" 'paredit-forward-slurp-sexp
            "M-p s l" 'paredit-backward-slurp-sexp
            "M-p b r" 'paredit-forward-barf-sexp
            "M-p b l" 'paredit-backward-barf-sexp)))
            


;; (add-hook 'cider-repl-mode-hook #'smartparens-strict-mode)
;; (add-hook 'cider-mode-hook #'smartparens-strict-mode)



(provide 'typescript-settings)
;;; clojure-settings.el ends here



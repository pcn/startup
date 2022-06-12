;;; package --- Summary
;;; the settings I use for clojure programming

;;; Commentary:
;;; Clojure language behavior that I want as a default


;;; Code:

;; Parinfer-rust works with emacs with dynamic module support, which for me is only 27.1 and later.
(use-package parinfer-rust-mode
  :ensure t)

(use-package cider
  :ensure t
  :hook 
  (clojure-mode . smartparens-strict-mode)
  (clojure-mode . fira-code-mode)
  (clojure-mode . parinfer-rust-mode)
  :general
  (:keymaps 'clojure-mode-map
            "M-p s r" 'paredit-forward-slurp-sexp
            "M-p s l" 'paredit-backward-slurp-sexp
            "M-p b r" 'paredit-forward-barf-sexp
            "M-p b l" 'paredit-backward-barf-sexp))
            


;; (add-hook 'cider-repl-mode-hook #'smartparens-strict-mode)
;; (add-hook 'cider-mode-hook #'smartparens-strict-mode)



(provide 'clojure-settings)
;;; clojure-settings.el ends here



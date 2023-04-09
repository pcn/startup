;; We can safely declare this function, since we'll only call it in Python Mode,
;; that is, when python.el was already loaded.a
(declare-function python-shell-calculate-exec-path "python")

;; I have no idea when or where this started, but as of this week this just started happening
;; (2023-03-24). It seems like https://old.reddit.com/r/emacs/comments/ke3bs7/how_would_you_narrow_down_this_bug_in_pythonmode/
;; is hitting me.
(setq debug-on-error nil)

;; This may or may not be the right approach.  We also have  pyenv-mode-auto, and one or the other
;; should work.
(defun flycheck-virtualenv-executable-find (executable)
  "Find an EXECUTABLE in the current virtualenv if any."
  (if (bound-and-true-p python-shell-virtualenv-root)
      (let ((exec-path (python-shell-calculate-exec-path)))
        (executable-find executable))
    (executable-find executable)))

(defun flycheck-virtualenv-setup ()
  "Setup Flycheck for the current virtualenv."
  (setq-local flycheck-executable-find #'flycheck-virtualenv-executable-find))

(provide 'flycheck-virtualenv)

;; With all that done, maybe we can use ipython in an inferior python now
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "--simple-prompt -i")


;; (with-eval-after-load 'flycheck
;;   (add-hook 'flycheck-mode-hook #'flycheck-pycheckers-setup))

;; (defun flycheck-python-setup ()
;;   (flycheck-mode))

;; Format with black to try not to think too hard about it
(use-package python-black
  :demand t
  :after python)

;; (use-package smartparens-python
;;   :demand t
;;   :ensure t)

(add-hook 'python-mode-hook #'(lambda () (setq flycheck-checker 'python-pylint)))
;; enable
(setq flycheck-python-pylint-executable (expand-file-name "~/bin/pylint"))
;; (add-to-list 'flycheck-disabled-checkers 'python-flake8)
;; (add-to-list 'flycheck-disabled-checkers 'flycheck-mypy)


;; Directly from https://emacs-lsp.github.io/lsp-pyright/
(use-package lsp-pyright
  ;; :ensure t
  :hook (python-momde . (lambda ()
                          (require 'lsp-pyright)
                          (lsp)))) ; or lsp-deferred?
  

;; More flychecking from https://github.com/lunaryorn/.emacs.d/blob/master/lisp/flycheck-virtualenv.el

(provide 'python-settings)
;;; python-settings.el ends here

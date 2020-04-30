;; We can safely declare this function, since we'll only call it in Python Mode,
;; that is, when python.el was already loaded.a
(declare-function python-shell-calculate-exec-path "python")
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

(add-hook 'python-mode-hook #'(lambda () (setq flycheck-checker 'python-pylint)))
;; enable
(setq flycheck-python-pylint-executable "~/bin/pylint")
(add-to-list 'flycheck-disabled-checkers 'python-flake8)
(add-to-list 'flycheck-disabled-checkers 'flycheck-mypy)


;; python-related LSP settings
;; This and more from
;; https://vxlabs.com/2018/11/19/configuring-emacs-lsp-mode-and-microsofts-visual-studio-code-python-language-server/
(use-package lsp-python-ms
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-python-ms)
                          (lsp-deferred))))  ; or lsp-deferred


;; More flychecking from https://github.com/lunaryorn/.emacs.d/blob/master/lisp/flycheck-virtualenv.el

(provide 'python-settings)
;;; python-settings.el ends here

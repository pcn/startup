;;; package --- Summary
;;; My .emacs file

;;; Commentary:
;;; 
;;; Try to have the 'package' package do as much work as possible
;;; as well as customize

;;; Summary:
;;; 
;;; Some top-level package-installed and customize-managed stuff, and
;;; then load other files that make my emacs happy

;;; Code:

;; Instead of package try elpaca
(setq package-enable-at-startup nil)
(defvar elpaca-installer-version 0.3)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (kill-buffer buffer)
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))



;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))


(elpaca-wait) ;; Defer after-init-hooks until after elpaca has run


;; symlink to https://github.com/pcn/startup/tree/master/emacs
(add-to-list 'load-path (directory-file-name "~/.emacs.d/settings"))
(load "early-misc.el")
(load "magit-settings")
(load "neotree-settings")
(load "development-settings")  ;; Lsp and dap first so other languages get its settings
(load "ivy-settings") ;; After development settings so that lsp-ivy works
(load "rust-settings")
(load "python-settings")
(load "clojure-settings")
(load "typescript-settings")
(load "golang-settings")
(load "feature-settings")
(load "tab-settings")
(load "run-in-vterm.el")
(load "org-mode-settings.el")
(load "various-other-settings.el")  ;; Things I want moved out of init.el here
(load "tramp-settings.el")

(put 'narrow-to-region 'disabled nil)
(elpaca-process-queues)
(provide 'init)
;; init.el ends here

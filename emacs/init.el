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

;; ;; From https://github.com/progfolio/elpaca 2025-02-21
(defvar elpaca-installer-version 0.9)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; ;; Install use-package support
;; (elpaca elpaca-use-package
;;   ;; Enable :elpaca use-package keyword.
;;   (elpaca-use-package-mode))


(elpaca-wait) ;; Defer after-init-hooks until after elpaca has run


;; ;; symlink to https://github.com/pcn/startup/tree/master/emacs
(add-to-list 'load-path (directory-file-name "~/.emacs.d/settings"))
(load "early-misc.el")
(load "magit-settings")
(load "development-settings")  ;; Lsp and dap first so other languages get its settings
(load "ivy-settings") ;; After development settings so that lsp-ivy works
(load "vertico-settings") 
(load "rust-settings")
(load "python-settings")
(load "clojure-settings")
(load "typescript-settings")
(load "golang-settings")
(load "feature-settings")
(load "tab-settings")
;; (load "run-in-vterm.el")
(load "org-mode-settings.el")
(load "various-other-settings.el")  ;; Things I want moved out of init.el here
(load "tramp-settings.el")
;; ;; (load "codeium.el")
(load "copilot-settings.el");; 

(put 'narrow-to-region 'disabled nil)
(elpaca-process-queues)
(delete ' ("\\.rs\\'" . rust-mode) auto-mode-alist)  ;; OMG I hate myself for this, but I don't know the "right" way to do this. Maybe ask on the elpaca github if this continues

(provide 'init)



;; init.el ends here

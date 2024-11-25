;;; package --- Summary
;;; the settings I use for the gherkin feature-mode

;;; Commentary:
;;; Gherkin/cucumber mode settings


;;; Code:


;; From https://github.com/michaelklishin/cucumber.el
;; Use gherkin mode for features
;; The table handling needs org-mode to be loaded,
;; which in 27.1 it ma not be, so
;; on init, load the org library

;; Projectile requires sqlite3, and I think magit does too. Anyway, install this
;; here, it's a runtime requirement it doesn't prevent loading.
(use-package sqlite3)

;; 2023-12-19 error during startup reads:
;; ⛔ Emergency (magit): Magit requires ‘transient’ >= 0.5.0,
;; but due to bad defaults, Emacs’ package manager, refuses to
;; upgrade this and other built-in packages to higher releases
;; from GNU Elpa.
;; 
;; To fix this, you have to add this to your init file:
;; 
;;   (setq package-install-upgrade-built-in t)
;; 
;; Then evaluate that expression by placing the cursor after it
;; and typing C-x C-e.
;; 
;; Once you have done that, you have to explicitly upgrade ‘transient’:
;; 
;;   M-x package-upgrade transient RET
;; 
;; Then you also must make sure the updated version is loaded,
;; by evaluating this form:
;; 
;;   (progn (unload-feature ’transient t) (require ’transient))
;; 
;; If you don’t use the ‘package’ package manager but still get
;; this warning, then your chosen package manager likely has a
;; similar defect.

;; which leads to https://github.com/magit/magit/issues/5059
(use-package transient)

(use-package magit
  ;; :ensure t
  )
;;  :init (;;(load-library "org")

(use-package forge
  ;; :ensure t
  :after magit)
(setq auth-sources '((expand-file-anme "~/.magit-forge-authinfo")))

;; For formatting commit messages with conventional-commit style
;; (use-package conventional-commit
;;   :hook
;;   (git-commit-mode . conventional-commit-setup))


;; Throw blamer.el in as well, since it's sort of git-related
;; (use-package blamer
;;   :bind (("s-i" . blamer-show-commit-info)
;;          ("C-c i" . blamer-show-posframe-commit-info))
;;   :defer 20
;;   :custom
;;   (blamer-idle-time 0.3)
;;   (blamer-min-offset 70)
;;   (blamer-show-avatar-p nil "Having failues loading avatars, silence it")
;;   :custom-face
;;   (blamer-face ((t :foreground "#7a88cf"
;;                     :background nil
;;                     :height 1.0
;;                     :italic t
;;                     )))
;;   :config
;;   (global-blamer-mode 1)
;;   ;; (setq blamer-commit-formmater "%s")
;;   )

(use-package why-this)

(provide 'magit-settings)
;;; clojure-settings.el ends here


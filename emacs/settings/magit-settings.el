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


(provide 'magit-settings)
;;; clojure-settings.el ends here


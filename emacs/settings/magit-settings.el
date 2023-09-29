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


;; Throw blamer.el in as well, since it's sort of git-related
(use-package blamer
  :bind (("s-i" . blamer-show-commit-info)
         ("C-c i" . blamer-show-posframe-commit-info))
  :defer 20
  :custom
  (blamer-idle-time 0.3)
  (blamer-min-offset 70)
  :custom-face
  (blamer-face ((t :foreground "#7a88cf"
                    :background nil
                    :height 1.0
                    :italic t
                    )))
  :config
  (global-blamer-mode 1)
  ;; (setq blamer-commit-formmater "%s")
  )

(provide 'magit-settings)
;;; clojure-settings.el ends here


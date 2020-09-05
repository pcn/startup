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
(use-package feature-mode
  :init (load-library "org")
  :hook (fira-code-mode . feature-mode))



(provide 'feature-settings)
;;; clojure-settings.el ends here


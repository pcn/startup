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
(elpaca feature-mode (use-package feature-mode
  ;; :ensure t
;;  :init (;;(load-library "org")
  ;;   :hook fira-code-mode) ;; This is wrong, this is changing the mode to feature mode when I load fira-code-mode
  
))


(provide 'feature-settings)
;;; clojure-settings.el ends here


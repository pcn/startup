;;; package --- Summary
;;; Things I want to move out of init.el

;;; Commentary:
;;; Odds-and-ends


;;; Code:


;; From https://github.com/michaelklishin/cucumber.el
;; Use gherkin mode for features
;; The table handling needs org-mode to be loaded,
;; which in 27.1 it ma not be, so
;; on init, load the org library
;; (use-package perspective
;;   ;; :ensure t
;;   :bind
;;   ("C-x C-b" . persp-list-buffers)

;;   :custom
;;   (persp-mode-prefix-key (kbd "C-c M-p"))
;;   (persp-suppress-no-prefix-key-warning to t)
;;   :init
;;   (persp-mode))

(use-package auto-complete
  ;; :ensure t
  :init
  (ac-config-default))

(use-package whitespace-cleanup-mode
  ;; :ensure t
  )
  

(provide 'various-other-settings)
;;; clojure-settings.el ends here


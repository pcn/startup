;;; package --- Summary
;;; Settings for using github copilot 

;;; Commentary:
;;; Use a module to enable copilot


;;; Code:

;;; First, use elpaca to define the copilot.el package since it's not avialable from elpa or melpa.

;; (elpaca-recipe '(copilot :inherit t :source "https://github.com/copilot-emacs/copilot.el"))


; When using company, 
; complete by copilot first, then company-mode
(defun my-company-tab ()
  (interactive)
  (or (copilot-accept-completion)
      (company-indent-or-complete-common nil)))

;; When using corfu, the same?
(defun my-corfu-tab ()
  (interactive)
  (or (copilot-accept-completion)
      (corfu-next)))

;;; Github copilot module
(use-package copilot
  :ensure (:host github :repo "copilot-emacs/copilot.el"
                 :files ("*.el")
                 :protocol ssh)
  ;; Oh, this is simpler than I copypasta'd in the past
  ;; https://www.gnu.org/software/emacs/manual/html_node/use-package/Hooks.html
  :hook prog-mode)
   
              
; modify company-mode behaviors
(with-eval-after-load 'company
  ; disable inline previews
  (delq 'company-preview-if-just-one-frontend company-frontends)
  ; enable tab completion
  (define-key company-mode-map (kbd "<tab>") 'my-company-tab)
  (define-key company-mode-map (kbd "TAB") 'my-company-tab)
  (define-key company-active-map (kbd "<tab>") 'my-company-tab)
  (define-key company-active-map (kbd "TAB") 'my-company-tab)
  (define-key corfu-mode-map (kbd "<tab>") 'my-corfu-tab)
  (define-key corfu-mode-map (kbd "TAB") 'my-corfu-tab)
  (define-key corfu-active-map (kbd "<tab>") 'my-corfu-tab)
  (define-key corfu-active-map (kbd "TAB") 'my-corfu-tab) )

(provide 'copilot-settings)
;;; copilot-settings.el ends here



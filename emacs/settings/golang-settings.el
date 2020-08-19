;;; package --- Summary
;;; the settings I use for golang programming

;;; Commentary:
;;; Golang language behavior that I want as a default


;;; Code:


(use-package go-mode
 :defer t
 :ensure t
 :mode ("\\.go\\'" . go-mode)
 :init
  (setq compile-command "echo Building... && go build -v && echo Testing... && go test -v && echo Linter... && golint")  
  (setq compilation-read-command nil)
;;  (add-hook 'go-mode-hook 'custom-go-mode)
  :hook
  (go-mode . compile)
  (go-mode . gotest)
  (go-mode . lsp)
  (go-mode . my-go-mode-hook)
 :bind (("M-," . compile)
        ("M-." . godef-jump)))


(defun my-go-mode-hook ()
  (setq tab-width 2 indent-tabs-mode 1)
  ;; eldoc shows the signature of the function at point in the status bar.
  (go-eldoc-setup)
  (local-set-key (kbd "M-.") #'godef-jump)
  (add-hook 'before-save-hook 'gofmt-before-save)

  ;; extra keybindings from https://github.com/bbatsov/prelude/blob/master/modules/prelude-go.el
  (let ((map go-mode-map))
    (define-key map (kbd "C-c a") 'go-test-current-project) ;; current package, really
    (define-key map (kbd "C-c m") 'go-test-current-file)
    (define-key map (kbd "C-c .") 'go-test-current-test)
    (define-key map (kbd "C-c b") 'go-run)))

; Use projectile-test-project in place of 'compile'; assign whatever key you want.
(global-set-key [f9] 'projectile-test-project)

;; "projectile" recognizes git repos (etc) as "projects" and changes settings
;; as you switch between them. 
;; (projectile-global-mode 1)
(projectile-mode 1)
(require 'go-projectile)
(go-projectile-tools-add-path)
(setq gofmt-command (concat go-projectile-tools-path "/bin/goimports"))

;; Golang customizations
(require 'company-go)
(add-hook 'go-mode-hook
          (lambda ()
            (company-mode)
            (set (make-local-variable 'company-backends) '(company-go))))

; gotest defines a better set of error regexps for go tests, but it only
; enables them when using its own functions. Add them globally for use in
(require 'compile)
(require 'gotest)
(dolist (elt go-test-compilation-error-regexp-alist-alist)
  (add-to-list 'compilation-error-regexp-alist-alist elt))
(defun prepend-go-compilation-regexps ()
  (dolist (elt (reverse go-test-compilation-error-regexp-alist))
    (add-to-list 'compilation-error-regexp-alist elt t)))
(add-hook 'go-mode-hook 'prepend-go-compilation-regexps)


;; (require 'go-mode)
;; (require 'company-go)
;; (add-hook 'go-mode-hook
;;           (lambda ()
;;             (company-mode)
;;             (set (make-local-variable 'company-backends) '(company-go))))

;; ; gotest defines a better set of error regexps for go tests, but it only
;; ; enables them when using its own functions. Add them globally for use in
;; (require 'compile)
;; (require 'gotest)
;; (dolist (elt go-test-compilation-error-regexp-alist-alist)
;;   (add-to-list 'compilation-error-regexp-alist-alist elt))
;; (defun prepend-go-compilation-regexps ()
;;   (dolist (elt (reverse go-test-compilation-error-regexp-alist))
;;     (add-to-list 'compilation-error-regexp-alist elt t)))
;; (add-hook 'go-mode-hook 'prepend-go-compilation-regexps)

; end golang .emacs additions

(provide 'golang-settings)
;;; golang-settings.el ends here

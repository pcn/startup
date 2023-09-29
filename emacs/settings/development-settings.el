;;; package --- Summary
;;; My settings for lsp and dap and other dev prerequisites

;;; Commentary:
;;;
;;; Try to have the 'package' package do as much work as possible
;;; as well as customize

;;; Summary:
;;;
;;; Settings specific to LSP, and less so to the languages that will use it

;;; Code:
;; (use-package helm-lsp :commands helm-lsp-workspace-symbol)
(use-package projectile
  ;; :ensure t
  )
(use-package counsel
  ;; :ensure t
  )
(use-package lsp-treemacs
  ;; :ensure t
  :commands lsp-treemacs-errors-list)

(use-package marginalia
  ;; :ensure t
  )  ;; Does this play nicely with ivy/swiper?

(use-package minimap
  ;; :ensure t
  ) ;; show a smaller view of the file being visited

(use-package rainbow-delimiters )

;; better smart parens than paredit, maybe?
;; Based on https://www.wisdomandwonder.com/article/9897/use-package-smartparens-config-ensure-smartparens
(use-package smartparens
  ;; :ensure t
  :init
  ;; needs to be in init https://github.com/Fuco1/smartparens/issues/1088
  (require 'smartparens-config)
  :config
  (smartparens-global-mode-enable-in-buffers)
  :general
  (:keymaps 'smartparens-mode-map
            "M-p s r" 'sp-forward-slurp-sexp
            "M-p s l" 'sp-backward-slurp-sexp
            "M-p b r" 'sp-forward-barf-sexp
            "M-p b l" 'sp-backward-barf-sexp
            "M-p p f" 'sp-forward-sexp
            "M-p p b" 'sp-backward-sexp ))

(use-package tree-sitter
  ;; :ensure t
  :init
  (global-tree-sitter-mode))

(use-package tree-sitter-langs
  ;; :ensure t
  )



;; ;; use-package-hydra to allow hydras to be bound to
;; ;; use-package
;; (use-package use-package-hydra
;;   :after hydra use-package)
;; (elpaca-wait) ;; Or the hydra part of use-package will not work
;; (use-package hydra)

(use-package yaml-mode)

(use-package lsp-origami
  :after origami)

(use-package origami
  :hook
  (yaml-mode . origami-mode)
  (go-mode . origami-mode)
  :after use-package-hydra use-package
  :bind ("C-c C-v" . hydra-origami/open-node)
  :hydra
  (hydra-origami (:color red)
  "
  _o_pen node    _n_ext fold       toggle _f_orward
  _c_lose node   _p_revious fold   toggle _a_ll
  "
  ("o" origami-open-node)
  ("c" origami-close-node)
  ("n" origami-next-fold)
  ("p" origami-previous-fold)
  ("f" origami-forward-toggle-node)
  ("a" origami-toggle-all-nodes))

  )



;; This doesn't work, still, without some more investigation/tinkering 2023-06-18
;; optionally if you want to use debugger
(use-package dap-mode
  ;; :ensure t
  )


;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; ;; TODO: include lsp-ui?
;; (require 'lsp-mode)


;; lsp-mode
;; https://github.com/emacs-lsp/lsp-mode/blob/master/README.org#performance
;; Let emacs gather more garbage before collecting using the gc magic hack
;; https://github.com/emacsmirror/gcmh
;; (use-package gcmh)
;; https://emacs-lsp.github.io/lsp-mode/page/performance/
;; (setq read-process-output-max (* 1024 1024 5)) ;; 5mb
;; In case I ever invoke 'lsp-mode' again:
;; https://github.com/emacs-lsp/lsp-mode/issues/523
;; Based on https://github.com/emacs-lsp/lsp-mode#use-package
(use-package lsp-mode
;;  :init (setq lsp-keymap-prefix "C-c l")
  ;; :ensure t
  :commands lsp
  :config
;;   (require 'lsp-clients)
  ;; change nil to 't to enable logging of packets between emacs and the LS
  ;; this was invaluable for debugging communication with the MS Python Language Server
  ;; and comparing this with what vs.code is doing
  ;; (setq lsp-enable-snippet t)
  ;; (setq lsp-ui-doc-max-height 8)
  ;; (setq lsp-ui-sideline-delay 2)
  (setq lsp-print-io nil)
  (setq lsp-idle-delay 0.500)
  :hook
  (lsp-mode . (lambda () (auto-complete-mode -1))) ;; https://stackoverflow.com/questions/29169210/how-to-disable-global-minor-mode-in-a-specified-major-mode
  ;; (lsp-after-open . lsp-origami-enable) ;; XXX look at fixing this so I can 
  )


;; Use the language server protocol module when possible
;; (with-eval-after-load 'lsp-mode
;;     (require 'lsp-flycheck))


;; Working off of
;; https://github.com/daviwil/emacs-from-scratch/blob/210e517353abf4ed669bc40d4c7daf0fabc10a5c/Emacs.org
;; And here is more documentation on what the various features are:
;; https://emacs-lsp.github.io/lsp-mode/tutorials/how-to-turn-off/
(use-package lsp-ui
  ;; :ensure t
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-position 'bottom)
  (lsp-ui-sideline-delay 2)
  (lsp-ui-doc-show-with-cursor t)
  ;; (lsp-ui-sideline-show-hover t)
  ;; (lsp-ui-doc-max-height 8)
  )

(use-package flycheck
  ;; :ensure t
  )


;; (use-package lsp-ui
;;   :ensure t
;;   :config
;; ;;   (setq lsp-ui-sideline-ignore-duplicate t)
;;   (add-hook 'lsp-mode-hook 'lsp-ui-mode))  ;;I changed this. -->  :commands lsp-ui-mode)
;; ;; Sideline just doesn't seem to DTRT for me.
;; (setq lsp-ui-sideline-enable nil)
;; ;; install LSP company backend for LSP-driven completion
;; ;; (use-package company-lsp
;; ;;   :ensure t
;; ;;   :config
;; ;;   (push 'company-lsp company-backends))

;; ;; ;; Recommended company settings from https://github.com/TommyX12/company-tabnine
;; ;; (use-package company-tabnine :ensure t)
;; ;; ;; Trigger completion immediately.
;; ;; (setq company-idle-delay 0)
;; ;; (add-to-list 'company-backends #'company-tabnine)

;; Number the candidates (use M-1, M-2 etc to select completions).

(use-package lsp-ivy
  ;; :ensure t
  :after lsp)

(use-package lsp-treemacs
  ;; :ensure t
  :after lsp)

(use-package yasnippet-snippets
  ;; :ensure t
  )

(use-package yasnippet
  ;; :ensure t
  :config
  (yas-reload-all)
  ;; (add-hook 'prog-mode-hook 'yas-minor-mode)
  ;; (add-hook 'text-mode-hook 'yas-minor-mode)
  :commands yas-minor-mode
  ;; :hook (go-mode . yas-minor-mode)
  ;;  (rustic-mode . yas-minor-mode))
  :hook (prog-mode-hook . yas-minor-mode)
  (text-mode-hook . yas-minor-mode))

(use-package company
  ;; :ensure t
  )
;;   :bind
;;  (add-hook 'after-init-hook 'global-company-mode))
  ;; (:map company-active-map
  ;;       ("C-n". company-select-next)
  ;;       ("C-p". company-select-previous)
  ;;       ("M-<". company-select-first)
  ;;       ("M->". company-select-last)))

;; Copying https://github.com/pcn/emacs-rust-config/blob/master/init.el
(defun check-expansion ()
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
        (backward-char 1)
        (if (looking-at "::") t nil)))))


(defun do-yas-expand ()
  (let ((yas/fallback-behavior 'return-nil))
    (yas/expand)))

;; Found this on reddit, to provide a yas snippet dir in local projectile projects
;; https://www.reddit.com/r/emacs/comments/57i41t/projectlocal_snippets/
(setq crshd--default-yas-snippet-dirs '("~/.emacs.d/snippets/"
                                        yas-installed-snippets-dir ))

(defun crshd/set-projectile-yas-dir ()
  "Append a projectile-local YAS snippet dir to yas-snippet-dirs."
  (interactive)
  (let ((local-yas-dir (concat (projectile-project-root) ".snippets")))
    (setq yas-snippet-dirs (cons local-yas-dir
                                 crshd--default-yas-snippet-dirs))))

(add-hook 'projectile-find-file-hook 'crshd/set-projectile-yas-dir)

;; (defun tab-indent-or-complete ()
;;   (interactive)
;;   (if (minibufferp)
;;       (minibuffer-complete)
;;     (if (or (not yas/minor-mode)
;;             (null (do-yas-expand)))
;;         (if (check-expansion)
;;             (company-complete-common)
;;           (indent-for-tab-command)))))

(use-package toml-mode :ensure)

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;; setting up debugging support with dap-mode

(use-package exec-path-from-shell
  ;; :ensure t
  :init (exec-path-from-shell-initialize))

;; Originally relied on lldb-mi, but that appears to no
;; longer be shipped as part of llvm, so, well, what to do?
(when (executable-find "rust-gdb")
  (use-package dap-mode
    ;; :ensure t
    :config
    (dap-ui-mode 1)
    (dap-tooltip-mode 1)
    (tooltip-mode 1)
    (dap-ui-controls-mode 1)

    (require 'dap-lldb)
    (require 'dap-gdb-lldb)
    ;; installs .extension/vscode
    (dap-gdb-lldb-setup)
    (dap-register-debug-template "Rust::GDB Run Configuration"
                             (list :type "gdb"
                                   :request "launch"
                                   :name "GDB::Run"
                           :gdbpath "rust-gdb"
                                   :target nil
                                   :cwd nil))
    ;; (dap-register-debug-template
    ;;  "Rust::LLDB Run Configuration"
    ;;  (list :type "lldb"
    ;;        :request "launch"
    ;;        :name "LLDB::Run"
    ;;        :gdbpath "rust-lldb"
    ;;        ;; uncomment if lldb-mi is not in PATH
    ;;        ;; :lldbmipath "path/to/lldb-mi"
    ;;        ))
    ))

;; Nicer blame mode
(use-package mo-git-blame
  ;; :ensure t
  )

(use-package restclient
  ;; :ensure t
  )

;; Fira is more annoying than useful as of 2023-06-18
;; (use-package fira-code-mode
;;   ;; :ensure t
;;   :custom (fira-code-mode-disabled-ligatures '("//" ":=" "==" ";;" "x" "[]" "++" "**")) ;; List of ligatures to turn off
;;   :hook prog-mode) ;; Enables fira-code-mode automatically for programming major modes

(provide 'development-settings)
;;; lsp-settings.el ends here

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
;; (use-package projectile  ;;; This is in ivy-settings
;;   ;; :ensure t
;;   )
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

;; Paren

;; (setq show-paren-mode 1)
;; (setq show-paren-delay 0)
;; (show-paren-mode)
(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))


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

;; (use-package lsp-origami
;;   :after origami)

;; (use-package origami
;;   :hook
;;   (yaml-mode . origami-mode)
;;   (go-mode . origami-mode)
;;   ;; :after use-package-hydra use-package
;;   :bind ("C-c C-v" . hydra-origami/open-node)
;;   ;; :hydra
;;   ;; (hydra-origami (:color red)
;;   "
;;   _o_pen node    _n_ext fold       toggle _f_orward
;;   _c_lose node   _p_revious fold   toggle _a_ll
;;   "
;;   ("o" origami-open-node)
;;   ("c" origami-close-node)
;;   ("n" origami-next-fold)
;;   ("p" origami-previous-fold)
;;   ("f" origami-forward-toggle-node)
;;   ("a" origami-toggle-all-nodes))
  



;; This doesn't work, still, without some more investigation/tinkering 2023-06-18
;; optionally if you want to use debugger
;; (use-package dap-mode
;;   ;; :ensure t
;;   )


;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; ;; TODO: include lsp-ui?
;; (require 'lsp-mode)

;; XXX UNDO
;; (use-package company
;;   :hook (company-mode . global-company-mode))

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
  ;; :after company-lsp
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

;; flycheck with pycheckers to enable checking.
(use-package flycheck
  ;; :ensure t
  :config
  (setq global-flycheck-mode 1)
  )

(with-eval-after-load 'flycheck
      (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)))

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

;; (use-package lsp-treemacs
;;   ;; :ensure t
;;   :after lsp)

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

(use-package toml-mode)

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;; setting up debugging support with dap-mode

;; (use-package exec-path-from-shell
;;   ;; :ensure t
;;   :init (exec-path-from-shell-initialize))

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

;; rg is enabled in early-misc
;; (use-package rg)
(use-package wgrep)

;; Helpfully convert strings between different programming cases
;; https://github.com/akicho8/string-inflection
(use-package string-inflection
  :general
  ("C-c C-i i" 'string-inflection-cycle)
  ("C-c C-i s" 'string-inflection-underscore)
  ("C-c C-i c" 'string-inflection-camelcase)
  )


;; Fira is more annoying than useful as of 2023-06-18
;; (use-package fira-code-mode
;;   ;; :ensure t
;;   :custom (fira-code-mode-disabled-ligatures '("//" ":=" "==" ";;" "x" "[]" "++" "**")) ;; List of ligatures to turn off
;;   :hook prog-mode) ;; Enables fira-code-mode automatically for programming major modes

;; Combobulate, from the masteringemacs site's maintainer
;; https://github.com/mickeynp/combobulate
;; This may be enough configuration on its own to merit its own file?

(use-package json-mode) ;; Without this, js-json mode is used, and tree-sitter doesn't know what to infer from that

(use-package treesit
  ;; For using elpaca's 'use-package' with tree-sitter, do not run the build steps since it's built-into emacs
  :build (:not elpaca--clone-dependencies elpaca--queue-dependencies
                      elpaca--generate-autoloads-async elpaca--byte-compile
                      elpaca--compile-info elpaca--install-info
                      elpaca--add-info-path elpaca--activate-package)  
  :mode (("\\.tsx\\'" . tsx-ts-mode))
  :preface
  (defun mp-setup-install-grammars () 
    "Install Tree-sitter grammars if they are absent."
    (interactive)
    (dolist (grammar
             ;; Note the version numbers. These are the versions that
             ;; are known to work with Combobulate *and* Emacs.
             '((css . ("https://github.com/tree-sitter/tree-sitter-css" "v0.20.0"))
               (go . ("https://github.com/tree-sitter/tree-sitter-go" "v0.20.0"))
               (html . ("https://github.com/tree-sitter/tree-sitter-html" "v0.20.1"))
               (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript" "v0.20.1" "src"))
               (json ("https://github.com/tree-sitter/tree-sitter-json" "v0.20.2"))
               (markdown "https://github.com/ikatyang/tree-sitter-markdown")
               (python ("https://github.com/tree-sitter/tree-sitter-python" "v0.20.4"))
               (rust "https://github.com/tree-sitter/tree-sitter-rust")
               (toml . ("https://github.com/tree-sitter/tree-sitter-toml" "v0.5.1"))
               (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "tsx/src"))
               (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "typescript/src"))
               (yaml ("https://github.com/ikatyang/tree-sitter-yaml" "v0.5.0"))))
      (add-to-list 'treesit-language-source-alist grammar)
      ;; Only install `grammar' if we don't already have it
      ;; installed. However, if you want to *update* a grammar then
      ;; this obviously prevents that from happening.
      (unless (treesit-language-available-p (car grammar))
        (treesit-install-language-grammar (car grammar)))))

  ;; Optional. Combobulate works in both xxxx-ts-modes and
  ;; non-ts-modes.

  ;; You can remap major modes with `major-mode-remap-alist'. Note
  ;; that this does *not* extend to hooks! Make sure you migrate them
  ;; also
  (dolist (mapping
           '((python-mode . python-ts-mode)
             (css-mode . css-ts-mode)
             (typescript-mode . typescript-ts-mode)
             (js2-mode . js-ts-mode)
             (bash-mode . bash-ts-mode)
             (conf-toml-mode . toml-ts-mode)
             (go-mode . go-ts-mode)
             (css-mode . css-ts-mode)
             (json-mode . json-ts-mode)
             ;; Well, this seems to be the mode 
             (js-json-mode . json-ts-mode)))
    (add-to-list 'major-mode-remap-alist mapping))
  :config
  (mp-setup-install-grammars)
  ;; Do not forget to customize Combobulate to your liking:
  ;;
  ;;  M-x customize-group RET combobulate RET
  ;;
  (use-package combobulate
    :custom
    ;; You can customize Combobulate's key prefix here.
    ;; Note that you may have to restart Emacs for this to take effect!
    (combobulate-key-prefix "C-c o")
    :hook ((prog-mode . combobulate-mode))
    ;; Amend this to the directory where you keep Combobulate's source
    ;; code.
    :load-path ("/home/pcn/dvcs/github/combobulate")))

(use-package combobulate
   :custom
   ;; You can customize Combobulate's key prefix here.
   ;; Note that you may have to restart Emacs for this to take effect!
   (combobulate-key-prefix "C-c o")
   :hook ((prog-mode . combobulate-mode))
   ;; Amend this to the directory where you keep Combobulate's source
   ;; code.
   :load-path ("/home/pcn/dvcs/github/combobulate"))

(provide 'development-settings)
;;; lsp-settings.el ends here

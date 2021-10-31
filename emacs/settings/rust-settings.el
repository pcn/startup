;;; package --- Summary
;;; the settings I use for rust programming

;;; Commentary:
;;; Rust language behavior that I want as a default


;;; Code:

;; Deferring the mapping of keys until after rust-mode happens
;; is apparently hard. Use the general mode, which can hook
;; into use-package, to do this
;; https://github.com/jwiegley/use-package/issues/121#issuecomment-237624152
;; (use-package rust-mode
;;   :hook
;;   (rust-mode . lsp)
;;   (rust-mode . cargo-minor-mode)
;;   :custom
;;   (lsp-rust-full-docs t)
;;   (lsp-rust-server 'rust-analyzer)
;;   :general
;;   (:keymaps 'rust-mode-map
;;             "C-c r t" 'rust-test
;;             "C-c r b" 'rust-build
;;             "C-c r r" 'rust-run))

;; It seems to be getting loaded somewhere else, so load it here so it can be removed from
;; auto-mode-aliast as long as I'm using rustic instead
;; (use-package rust-mode)


;; https://robert.kra.hn/posts/2021-02-07_rust-with-emacs/#code-navigation
(use-package rustic
  :ensure
  :general
  (:keymaps 'rustic-mode-map
            "M-j" 'lsp-ui-imenu
            "M-?" 'lsp-find-references
            ;; "C-c C-c l" 'flycheck-list-errors  ;; , use C-c ! l
            "C-c C-c a" 'lsp-execute-code-action
            "C-c C-c r" 'lsp-rename  ;; TODO: move this up to the development settings?
            "C-c C-c q" 'lsp-workspace-restart    ;; TODO: move this to the development settings?
            "C-c C-c Q" 'lsp-worksapce-shutdown  ;; TODO: move this to the development settings?
            "C-c C-c s" 'lsp-rust-analyzer-status
            "C-c C-c C-r" 'rustic-cargo-run  ;; Reverting to defaults - be explicit until next restart            
            "C-c C-c C-t" nil
            "C-c C-c C-t t" 'rustic-cargo-test  ;; Reverting to defaults - be explicit until next restart
            "C-c C-c C-b"  'rustic-cargo-build ;; Reverting to defaults - be explicit until next restart
            "C-c C-c C-t r" 'rustic-cargo-test-run
            "C-c C-c C-t l" 'pcn-cargo-test-file-local)
  :config
  ;; (setq rustic-format-on-save t)
  (setq rustic-lsp-format t)
  (setq lsp-rust-analyzer-proc-macro-enable t)
  (setq rustic-format-trigger 'on-save)
  :hook
  (rustic-mode . smartparens-mode)
  (rustic-mode . rk/rustic-mode-hook)
  (rustic-mode . tree-sitter-hl-mode)
  ;; (rustic-mode . dap-gdb-lldb)  ;; todo: maybe make sure that gdb and lldb are installed?
  )


;; inline-docs, aka rustdoc-to-org
;; https://github.com/brotzeit/rustic#inline-documentation
(use-package helm-ag
  :ensure t)


(defun rk/rustic-mode-hook ()
    ;; so that run C-c C-c C-r works without having to confirm, but don't try to
    ;; save rust buffers that are not file visiting. Once
    ;; https://github.com/brotzeit/rustic/issues/253 has been resolved this should
    ;; no longer be necessary.
  (when buffer-file-name
    (setq-local buffer-save-without-query t)))

;; Use this for cargo testing a particular module, so I can
;; set a local variable, e.g.
;; // -*- mode: rustic; cargo-test-less-arguments: "--test matrix"
;; for e.g.
(defun pcn-cargo-test-file-local ()
  "Run 'cargo test' via rustic-cargo-test-run with the buffer-local `cargo-test-arguments' variable.
The intent is to place e.g. this at the top of the file: // -*- mode: rustic; cargo-test-arguments: \"--test matrix\" -*-
or the equivalent at the end of the file"
  (interactive)
  (rustic-cargo-test-run (buffer-local-value 'cargo-test-arguments (current-buffer))))

  

;; Not sure how to do use-package, this doesn't help:
;; binding the key via https://github.com/jwiegley/use-package#key-binding and via
;; So just going for what it says here:
;; https://github.com/rust-lang/rust-mode#running--testing--compiling-code
;; (define-key rust-mode-map (kbd "C-c r t") 'rust-test)
;; (define-key rust-mode-map (kbd "C-c r b") 'rust-build)
;; (define-key rust-mode-map (kbd "C-c r r") 'rust-run)

;; 
;; Add keybindings for interacting with Cargo
;; (use-package cargo
;;   :hook (rust-mode . cargo-minor-mode))
;; (use-package flycheck-rust
;;   :config (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

;; (with-eval-after-load 'rust-mode
;;   (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(use-package toml-mode)

;; (require 'lsp-rust)
;; (add-hook 'rust-mode-hook 'cargo-minor-mode)


(provide 'rust-settings)
;;; rust-settings.el ends here

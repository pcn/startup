;;; package --- Summary
;;; the settings I use for rust programming

;;; Commentary:
;;; Rust language behavior that I want as a default


;;; Code:
(use-package rust-mode
  :hook
  (rust-mode . lsp)
  (rust-mode . cargo-minor-mode)
  :custom
  (lsp-rust-full-docs t)
  (lsp-rust-server 'rust-analyzer)
  )

;; Not sure how to do use-package, this doesn't help:
;; binding the key via https://github.com/jwiegley/use-package#key-binding and via
;; So just going for what it says here:
;; https://github.com/rust-lang/rust-mode#running--testing--compiling-code
(define-key rust-mode-map (kbd "C-c r t") 'rust-test)
(define-key rust-mode-map (kbd "C-c r b") 'rust-build)
(define-key rust-mode-map (kbd "C-c r r") 'rust-run)

;; 
;; Add keybindings for interacting with Cargo
(use-package cargo
  :hook (rust-mode . cargo-minor-mode))
;; (use-package flycheck-rust
;;   :config (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

;; (with-eval-after-load 'rust-mode
;;   (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(use-package toml-mode)

;; (require 'lsp-rust)
;; (add-hook 'rust-mode-hook 'cargo-minor-mode)


(provide 'rust-settings)
;;; rust-settings.el ends here

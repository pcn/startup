;;; package --- Summary
;;; the settings I use for rust programming

;;; Commentary:
;;; Rust language behavior that I want as a default


;;; Code:
(use-package rust-mode
  :hook (rust-mode . lsp))
;; 
;; Add keybindings for interacting with Cargo
(use-package cargo
  :hook (rust-mode . cargo-minor-mode))
(use-package flycheck-rust
  :config (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(with-eval-after-load 'rust-mode
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(use-package toml-mode)

;; (require 'lsp-rust)
(add-hook 'rust #'lsp-mode-deferred)
(add-hook 'rust-mode-hook 'cargo-minor-mode)


(provide 'rust-settings)
;;; rust-settings.el ends here

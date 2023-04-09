;;; package --- Summary
;;; the settings I use for the using tabs at the tope of a buffer, starting with centaur-tabs

;;; Commentary:
;;; See https://github.com/ema2159/centaur-tabs#installation
;;;

;;; Code:


(use-package centaur-tabs
  ;; :ensure
  :demand
  :config
  (centaur-tabs-mode t)
  (setq centaur-tabs-enable-key-bindings t)
  (setq centaur-tabs-cycle-scope 'tabs)
  (setq centaur-tabs-adjust-buffer-order t)
  (setq centaur-tabs-adjust-buffer-order 'left)
  :bind
  ;; Prior is pgup, next is pgdown
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward)
  ("C-<tab>" . centaur-tabs-counsel-switch-group))
  ;; :init
  ;; (setq centaur-tabs-enable-key-bindings t) )


(provide 'tab-settings)
;;; tab-settings.el ends here

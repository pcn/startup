;;; package --- Summary
;;; the settings I use for the using tabs at the tope of a buffer, starting with centaur-tabs

;;; Commentary:
;;; See https://github.com/ema2159/centaur-tabs#installation
;;;

;;; Code:

;; Todo: Now that I've added bindings for the grouping functions,
;; I think it'd be helpful to have groups that are dynamically created
;; for each projectile project
;; Can I do that based on https://github.com/ema2159/centaur-tabs#buffer-groups


(elpaca centaur-tabs (use-package centaur-tabs
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
  ("C-<tab>" . centaur-tabs-counsel-switch-group)
  ("C-c g f" . centaur-tabs-forward-group)
  ("C-c g b" . centaur-tabs-backward-group)
  ("C-c g g" . centaur-tabs-counsel-switch-group)
  ;; :init
  ;; (centaur-tabs-group-by-projectile-project)))
  ;; (setq centaur-tabs-enable-key-bindings t) )

))
  
(provide 'tab-settings)
;;; tab-settings.el ends here

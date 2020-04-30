;;; package --- Summary
;;; My settings for using neotree

;;; Commentary:
;;; 
;;; Try to have the 'package' package do as much work as possible
;;; as well as customize

;;; Summary:
;;; 
;;; Settings specific to LSP, and less so to the languages that will use it

;;; Code:

;; Test out neotree with projectile
;; From https://www.emacswiki.org/emacs/NeoTree#toc11
(defun neotree-project-dir ()
  "Open NeoTree using the git root."
  (interactive)
  (let ((project-dir (projectile-project-root))
        (file-name (buffer-file-name)))
    (neotree-toggle)
    (if project-dir
        (if (neo-global--window-exists-p)
            (progn
              (neotree-dir project-dir)
              (neotree-find file-name)))
      (message "Could not find git project root."))))


(global-set-key [f8] 'neotree-project-dir)

(defun neotree-show-project-dir ()
  "Open NeoTree using the git root, but don't close it."
  (interactive)
  (let ((project-dir (projectile-project-root))
        (file-name (buffer-file-name)))
    (unless (neo-global--window-exists-p)
      (neotree-toggle))
    (if project-dir
        (if (neo-global--window-exists-p)
            (progn
              (neotree-dir project-dir)
              (neotree-find file-name)))
      (message "Could not find git project root."))))
(global-set-key (kbd "\C-c n t") 'neotree-show-project-dir)




(provide 'neotree-settings)
;;; lsp-settings.el ends here

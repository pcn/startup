;;; package --- Summary
;;; the settings I use for mu4e for indexing email

;;; Commentary:
;;; Setting up mu4e for email


;;; Code:

;; From https://www.djcbsoftware.nl/code/mu/mu4e/Installation.html#Installation

;; sudo apt-get update;  sudo apt-get install -y libgmime-3.0-dev libxapian-dev guile-2.2-dev html2text xdg-utils


;; From https://www.djcbsoftware.nl/code/mu/mu4e/Minimal-configuration.html

;; make sure mu4e is in your load-path
(require 'mu4e)

;; use mu4e for e-mail in emacs
(setq mail-user-agent 'mu4e-user-agent)

;; these must start with a "/", and must exist
;; (i.e.. /home/user/Maildir/sent must exist)
;; you use e.g. 'mu mkdir' to make the Maildirs if they don't
;; already exist

;; below are the defaults; if they do not exist yet, mu4e offers to
;; create them. they can also functions; see their docstrings.
;; (setq mu4e-sent-folder   "/sent")
;; (setq mu4e-drafts-folder "/drafts")
;; (setq mu4e-trash-folder  "/trash")

;; smtp mail setting; these are the same that `gnus' uses.
;; (setq
;;    message-send-mail-function   'smtpmail-send-it
;;    smtpmail-default-smtp-server "smtp.example.com"
;;    smtpmail-smtp-server         "smtp.example.com"
;;    smtpmail-local-domain        "example.com")

;; ;; Todo: script command to sync emails
(setq mu4e-get-mail-command "docker run --rm --name offlineimap --user $(id -u) -v ~/.offlineimaprc:/home/pcn/.offlineimaprc -v ~/BustImap:/home/pcn/BustImap offlineimap3:latest")

;; Going to need to explore more of the practical settings from
;; http://cachestocaches.com/2017/3/complete-guide-email-emacs-using-mu-and-/


(provide 'mu4e-settings)
;;; mu4e-settings.el ends here

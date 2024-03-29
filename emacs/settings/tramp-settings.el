;;; package --- Summary
;;; the settings I use for the using tabs at the tope of a buffer, starting with centaur-tabs

;;; Commentary:
;;;
;;; Uses a running container 
;;; https://www.emacswiki.org/emacs/TrampAndDocker

;;; Code:


(use-package docker-tramp
  ;; :ensure
  :demand
;; Open files in Docker containers like so: /docker:drunk_bardeen:/etc/passwd
(push
 (cons
  "docker"
  '((tramp-login-program "docker")
    (tramp-login-args (("exec" "-it") ("%h") ("/bin/bash")))
    (tramp-remote-shell "/bin/sh")
    (tramp-remote-shell-args ("-i") ("-c"))))
 tramp-methods)
  
  )


(defadvice tramp-completion-handle-file-name-all-completions
  (around dotemacs-completion-docker activate)
  "(tramp-completion-handle-file-name-all-completions \"\" \"/docker:\" returns
    a list of active Docker container names, followed by colons."
  (if (equal (ad-get-arg 1) "/docker:")
      (let* ((dockernames-raw (shell-command-to-string "docker ps | perl -we 'use strict; $_ = <>; m/^(.*)NAMES/ or die; my $offset = length($1); while(<>) {substr($_, 0, $offset, q()); chomp; for(split m/\\W+/) {print qq($_:\n)} }'"))
             (dockernames (cl-remove-if-not
                           #'(lambda (dockerline) (string-match ":$" dockerline))
                           (split-string dockernames-raw "\n"))))
        (setq ad-return-value dockernames))
    ad-do-it))

;; It says tramp is faster with ssh...
(setq tramp-default-method "ssh")
;; Tramp actually has a sudo method. I don't even have words
;; emacsclient -e '(find-file "/sudo::/etc/apt/sources.list.d/steam.list")'


(provide 'tramp-settings)
;;; tramp-settings.el ends here

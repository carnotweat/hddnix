;; Adds melpa package access
;; Requires tweaking for emacs 22
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; ;; loads the preferred theme (must be installed already)
;; ;; to install this theme check here: https://github.com/purcell/color-theme-sanityinc-tomorrow
;; (load-theme sanityinc-tomorrow-night t)

;; Send all emacs backups to a specific folder. 
(setq backup-directory-alist '(("" . "~/emacs")))   
(when (daemonp)
  (exec-path-from-shell-initialize))

(dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO" "LANG" "LC_CTYPE" "NIX_SSL_CERT_FILE" "NIX_PATH"))
  (add-to-list 'exec-path-from-shell-variables var))

(require 'cl-lib)
(loop for (name . dir) in '(("home.local" . "/run/current-system/sw/bin/git")
                            ("work.local" . "/run/current-system/sw/bin/git"))
      if (string= (system-name) name)
      do (push dir exec-path))

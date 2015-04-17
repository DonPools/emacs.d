(require-package 'magit)
(require-package 'git-blame)
(require-package 'git-commit-mode)
(require-package 'git-rebase-mode)
(require-package 'gitignore-mode)
(require-package 'gitconfig-mode)
(require-package 'git-messenger)
(require-package 'git-timemachine)

(setq-default
 magit-save-some-buffers nil
 magit-process-popup-time 10
 magit-diff-refine-hunk t
 magit-completing-read-function 'magit-ido-completing-read)

(after-load 'magit
  (define-key magit-status-mode-map (kbd "C-M-<up>") 'magit-goto-parent-section))

(require-package 'fullframe)
(after-load 'magit
  (fullframe magit-status magit-mode-quit-window))

(add-hook 'git-commit-mode-hook 'goto-address-mode)
(after-load 'session
  (add-to-list 'session-mode-disable-list 'git-commit-mode))


(after-load 'magit
  (global-magit-wip-save-mode)
  (diminish 'magit-wip-save-mode))

(after-load 'magit
  (diminish 'magit-auto-revert-mode))

(when *is-a-mac*
  (after-load 'magit
    (add-hook 'magit-mode-hook (lambda () (local-unset-key [(meta h)])))))


(global-set-key (kbd "C-x v f") 'vc-git-grep)


(require-package 'magit-svn)
(autoload 'magit-svn-enabled "magit-svn")
(defun sanityinc/maybe-enable-magit-svn-mode ()
  (when (magit-svn-enabled)
    (magit-svn-mode)))
(add-hook 'magit-status-mode-hook #'sanityinc/maybe-enable-magit-svn-mode)

(after-load 'compile
  (dolist (defn (list '(git-svn-updated "^\t[A-Z]\t\\(.*\\)$" 1 nil nil 0 1)
                      '(git-svn-needs-update "^\\(.*\\): needs update$"
                                             1 nil nil 2 1)))
    (add-to-list 'compilation-error-regexp-alist-alist defn)
    (add-to-list 'compilation-error-regexp-alist (car defn))))

(defvar git-svn--available-commands nil "Cached list of git svn subcommands")

(defun git-svn (dir)
  "Run a git svn subcommand in DIR."
  (interactive "DSelect directory: ")
  (unless git-svn--available-commands
    (setq git-svn--available-commands
          (sanityinc/string-all-matches
           "^  \\([a-z\\-]+\\) +"
           (shell-command-to-string "git svn help") 1)))
  (let* ((default-directory (vc-git-root dir))
         (compilation-buffer-name-function (lambda (major-mode-name)
                                             "*git-svn*")))
    (compile (concat "git svn "
                     (ido-completing-read "git-svn command: "
                                          git-svn--available-commands nil t)))))

(require-package 'git-messenger)
(global-set-key (kbd "C-x v p") #'git-messenger:popup-message)


(setq magit-last-seen-setup-instructions "1.4.0")

(provide 'init-git)

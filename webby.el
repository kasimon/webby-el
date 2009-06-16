;; webby.el
;; Copyright (c) 2009 Karsten Heymann <karsten.heymann@gmx.de>

(define-derived-mode webby-mode text-mode "Webby"
  "Major mode for webby documents."
  (setq case-fold-search nil))

(define-key webby-mode-map "\C-c\C-c" 'webby-comnmand)
(define-key webby-mode-map "\C-c\C-b" 'webby-build)
(define-key webby-mode-map "\C-c\C-p" 'webby-publish)
(define-key webby-mode-map "\C-c\C-r" 'webby-rebuild)

(defun kh-get-parent-dir (dir)
  "Return the parent directory of a directory."
  (file-name-directory (directory-file-name (expand-file-name dir))))

(defun kh-find-parent-dir-containing-file (dir file)
  "Return the parent directory containing a given file or nil if no file found."
  (unless (string= dir "/")
    (if (member file (directory-files dir))
	dir
      (kh-find-parent-dir-containing-file (kh-get-parent-dir dir) file))))

(defun kh-current-buffer-directory ()
  "Return the directory the current buffer is in."
  (file-name-directory (buffer-file-name (current-buffer))))

(defun kh-webby-find-project-root ()
  "When called on a buffer that's part of a webby project, return the project root."
  (kh-find-parent-dir-containing-file (kh-current-buffer-directory) "Sitefile"))

(defun kh-shell-command-in-dir (dir command)
  "Execute a shell command in a given directory and collect the output in a buffer."
  (shell-command (concat "cd " dir ";" command) (get-buffer-create "*webby-output*")))

(defun kh-webby-execute (command)
  "Execute a webby command on the project of the current buffer."
  ;; execute webby in that dir
  (message (concat "Running: webby " command))
  (kh-shell-command-in-dir (kh-webby-find-project-root) (concat "webby " command))
  (message "Finished")
)

(defun webby-build ()
  "Rebuild all files in a webby project that need an update."
  (interactive)
  (kh-webby-execute "build"))

(defun webby-rebuild ()
  "Rebuild all files of a webby project."
  (interactive)
  (kh-webby-execute "rebuild"))

(defun webby-publish ()
  "Publish the current webby project."
  (interactive)
  (kh-webby-execute "publish"))

(provide 'webby)
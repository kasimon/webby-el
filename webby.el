;; webby.el --- Emacs support for the webby website compiler

;; Copyright  (C)  2009  Karsten Heymann <devel@karsten-heymann.de>

;; Version: 0.1
;; Keywords: webby html www
;; Author: Karsten Heymann <devel@karsten-heymann.de>
;; Maintainer: Karsten Heymann <devel@karsten-heymann.de>
;; URL: http://github.com/kasimon/webby-el

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

;; Commentary: 

;; This file implements basic emacs support for webby, a website compiler written 
;; in ruby.  Webby can be found at http://webby.rubyforge.org/.
;; 
;; This is a very early release with few features. The interface is
;; still subject to change, although changes will be done only for a
;; good reason. Documentation is still very sparse.

;; Code:

(define-derived-mode webby-mode text-mode "Webby"
  "Major mode for webby documents."
)

(define-key webby-mode-map "\C-c\C-c" 'webby-command)
(define-key webby-mode-map "\C-c\C-b" 'webby-build)
(define-key webby-mode-map "\C-c\C-d" 'webby-deploy)
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
  (kh-shell-command-in-dir 
   (kh-webby-find-project-root) 
   (concat "unset TERM; webby " command))
  (message "Finished")
)

(defun webby-command ()
  "Query webby command to run and run it."
  (interactive)
  (kh-webby-execute (completing-read
		     "Webby command: "
		     '("build" "rebuild" "deploy")
		     )
		    )
  )

(defun webby-build ()
  "Rebuild all files in a webby project that need an update."
  (interactive)
  (kh-webby-execute "build"))

(defun webby-rebuild ()
  "Rebuild all files of a webby project."
  (interactive)
  (kh-webby-execute "rebuild"))

(defun webby-deploy ()
  "Deploy the current webby project."
  (interactive)
  (kh-webby-execute "deploy"))

(provide 'webby)

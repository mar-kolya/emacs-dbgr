(eval-when-compile
  (defvar el-get-sources)
)

(declare-function el-get-post-install 'el-get)

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

;;; el-get-install.el --- installer for the lazy
;;
;; Copyright (C) 2010 Dimitri Fontaine
;;
;; Author: Dimitri Fontaine <dim@tapoueh.org>
;; URL: http://www.emacswiki.org/emacs/el-get.el
;; Created: 2010-06-17
;; Keywords: emacs package elisp install elpa git git-svn bzr cvs apt-get fink http http-tar
;; Licence: WTFPL, grab your copy here: http://sam.zoy.org/wtfpl/
;;
;; This file is NOT part of GNU Emacs.
;;
;; bootstrap your el-get installation, the goal is then to use el-get to
;; update el-get.
;;
;; So the idea is that you copy/paste this code into your *scratch* buffer,
;; hit C-j, and you have a working el-get.

(let ((el-get-root
       (file-name-as-directory
	(or (bound-and-true-p el-get-dir)
	    (concat (file-name-as-directory user-emacs-directory) "el-get")))))

  (when (file-directory-p el-get-root)
    (add-to-list 'load-path el-get-root))

  ;; try to require el-get, failure means we have to install it
  (unless (require 'el-get nil t)
    (unless (file-directory-p el-get-root)
      (make-directory el-get-root t))

    (let* ((package   "el-get")
	   (buf       (switch-to-buffer "*el-get bootstrap*"))
	   (pdir      (file-name-as-directory (concat el-get-root package)))
	   (git       (or (executable-find "git")
			  (error "Unable to find `git'")))
	   (url       (or (bound-and-true-p el-get-git-install-url)
			  "http://github.com/dimitri/el-get.git"))
	   (default-directory el-get-root)
	   (process-connection-type nil)   ; pipe, no pty (--no-progress)

	   ;; First clone el-get
	   (status
	    (call-process
	     git nil `(,buf t) t "--no-pager" "clone" "-v" url package)))

      (unless (zerop status)
	(error "Couldn't clone el-get from the Git repository: %s" url))

      ;; switch branch if we have to
      (let* ((branch (cond
                      ;; Check if a specific branch is requested
                      ((bound-and-true-p el-get-install-branch))
                      ;; Check if master branch is requested
                      ((boundp 'el-get-master-branch) "master")
                      ;; Read the default branch from the el-get recipe
                      ((plist-get (with-temp-buffer
                                    (insert-file-contents-literally
                                     (expand-file-name "recipes/el-get.rcp" pdir))
                                    (read (current-buffer)))
                                  :branch))
                      ;; As a last resort, use the master branch
                      ("master")))
             (remote-branch (format "origin/%s" branch))
             (default-directory pdir)
             (bstatus
               (if (string-equal branch "master")
                 0
                 (call-process git nil (list buf t) t "checkout" "-t" remote-branch))))
        (unless (zerop bstatus)
          (error "Couldn't `git checkout -t %s`" branch)))

      (add-to-list 'load-path pdir)
      (load package)
      (let ((el-get-default-process-sync t) ; force sync operations for installer
            (el-get-verbose t))		    ; let's see it all
        (el-get-post-install "el-get"))
      (with-current-buffer buf
	(goto-char (point-max))
	(insert "\nCongrats, el-get is installed and ready to serve!")))))


(declare-function el-get 'el-get)

;; now either el-get is `require'd already, or have been `load'ed by the
;; el-get installer.
(setq
 el-get-sources
 '(el-get			; el-get is self-hosting
   loc-changes 		        ; loc marks in buffers
   list-utils 		        ; list utilities like list-utils-flatten
   load-relative		; load emacs lisp relative to emacs source
   test-simple			; simple test framework
   ))

;; install new packages and init already installed packages
(el-get 'sync '(loc-changes list-utils load-relative test-simple))

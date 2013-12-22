;;; Copyright (C) 2010, 2011 Rocky Bernstein <rocky@gnu.org>
;;; Ruby "trepan8" Debugger tracking a comint or eshell buffer.

(eval-when-compile (require 'cl))
(require 'load-relative)
(require-relative-list '(
			 "../../common/cmds"
			 "../../common/menu"
			 "../../common/track"
			 "../../common/track-mode"
			 )
		       "realgud-")
(require-relative-list '("core" "init") "realgud-trepan8-")
(require-relative-list '("../../lang/ruby") "realgud-lang-")

(realgud-track-mode-vars "trepan8")

(declare-function realgud-track-mode 'realgud-track-mode)
(declare-function realgud-track-mode-hook 'realgud-track-mode)
(declare-function realgud-track-mode-setup 'realgud-track-mode)
(declare-function realgud-track-set-debugger 'realgud-track-mode)

(realgud-ruby-populate-command-keys trepan8-track-mode-map)

(define-key trepan8-track-mode-map
  (kbd "C-c !x") 'realgud-rubinius-goto-Xagent-backtrace-line)
(define-key trepan8-track-mode-map
  (kbd "C-c !!") 'realgud-ruby-goto-dollar-bang-line)

(defun trepan8-track-mode-hook()
  (use-local-map trepan8-track-mode-map)
  (message "trepan8 track-mode-hook called")
)
(define-minor-mode trepan8-track-mode
  "Minor mode for tracking ruby debugging inside a process shell."
  :init-value nil
  ;; :lighter " trepan8"   ;; mode-line indicator from realgud-track is sufficient.
  ;; The minor mode bindings.
  :global nil
  :group 'trepan8
  :keymap trepan8-track-mode-map

  (realgud-track-set-debugger "trepan8")
  (if trepan8-track-mode
      (progn
	(realgud-track-mode 't)
	(run-mode-hooks (intern (trepan8-track-mode-hook))))
    (progn
      (realgud-track-mode nil)
      ))
)

(provide-me "realgud-trepan8-")

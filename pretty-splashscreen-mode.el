;;; pretty-splashscreen-mode.el --- A pretty splashscreen to display anything of your choosing

;; Copyright (C) 2016 Jake Faulkner

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; Author: Jake Faulkner
;; Version: 0.1
;; Keywords: splashscreen
;; Package-Requires: ((cl-lib "0.2"))

;;; Commentary:
;;
;; This package displays a centered, read-only chunk of text as your splashscreen on startup.
;; The package was made to help users who do not wish to play around with the batteries included splashscreen
;; that comes with Emacs, which can be rather difficult and heavy duty.
;;

;;; Code:

(require 'cl-lib)

(defcustom pretty-splashscreen-center-text nil
  "If non-nil, center the splashscreen text."
  :group 'pretty-splashscreen
  :type 'boolean)
(defcustom pretty-splashscreen-buffer-name "*splash*"
  "The name of the pretty splashscreen buffer."
  :group 'pretty-splashscreen
  :type 'string)
(defcustom pretty-splashscreen-buffer-contents ""
  "The contents of the pretty splashscreen buffer."
  :group 'pretty-splashscreen
  :type 'string)

(defun pspl--get-max-line ()
  "Get the longest line length of a buffer (useful for centering)."
  (with-current-buffer (current-buffer)
    (cl-reduce (lambda (acc cur)
              (max (if (stringp acc)
                       (length acc)
                     acc) (length cur))) (split-string (buffer-string) "\n" t))))

(defun pspl--calculate-margin-position ()
  "Return the center margin position for the splashscreen."
  (- (/ (window-width) 2) (truncate (/ (pspl--get-max-line) 2))))

;;;###autoload
(define-derived-mode pretty-splashscreen-mode fundamental-mode "Splash"
  "A pretty splashscreen mode containing read-only, centered text of your choosing"
  :group 'pretty-splashscreen
  :syntax-table nil
  :abbrev-table nil
  (setq buffer-read-only t
        left-margin-width (if (or (not pretty-splashscreen-center-text) (daemonp))
                              0
                              (pspl--calculate-margin-position))
        right-margin-width 0
        left-fringe-width 0
        right-fringe-width 0
        truncate-lines t))

(defun pspl--update-splash ()
  "Center and redisplay splashscreen (provided `pretty-splashscreen-center-text' is non-nil)"
  (with-current-buffer (get-buffer pretty-splashscreen-buffer-name)
    (let ((margin-position (pspl--calculate-margin-position)))
      (when (and (not (> left-margin-width 0)) (> margin-position 0) (< margin-position 2147483647))
        (setq left-margin-width margin-position)
        (set-window-buffer nil (current-buffer))))))

;;;###autoload
(defun pspl/goto-splash ()
  "Swap to the pretty splashscreen buffer (creating it if it doesn't exist)."
  (interactive)
  (unless (get-buffer pretty-splashscreen-buffer-name)
    (with-current-buffer (get-buffer-create pretty-splashscreen-buffer-name)
      (insert pretty-splashscreen-buffer-contents)
      (when (and pretty-splashscreen-center-text (daemonp))
        (add-hook 'focus-in-hook #'pspl--update-splash))
      (pretty-splashscreen-mode)))
  (get-buffer pretty-splashscreen-buffer-name))
(provide 'pretty-splashscreen-mode)
;;; pretty-splashscreen-mode.el ends here

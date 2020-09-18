;;; chicken-doc.el --- CHICKEN Scheme doc commands

;; Copyright (C) 2020 Vasilij Schneidermann <mail@vasilij.de>

;; Author: Vasilij Schneidermann <mail@vasilij.de>
;; URL: https://depp.brause.cc/chicken-doc.el
;; Version: 0.0.1
;; Package-Requires:
;; Keywords: languages

;; This file is NOT part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;;; Code:

(defgroup chicken-doc nil
  "CHICKEN Scheme doc commands"
  :group 'languages
  :prefix "chicken-doc-")

(defcustom chicken-doc-command (executable-find "chicken-doc")
  "Path to `chicken-doc-helper' command."
  :group 'chicken-doc
  :type 'string)

(defvar chicken-doc-buffer "*chicken-doc*")

(defun chicken-doc--command (&rest args)
  (when (not chicken-doc-command)
    (user-error "`chicken-doc-helper-command' isn't set"))
  (with-current-buffer (get-buffer-create chicken-doc-buffer)
    (let (buffer-read-only)
      (erase-buffer)
      (let ((process-environment process-environment))
        ;; TODO: this doesn't work (yet)
        (setenv "CHICKEN_DOC_COLORS" "always")
        (let ((exit (apply 'call-process chicken-doc-command nil t nil args)))
          (when (not (zerop exit))
            (error "`chicken-doc-command' exited with %d, see %s"
                   exit chicken-doc-buffer))))
      (special-mode))))

(defun chicken-doc--get-candidates (term &optional regexp)
  (chicken-doc--command (if regexp "-m" "-f") term)
  (let (candidates)
    (with-current-buffer chicken-doc-buffer
      (goto-char (point-min))
      (while (not (eobp))
        (push (read (current-buffer)) candidates)
        (forward-line 1)))
    (nreverse candidates)))

(defun chicken-doc--narrow-down-candidates (candidates)
  (let* ((collection (mapcar (lambda (item)
                               (cons (prin1-to-string item) item))
                             candidates)))
    (cdr (assoc (completing-read "Select match " collection) collection))))

(defun chicken-doc--show-candidate (candidate)
  (apply 'chicken-doc--command (mapcar 'symbol-name candidate))
  (with-current-buffer chicken-doc-buffer
    (goto-char (point-min)))
  (display-buffer chicken-doc-buffer))

;;;###autoload
(defun chicken-doc-describe (term &optional regexp)
  "Look up TERM using the chicken-doc command.
Use the prefix argument to enable regex matching."
  (interactive
   (let* ((default (thing-at-point 'symbol))
          (prompt (if default
                      (format "Term (default %s): "
                              (substring-no-properties default))
                    "Term: ")))
     (list (read-string prompt nil nil default) current-prefix-arg)))
  (let ((candidates (chicken-doc--get-candidates term regexp)))
    (cond
     ((not candidates)
      (message "No matches for %s" term))
     ((= (length candidates) 1)
      (chicken-doc--show-candidate (car candidates)))
     (t
      (let ((candidate (chicken-doc--narrow-down-candidates candidates)))
        (when candidate
          (chicken-doc--show-candidate candidate)))))))

(provide 'chicken-doc)
;;; chicken-doc.el ends here

;;; elpa-mirror.el --- Tools for mirror elpa packages

;; Copyright (C) 2015 Ye Wenbin <wenbinye@gmail.com>

;; Author: Ye Wenbin <wenbinye@gmail.com>
;; Created: 2015-11-28
;; Version: 0.1
;; Keywords: tools
;; Package-Requires: ()

;; This file is not (yet) part of GNU Emacs.
;; However, it is distributed under the same license.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Don't load this file when running emacs

;; The archive is generated from a set of recipes which describe elisp
;; projects and repositories from which to get them.  The term
;; "package" here is used to mean a specific version of a project that
;; is prepared for download and installation.

;;; Code:

(require 'package)

(setq package-user-dir (file-name-directory load-file-name))
(setq package-archives
      (with-temp-buffer
        (insert-file-contents-literally (concat package-user-dir "package-archives.el"))
        (read (current-buffer))))

(defvar elpa-mirror-packages-dir (concat package-user-dir "packages/"))

(defun elpa-mirror-download (package)
  (let* ((name (car package))
         (kind (package-desc-kind (cdr package)))
         (version (package-version-join (package-desc-vers (cdr package))))
         (dir elpa-mirror-packages-dir)
         (ext (cond ((eq kind 'tar) ".tar")
                    ((eq kind 'single) ".el")
                    (t (error "Unknown package kind %s" (symbol-name kind)))))
         (location (package-archive-base name))
         (basename (concat (symbol-name name) "-" version))
         (file (concat basename ext)))
    (message "Downloading %s/%s" location file)
    (package--with-work-buffer location file
                               (write-region (point-min) (point-max) (concat dir "/" file)))
    (with-temp-buffer
      (print package (current-buffer))
      (write-region (point-min) (point-max) (concat dir "/" basename ".entry")))))

(defun elpa-mirror ()
  (message "Mirror elpa to directory " package-user-dir)
  (package-refresh-contents)
  (unless (file-exists-p elpa-mirror-packages-dir)
    (make-directory elpa-mirror-packages-dir))
  (dolist (package package-archive-contents)
    (let* ((name (car package))
           (version (package-desc-vers (cdr package)))
           (basename (concat (symbol-name name) "-" (package-version-join version))))
      (unless (file-exists-p (concat elpa-mirror-packages-dir basename ".entry"))
        (condition-case nil
            (elpa-mirror-download package)
          (error "Failed to download `%s' archive." name))))))

;; Local Variables:
;; coding: utf-8
;; End:

;;; elpa-mirror.el ends here

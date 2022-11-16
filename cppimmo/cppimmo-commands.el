;;; BSD 2-Clause License
;;; 
;;; Copyright (c) 2022, Brian Hoffpauir
;;; All rights reserved.
;;; 
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are met:
;;; 
;;; 1. Redistributions of source code must retain the above copyright notice,
;;;    this list of conditions and the following disclaimer.
;;;     
;;; 2. Redistributions in binary form must reproduce the above copyright notice,
;;;    this list of conditions and the following disclaimer in the documentation
;;;    and/or other materials provided with the distribution.
;;; 
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;; POSSIBILITY OF SUCH DAMAGE.
;;;
;;; Miscellaneous Commands
;;; All interactive commands that don't belong to a mode or library.

(defmacro cppimmo/call-when-interactive (fn-interactive &optional fn-non-interactive)
  "Call FN-INTERACTIVE when the parent function is called
interactively.  Call FN-NON-INTERACTIVE when optional argument is non-null."
  `(if (called-interactively-p 'interactive)
		 (,fn-interactive)
	   (when (not (null ,fn-non-interactive))
		 (,fn-non-interactive))))

(defun cppimmo/kill-ring-buffer-save ()
  "Place the entirety of the current buffer in the kill ring."
  (interactive)
  (save-excursion
    (push-mark (point)) ; Set mark at current point.
	(push-mark (point-min) nil t)
	(goto-char (point-max))
	(kill-ring-save (region-beginning) (region-end)))
  (message "Buffer saved to kill ring."))

(defun cppimmo/execute-command-other-frame (@command)
  "Run a command in a new frame.
@COMMAND ."
  (interactive "CC-x 5 M-x ")
  (select-frame (make-frame))
  (call-interactively @command))

(defun cppimmo/buffer-menu-other-frame ()
  "Execute the buffer-menu command in a new frame."
  (interactive)
  (cppimmo/execute-command-other-frame 'buffer-menu))

(defun cppimmo/bookmark-bmenu-other-frame ()
  "Execute the bookmark-bmenu-list command in a new frame."
  (interactive)
  (cppimmo/execute-command-other-frame 'bookmark-bmenu-list))

(defun cppimmo/goto-percent (@percent)
  "Move to @PERCENT as a percentage of the buffer point position.
@PERCENT The percentage to move to in the buffer."
  (interactive "nGo to percent ([0, 100]%%): ")
  (when (not (and (>= @percent 0) (<= @percent 100)))
	(error "@PERCENT must be within the range: [0, 100]."))
  (goto-char (/ (* (point-max) @percent) 100)))

(defun cppimmo/pluralize (@word @amount-of &optional @special-form)
  "Create a plural version of @WORD.
Insert the plural version of @WORD in the current buffer when called
interactively.  When called non-interatively return the plural version of @WORD
as a string.
@WORD The word to create a plural form for.
@AMOUNT-OF Specify the amount of @WORD(s) (i.e. the number of things).
@SPECIAL-FORM Optional specialized plural form of @WORD."
  (interactive "sEnter a word: \nnEnter the amount of the word: \nsEnter a special form (default: nil): ")
  (when (not (stringp @word))
	(error "@WORD must be of type string."))
  (when (or (not (integerp @amount-of)) (<= @amount-of 0))
	(error "@AMOUNT-OF must be of type integer and greater than 0."))
  (when (and (not (null @special-form)) (not (stringp @special-form)))
	(error "@SPECIAL-FORM must be of type string or set to nil."))
  (if (= (truncate @amount-of) 1)
	  (cppimmo/call-when-interactive
	   (lambda ()
		 (message "Inserting %s into the current buffer..." @word)
		 (insert @word))
	   (lambda ()
		 @word))
	(if (or (null @special-form) (string-empty-p @special-form))
		(cppimmo/call-when-interactive
		 (lambda ()
		   (message "Inserting %ss into the current buffer..." @word)
		   (insert (concat @word "s")))
		 (lambda ()
		   (concat @word "s")))
	  (cppimmo/call-when-interactive
	   (lambda ()
		 (message "Inserting %s into the current buffer..." @special-form)
		 (insert @special-form))
	   (lambda ()
		 @special-form)))))

(defun cppimmo/apostrophize (@word &optional @plural-p)
  ""
  (interactive)
  nil)

(defun cppimmo/describe-last-command ()
  "Display the full documentation of the last command."
  (interactive)
  (let (($last-cmd last-command))
  (when (not (commandp $last-cmd))
	(error "LAST-COMMAND must be a command!"))
  (describe-command $last-cmd)))

(defun cppimmo/find-file-sudo (@file-name)
  "Edit file @FILE-NAME as the super user."
  (interactive "FFind file (sudo): ")
  (let (($tramp-file-name
		 (concat "/sudo::" (expand-file-name @file-name))))
	(find-file $tramp-file-name)))

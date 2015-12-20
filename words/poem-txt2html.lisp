#!/usr/bin/env sbcl-script
;;for now, I don't know what
;;else to do other than copy and paste.

(defun $foreach (l f)
  (map nil f l))
(defun requires (&rest l)
  ($foreach l #'require))
(defun imports (&rest l)
  ($foreach l #'import))
(requires 'cl-ppcre 'local-time)
(imports 'cl-ppcre:scan-to-strings 'cl-ppcre:split 'cl-ppcre:scan)

(defun spit (a)
  (format t "~a~%" a))
(defmacro $mapsr (l &rest fs)
  (if (= (length fs) 0)
      l
      `(mapcar ,(first fs) ($mapsr ,l ,@(rest fs)))))
(defmacro $maps (l &rest fs)
  `($mapsr ,l ,@(reverse fs)))
(defmacro strcat (&rest s)
  `(concatenate 'string ,@s))
(defmacro strscat (l)
  `(concatenate 'string ,@l))

(defun getmatch (r l)
  (multiple-value-bind (_ val) (scan-to-strings r l)
    (if val (elt val 0) val)))
(defun getmatches (r l)
  (multiple-value-bind (_ val) (scan-to-strings r l)
    val))
(defun file-read-full (fname)
  (with-open-file (s fname)
    (let ((out (make-string (file-length s))))
      (read-sequence out s) out)))

(defun file-read-lines (fname)
  (labels
      ((gather-lines (s ret)
         (handler-case
             (multiple-value-bind (line) (read-line s)
               (gather-lines s (append ret (list line))))
           (end-of-file () ret))))
    (with-open-file (s fname)
      (gather-lines s '()))))
(defun text-to-<p>-ed (lines)
  (getmatch "((?:.|\\n)*)<p>
$" ;removes last <p>
            (strcat "<p>
"
                    (reduce (lambda (p c) (strcat p c))
                            ($maps lines
                                   (lambda (l)
                                     (strcat l (if (string= l "") "</p><p>
" "<br/>
"))))))))
(spit
 (if (> (length *posix-argv*) 1)
    (text-to-<p>-ed (file-read-lines (elt *posix-argv* 1)))
    "Usage: ./poem-txt2html.lisp <txt-file>"))

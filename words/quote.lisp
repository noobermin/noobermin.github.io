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
(defun to-quote (ins)
  (labels
      ((to-quote-r (s expected ret)
         (if (string= s "") ret
             (let ((cur (subseq s 0 1)))
               (destructuring-bind (expect out)
                   (cond
                     ((string= cur "<") `(">" ,cur))
                     ((string= cur ">") `("" ,cur))
                     ((and (string= cur "\"") (string/= expected ">"))
                      (if (string/= expected "\"")
                          '("\"" "“")
                          '(""   "”")))
                     (t `(,expected ,cur)))
                 (to-quote-r (subseq s 1) expect (strcat ret out)))))))
    (to-quote-r ins "" "")))
(spit
 (if (> (length *posix-argv*) 1)
    (to-quote (file-read-full (elt *posix-argv* 1)))
    "Usage: ./quote.lisp <quotefile>"))

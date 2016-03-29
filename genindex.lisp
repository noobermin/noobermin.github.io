#!/usr/bin/env sbcl-script

(defun $foreach (l f)
  (map nil f l))
(defun requires (&rest l)
  ($foreach l #'require))
(defun imports (&rest l)
  ($foreach l #'import))
(defun spit (a)
  (format t "~a~%" a))

;;jebus
(defun aget (l d)
  (cdr (assoc l d)))
(defmacro $mapsr (l &rest fs)
  (if (= (length fs) 0)
      l
      `(mapcar ,(first fs) ($mapsr ,l ,@(rest fs)))))
(defmacro $maps (l &rest fs)
  `($mapsr ,l ,@(reverse fs)))

(requires 'cl-ppcre 'local-time 'cl-interpol)
(imports 'cl-ppcre:scan-to-strings 'cl-ppcre:split 'cl-ppcre:scan
         'cl-ppcre:regex-replace 'cl-ppcre:regex-replace-all)

(cl-interpol:enable-interpol-syntax)
 

;;string manipulation
(defmacro strcat (&rest s)
  `(concatenate 'string ,@s))
(defun strrep (s r)
  (cond
    ((< r 1) "")
    ((= r 1) s)
    (T
     (concatenate 'string s (strrep s (- r 1))))))
(defun indent (s &optional (depth 1))
  (let* ((indents (strrep "  " depth)) (ret ()))
    (setq ret
          (regex-replace-all
           #?"\n"
           ;;replaces the first line with an indentation
           (regex-replace "^" s indents)
           (strcat #?"\n" indents)))
    (regex-replace #?"${indents}$" ret "")))
(defun strip (s)
  (regex-replace #?"\n$" s ""))


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
(defvar *urlrx* ".*(words/.*\.htm(?:l){0,1})")
(defvar *keywordsrx* "<meta *name=\" *keywords *\" *content=\"(.*)\" */>")
(defvar *titlerx* "<header>(?:.|\\n)*<h1>(.*)</h1>(?:.|\\n)*</header>")
(defvar *daterx* "<header>(?:.|\\n)*<time>(.*)</time>(?:.|\\n)*</header>")
(defvar *us-date-partsrx* "([A-Za-z.]*) *([0-9]{1,2}),{0,1} *([0-9]{1,4})")
(defparameter *months-rx*
  ($maps
   '("January" "Febuary" "March" "April" "May" "June" "July"
     "August"  "September" "October" "November" "December")
   (lambda (s)
     (strcat
      ;;  "[Jj]"
      "[" (subseq s 0 1) (string-downcase (subseq s 0 1)) "]"
      ;;  "an(?:.|uary){0,1}"
      (subseq s 1 3) "(?:.|" (subseq s 3) "){0,1}"))))
(defun month-to-num (s)
  (loop
     for month-rx in *months-rx*
     for i = 0 then (+ i 1)
     do (if (scan month-rx s) (return (+ 1 i)))
     finally (error "not given a valid month string")))
(defun datestr-to-date (s)
  (let ((date (getmatches *us-date-partsrx* s)))
    (if (eq date '())
      (error (strcat "invalid date " s)))
    (list
     (parse-integer (elt date 1)); day
     (month-to-num  (elt date 0)); month
     (parse-integer (elt date 2)))));year
(defun datestr-to-timestamp(s)
  (destructuring-bind (day month year) (datestr-to-date s)
    ;                           nsec sec min hour
    (local-time:encode-timestamp   0   0   0    0 day month year)))
(defun datestr-to-unix(s)
  (local-time:timestamp-to-unix
   (datestr-to-timestamp s)))

;; the shits  
(defun genwords()
  (let* ((words "") (pairs (directory "words/*.htm")))
    (setq pairs
          ($maps pairs
                 (lambda (f) ; first, extra meta data
                   (let* ((text (file-read-full f)))
                     (pairlis
                      '(url title date kw)
                      (list (getmatch *urlrx* (namestring f))
                            (getmatch *titlerx* text)
                            (getmatch *daterx* text)
                            (getmatch *keywordsrx* text)))))
                 (lambda (d) ;and getting the id
                   (acons 'id (getmatch "words/(.*)\.htm"
                                        (aget 'url d)) d))
                 (lambda (d) ;making keywords into tags
                   (let (kw-str)
                     (setq kw-str (reduce
                                   (lambda (a b) (strcat a b))
                                   (mapcar (lambda (l)
                                             #?"<span class='wordstag'>${l}</span>\n")
                                           (split ", *" (aget 'kw d)))))
                     (setq kw-str (strip kw-str))
                     (acons 'kw kw-str d)))
                 (lambda (d) ;adding date info
                   (acons 'unix (datestr-to-unix (aget 'date d)) d))))
    ;;sort by unix time
    (setq pairs (sort pairs #'>
                      :key(lambda (i) (aget 'unix i))))
    (setq words
          (reduce
           (lambda (a b) (strcat a b))
           ($maps
            pairs
            (lambda (i)
              (flet ((d (l) (aget l i)))
                (strcat
#?"<li>
  <a id='${(d 'id)}' href='${(d 'url)}'> ${(d 'title)} </a>
  <time>${(d 'date)}</time>
${(indent (d 'kw))}
</li>
"))))))
    (setq words (strip words))
    ;;last form
#?"<div id='words'>
  <h2>words</h2>
  <ul>
${(indent words 1)}
  </ul>
</div>
"))

(defun genwork ()
  ;;right now, just give the static shit, update this!
"<div id='work'>
  <h2>work</h2>
  <h3>Teacher Assistantship</h3>
  <ul>
    <li>
	  <a id=\"Class Notes\" onclick=\"loadcontent('springnotes/classnotes.htm')\">
        Previous Notes
      </a>
    </li>
  </ul>
</div>")
;;the rest of the webpage
;    <link href='https://fonts.googleapis.com/css?family=Crimson+Text' rel='stylesheet' type='text/css'>

(defvar *html-head*
"<head>
  <title>noobermin</title>
  <meta name='viewport' content='width=device-width, initial-scale=1'>
  <meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
  <link href='https://fonts.googleapis.com/css?family=Average' rel='stylesheet' type='text/css'>
  <link href='style.css' rel='stylesheet' type='text/css'/>
  <script src='jss/htm.js'></script>
  <script src='jss/ani.js'></script>
  <script src='jss/xhr.js'></script>
  <script src='site.js'></script>
  <script async defer src='http://platform.instagram.com/en_US/embeds.js'></script>
</head>
")
(defvar *html-body-title*
#?"<div id='noobermin' onclick='window.location.href=\"\";'>noobermin</div>\n")
(defvar *html-body-topnav*
"<nav id='topnav'>
  <div id='top'>
    <a id='melink' href='#me'>me</a>
    <!--<a id='worklink' href='#work'>work</a>-->
    <a id='wordslink' href='#words'>words</a>
  </div>
  <div id='me'>
    <a id='1' href='http://github.com/noobermin'>1/</a>
    <a id='2' href='http://instagram.com/windywalk'>2/</a>
    <a id='3' href='http://twitter.com/noobermin'>3/</a>
   </div>
</nav>
")
(defvar *html-body-sidenav*
  (strcat #?"<nav id='sidenav'>\n"
          (indent (genwords))
          ;;(indent (genwork))
          #?"</nav>\n"))

(defvar *html-main*
  (strcat #?"<div id='main'>\n"
          #?"  <div id='content'></div>\n"
          (indent *html-body-sidenav*)
          #?"</div>\n"))
          

(defvar *index*
  (strcat
   #?"<!DOCTYPE html>\n<html>\n"
   *html-head*
   #?"<body>\n"
   (indent *html-body-title*)
   (indent *html-main*)
   (indent #?"<hr id='hr'/>\n")
   (indent *html-body-topnav*)
   (indent #?"\n<script>window.onload=init;</script>\n")
   #?"</body>\n</html>"))
(with-open-file (stream "index.htm"
                        :direction :output :if-exists :supersede)
  (write-sequence *index* stream))

#!/usr/bin/env sbcl-script

(defun $foreach (l f)
  (map nil f l))
(defun requires (&rest l)
  ($foreach l #'require))
(defun imports (&rest l)
  ($foreach l #'import))
(defun spit (a)
  (format t "~a~%" a))
(defmacro $mapsr (l &rest fs)
  (if (= (length fs) 0)
      l
      `(mapcar ,(first fs) ($mapsr ,l ,@(rest fs)))))
(defmacro $maps (l &rest fs)
  `($mapsr ,l ,@(reverse fs)))

(requires 'cl-ppcre 'local-time)

(imports 'cl-ppcre:scan-to-strings 'cl-ppcre:split 'cl-ppcre:scan)
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
(defvar *urlrx* ".*(words/.*\.htm(?:l){0,1})")
(defvar *keywordsrx* "<meta *name=\" *keywords *\" *content=\"(.*)\" */>")
(defvar *titlerx* "<header>(?:.|\\n)*<h1>(.*)</h1>(?:.|\\n)*</header>")
(defvar *daterx* "<header>(?:.|\\n)*<time>(.*)</time>(?:.|\\n)*</header>")
(defvar *us-date-partsrx* "([A-Za-z.]*) *([0-9]{1,2}),{0,1} *([0-9]{1,4})")
(defparameter *months-rx*
  ($maps
   '("January" "Febuary" "March" "April" "June" "July"
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
        (error "invalid date"))
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
  (let*
      ((ret "")
       (pairs
        ($maps
         (directory "words/*.htm")
         (lambda (f) ; first, extra meta data
           (let* ((text (file-read-full f)))
             (list
              (getmatch *urlrx* (namestring f))
              (getmatch *titlerx* text)
              (getmatch *daterx* text)
              (getmatch *keywordsrx* text))))
         (lambda (i) ;and getting the id
           (destructuring-bind (url title date kw) i
             (list
              (getmatch "words/(.*)\.htm" url)
              url title date kw)))
         (lambda (i) ;making keywords into tags
           (destructuring-bind (id url title date kw) i
             (list
              id url title date
              (reduce (lambda (a b) (strcat a b))
                      (mapcar (lambda (l) (strcat "<span class='wordstag'>"
                                                  l "</span>"))
                              (split ", *" kw))))))
         (lambda (i) ;adding date info
           (destructuring-bind (id url title date kw) i
             (list
              id url title date kw
              (datestr-to-unix date)))))))
    ;;sort by unix time
    (setq pairs (sort pairs #'>
                      :key(lambda (i) (elt i 5))))
    (setq ret (reduce (lambda (a b) (strcat a b))
            ($maps
             pairs
             (lambda (i)
               (destructuring-bind (id url title date kw unix) i
                 (strcat "<li>
  <a id='" id "' href='" url "'>" title "</a>
  <time>" date "</time>
  " kw "
</li>
"))))))
  (strcat "<div id='words'>
<h2>words</h2>
<ul>
" ret "</ul>
</div>")))
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
    <link href='https://fonts.googleapis.com/css?family=Arimo' rel='stylesheet' type='text/css'>
    <link href='https://fonts.googleapis.com/css?family=Average' rel='stylesheet' type='text/css'>
	<link href='style.css' rel='stylesheet' type='text/css'/>
	<link href='pc.css' media='(min-width: 700px)' rel='stylesheet'  type='text/css' />
	<link href='m.css' media='(max-width: 700px)' rel='stylesheet'  type='text/css' />
	<script src='jss/htm.js'></script>
	<script src='jss/ani.js'></script>
	<script src='sitej.js'></script>
    <script async defer src='http://platform.instagram.com/en_US/embeds.js'></script>
</head>")
(defvar *html-body-title*
"<div id=\"noobermin\" onclick=\"window.location.href='';\">noobermin</div>
<hr id='hr'/>")
(defvar *html-body-topnav*
"<nav id='topnav'>
  <div id='top'>
    <a id='melink' href='#me'>me.</a>
    <a id='worklink' href='#work'>work.</a>
    <a id='wordslink' href='#words'>words.</a>
  </div>
  <div id='me'>
    <a id='1' href='http://github.com/noobermin'>1/</a>
    <a id='2' href='http://instagram.com/windywalk''>2/</a>
    <a id='3' href='http://twitter.com/noobermin'>3/</a>
   </div>
</nav>")
(defvar *html-body-sidenav*
  (strcat "<nav id='sidenav'>" (genwords) (genwork) "</nav>"))

(defvar *html-main* (strcat
"<div id='main'>
" *html-body-sidenav* "
<div id='content'></div>
</div>"))

(spit (strcat "<!DOCTYPE html>
<html>" *html-head* "
<body>
" *html-body-title* *html-body-topnav* *html-main* "
<script>window.onload=init;</script>
</body>
</html>"))

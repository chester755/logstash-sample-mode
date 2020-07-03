;;;This is a simple convert that I adept from qmake-mode:  https://github.com/inlinechan/qmake-mode
;;;Essentially everything is copied apart from few changes that I have to add to adept to logstash mode
;;;The main reason I create this one is because the logstash mode available:
;;;https://github.com/Wilfred/logstash-conf.el is very slow when calculating indentation.
;;;In most of cases we only need a simple looking back indentation algorithm and this simple does that

;;;Also I have tried smie implementation and for some reason it won't indent comment correctly.
;;;I might re-try that at somepoint

(defmacro logstash-sample-debug (&rest _args))
(defvar logstash-sample-mode-hook nil)
(defvar logstash-sample-mode-map
  (let ((logstash-sample-mode-map (make-keymap)))
    (define-key logstash-sample-mode-map "\C-j" 'newline-and-indent)
    logstash-sample-mode-map)
  "Keymap for LOGSTASH-SAMPLE major mode.")

(defcustom logstash-sample-indent-width 2
  "The width for further indentation in logstash-sample mode."
  :type 'integer
  :group 'logstash-sample-mode)
(put 'logstash-sample-indent-width 'safe-local-variable 'integerp)

(defvar logstash-sample-builtin-variables
  '("if"
    "else if"
    "else")
  "Logstash-Sample builtin."
  )

(defvar logstash-sample-plugin-variables
  '("kv"
    "aggregate"
    "aggregate"
    "alter"
    "bytes"
    "cidr"
    "cipher"
    "clone"
    "csv"
    "date"
    "de_dot"
    "dissect"
    "dns"
    "drop"
    "elapsed"
    "elasticsearch"
    "environment"
    "extractnumbers"
    "fingerprint"
    "geoip"
    "grok"
    "http"
    "i18n"
    "java_uuid"
    "jdbc_static"
    "jdbc_streaming"
    "json"
    "json_encode"
    "kv"
    "memcached"
    "metricize"
    "metrics"
    "mutate"
    "prune"
    "range"
    "ruby"
    "sleep"
    "split"
    "syslog_pri"
    "threats_classifier"
    "throttle"
    "tld"
    "translate"
    "truncate"
    "urldecode"
    "useragent"
    "uuid"
    "xml"
    )
  "Logstash-Sample plugins."
  )

(defvar logstash-sample-common-variables
  '("add_field"
    "add_tag"
    "enable_metric"
    "id"
    "periodic_flush"
    "remove_field"
    "remove_tag"
    )
  "Logstash-Sample common configurations"
  )

(defvar logstash-sample-builtin-regexp (regexp-opt logstash-sample-builtin-variables 'words))
(defvar logstash-sample-functions-regexp (regexp-opt logstash-sample-plugin-variables 'words))
(defvar logstash-sample-variables-regexp (regexp-opt logstash-sample-common-variables 'words))

(defvar logstash-sample-font-lock-keywords
  (list
   '("#.*" . font-lock-comment-face)
   `(,logstash-sample-functions-regexp . ,font-lock-function-name-face)
   `(,logstash-sample-builtin-regexp . ,font-lock-builtin-face)
   `(,logstash-sample-variables-regexp . ,font-lock-constant-face))
  "Default highlighting expressions for LOGSTASH-SAMPLE mode.")

(defvar logstash-sample-mode-syntax-table
  (let ((logstash-sample-mode-syntax-table (make-syntax-table)))
    (modify-syntax-entry ?_ "w" logstash-sample-mode-syntax-table)
    (modify-syntax-entry ?\n "> b" logstash-sample-mode-syntax-table)
    logstash-sample-mode-syntax-table)
  "Syntax table for logstash-sample-mode.")

(defun logstash-sample-current-indent-type ()
  "Return current indent type."
  (let ((result))
    (save-excursion
      (end-of-line)
      (setq result (logstash-sample-parse-line t)))
    (when (listp result)
      (car (car result))))
  )

(defun logstash-sample-parent-indent-type ()
  "Return list of parent indent type.  Order by nearest first."
  (interactive)
  (let ((done)
        (line (save-excursion (forward-line -1)))
        (result))
    (save-excursion
      (while (and (not done) (= line 0))
        (setq line (forward-line -1))
        (end-of-line)
        (setq result (append result (logstash-sample-parse-line nil)))))
    result))

(defun logstash-sample-indent-line ()
  "Indent line when it's in `logstash-sample-mode'."
  (interactive)
  (let* ((current (logstash-sample-current-indent-type))
         (indent-base 0)
         (parent-list (logstash-sample-parent-indent-type))
         (parent (and parent-list (car parent-list)))
         (parent-type (and parent (car parent)))
         (parent-point (and parent (cdr parent))))
    (let ((p)
          (pl parent-list)
          (pt parent-type)
          (pp))
      (when (eq pt 'line-cont-end)
        (while (or (eq pt 'line-cont-end) (eq pt 'line-cont))
          (setq p (car (cdr pl)))
          (setq pl (cdr pl))
          (setq pt (car p))
          (setq pp (cdr p)))
        (setq indent-base (save-excursion
                            (Goto-char pp)
                            (current-indentation)))))
    (cond
     ((or (eq parent-type 'brace-open) (eq parent-type 'brace-close-open))
      (setq indent-base (save-excursion
                          (goto-char parent-point)
                          (+ (current-indentation) logstash-sample-indent-width))))
     ((eq parent-type 'brace-close)
      (setq indent-base (save-excursion
                          (goto-char parent-point)
                          (current-indentation))))
     ((eq parent-type 'line-cont-begin)
      (setq indent-base (save-excursion
                          (goto-char parent-point)
                          (+ (current-indentation) logstash-sample-indent-width))))
     ((eq parent-type 'line-cont)
      (setq indent-base (save-excursion
                          (goto-char parent-point)
                          (current-indentation)))))
    (logstash-sample-debug "current: %s, parent: %s, indent-base: %s" current parent indent-base)
    (cond
     ((null parent)
      (indent-line-to (+ 0 indent-base)))
     ((eq current 'brace-close)
      (indent-line-to (save-excursion
                        (beginning-of-line)
                        (looking-at "^[ \t]*}")
			(looking-at "^[ \t]*\\]")
			(looking-at "^[ \t]*)")
                        (goto-char (match-end 0))
                        (ignore-errors
                          (backward-list 1))
                        (current-indentation))))
     ((eq current 'brace-close-open)
      (indent-line-to (save-excursion
                        (goto-char (cdr (assoc 'brace-open parent-list)))
                        (current-indentation))))
     ;; ((eq current 'default)
     ;;  (indent-line-to indent-base))
     ;; ((eq current 'line-cont-begin)
     ;;  (indent-line-to indent-base))
     ;; ((eq current 'brace-open)
     ;;  (indent-line-to indent-base))
     (t
      (indent-line-to indent-base))
     )))

(define-derived-mode logstash-sample-mode prog-mode "logstash-sample"
  "A major mode for logstash-sample."
  :syntax-table logstash-sample-mode-syntax-table
  (setq-local comment-start "# ")
  (setq-local comment-end "")
  ;(setq-local comment-start-skip "#+\\s-*")
  (setq-local font-lock-defaults
              '(logstash-sample-font-lock-keywords))
  (setq-local indent-line-function 'logstash-sample-indent-line)
  (run-hooks 'logstash-sample-mode-hook))

(defun logstash-sample-parse-line (add-default)
  (let ((result))
    (cond
     ((looking-back "^.*[ \t]*\\\\$" (line-beginning-position))
      (progn
        (goto-char (match-end 0))
        (let ((prev-cont
               (save-excursion
                 (and (= (forward-line -1) 0)
                      (progn
                        (end-of-line)
                        (looking-back "^.*[ \t]*\\\\$"
                                      (line-beginning-position)))))))
          (if prev-cont
              (add-to-list 'result `(line-cont . ,(1- (point))))
            (add-to-list 'result `(line-cont-begin . ,(1- (point))))))))
     ((looking-back "^[ \t]*}.*[ \t]*{$" (line-beginning-position))
      (progn
        (goto-char (match-end 0))
        (add-to-list 'result `(brace-close-open . ,(1- (point))))))
     ((looking-back "^.*[ \t]*{" (line-beginning-position))
      (progn
        (goto-char (match-end 0))
        (add-to-list 'result `(brace-open . ,(1- (point))))))
     ((looking-back "^[ \t]*}$" (line-beginning-position))
      (progn
        (goto-char (match-end 0))
        (add-to-list 'result `(brace-close . ,(1- (point))))))
     ((looking-back "^[ \t]*\\].*[ \t]*\\[$" (line-beginning-position))
      (progn
        (goto-char (match-end 0))
        (add-to-list 'result `(brace-close-open . ,(1- (point))))))
     ((looking-back "^.*[ \t]*\\[" (line-beginning-position))
      (progn
        (goto-char (match-end 0))
        (add-to-list 'result `(brace-open . ,(1- (point))))))
     ((looking-back "^[ \t]*\\]$" (line-beginning-position))
      (progn
        (goto-char (match-end 0))
        (add-to-list 'result `(brace-close . ,(1- (point))))))
     ((looking-back "^[ \t]*).*[ \t]*($" (line-beginning-position))
      (progn
        (goto-char (match-end 0))
        (add-to-list 'result `(brace-close-open . ,(1- (point))))))
     ((looking-back "^.*[ \t]*(" (line-beginning-position))
      (progn
        (goto-char (match-end 0))
        (add-to-list 'result `(brace-open . ,(1- (point))))))
     ((looking-back "^[ \t]*)$" (line-beginning-position))
      (progn
        (goto-char (match-end 0))
        (add-to-list 'result `(brace-close . ,(1- (point))))))     
     (t
      (let ((orig-point (point))
            (prev-line-cont
             (save-excursion
               (and (= 0 (forward-line -1))
                    (progn
                      (end-of-line)
                      (looking-back "^.*[ \t]*\\\\$"
                                    (line-beginning-position)))))))
        (if prev-line-cont
            (add-to-list 'result `(line-cont-end . ,(1- orig-point)))
          (when add-default
            (add-to-list 'result `(default . ,0))))))
     )                              ;cond
    result))

(add-to-list 'auto-mode-alist '("\\.conf\\'" . logstash-sample-mode))

(provide 'logstash-sample-mode)

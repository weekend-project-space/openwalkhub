;; Minimal helpers shared by Scheme tools.
;;
;; Usage:
;;   (def answer 42)
;;   (def (add a b) (+ a b))
;;   (defun add (a b) (+ a b))
;;   (open "https://example.com")
;;   (open "https://example.com" #t)

(define-syntax def
  (syntax-rules ()
    ((_ name value)
     (define name value))
    ((_ (name . args) body ...)
     (define (name . args) body ...))))

(define-syntax defun
  (syntax-rules ()
    ((_ name formals body ...)
     (define (name . formals) body ...))))

(defun %browser-session-exists? (session-name)
  (let ((sessions (browser-list)))
    (let loop ((index 0))
      (if (>= index (vector-length sessions))
          #f
          (if (equal? session-name (vector-ref sessions index))
              #t
              (loop (+ index 1)))))))

(defun %tab-field (tab key)
  (let ((entry (assoc key tab)))
    (if entry (cdr entry) #f)))

(defun %tab-url-id-alist ()
  (let loop ((tabs (tab-list)) (pairs '()))
    (if (null? tabs)
        (reverse pairs)
        (let* ((tab (car tabs))
               (url (%tab-field tab "url"))
               (id (%tab-field tab "id")))
          (if (and url id)
              (loop (cdr tabs) (cons (cons url id) pairs))
              (loop (cdr tabs) pairs))))))

(defun %url-with-trailing-slash (url)
  (if (and (> (string-length url) 0)
           (not (char=? (string-ref url (- (string-length url) 1)) #\/)))
      (string-append url "/")
      url))

(defun %url-without-trailing-slash (url)
  (if (and (> (string-length url) 0)
           (char=? (string-ref url (- (string-length url) 1)) #\/))
      (substring url 0 (- (string-length url) 1))
      url))

(defun %find-tab-by-url (url)
  (let* ((pairs (%tab-url-id-alist))
         (entry (or (assoc url pairs)
                    (assoc (%url-with-trailing-slash url) pairs)
                    (assoc (%url-without-trailing-slash url) pairs))))
    (if entry (cdr entry) #f)))

(defun %open-impl (url no-reuse-tab)
  (let ((session-name openwalk-session-name))
    (if (and session-name (%browser-session-exists? session-name))
        (if no-reuse-tab
            (tab-new url)
            (let ((tab-id (%find-tab-by-url url)))
              (if tab-id
                  (tab-select tab-id)
                  (tab-new url))))
        (browser-open url))))

(define-syntax open
  (syntax-rules ()
    ((_ url)
     (%open-impl url #f))
    ((_ url no-reuse-tab)
     (%open-impl url no-reuse-tab))))

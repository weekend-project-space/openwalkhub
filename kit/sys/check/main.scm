#| @meta
{
  "name": "check",
  "description": "查看网页信息",
  "args": [
    {
      "name": "url",
      "type": "string",
      "required": false,
      "description": "网址"
    },
    {
      "name": "max_inline",
      "type": "number",
      "required": false,
      "default": 12000,
      "description": "auto 模式下直接返回内容的最大字符数，默认 12000"
    },
    {
      "name": "output",
      "type": "string",
      "required": false,
      "default": "auto",
      "description": "输出方式：auto、inline、file"
    }
  ],
  "returns": {
    "type": "object",
    "description": "短内容返回 markdown 字符串；长内容返回 { file, length, preview }"
  },
  "examples": [
    "openwalk exec check",
    "openwalk exec check -- https://example.com",
    "openwalk exec check -- https://example.com --output file"
  ],
  "domains": [],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "example",
    "snapshot"
  ]
}
|#


(defun %min (a b)
  (if (< a b) a b))

(defun %write-string-file (path text)
  (call-with-output-file path
    (lambda (port)
      (write-string text port))))

(defun %make-check-path ()
  (string-append
    ".openwalk/check-"
    (js-eval "new Date().toISOString().replace(/[:.]/g,'-')")
    ".md"))

(defun %spill-check-result (markdown reason)
  (define path (%make-check-path))
  (define length (string-length markdown))
  (%write-string-file path markdown)
  (list
    (cons "preview" (substring markdown 0 (%min length 1200)))
    (cons "file" path)
    (cons "length" length)
    (cons "truncated" #t)
    (cons "reason" reason)))

(defun %format-check-result (markdown params)
  (define output (alist-get params "output"))
  (define max-inline (alist-get params "max_inline"))
  (define length (string-length markdown))
  (cond
    ((equal? output "inline")
     markdown)
    ((equal? output "file")
     (%spill-check-result markdown "output=file"))
    ((equal? output "auto")
     (if (> length max-inline)
         (%spill-check-result markdown "content_too_large")
         markdown))
    (else
      (list
        (cons "error" (string-append "Invalid output: " output))
        (cons "hint" "Supported output: auto, inline, file")))))

(defun main (args)
  (def params (parse-args args))
  (if (null? args)
      (tab-list)
      (open (alist-get params "url")))
  (%format-check-result (js-run "main.js" args) params))

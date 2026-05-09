#| @meta
{
  "name": "linuxdo/hot",
  "description": "获取 Linux.do 热门主题并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 30,
      "description": "返回结果数量，默认 30，最大 50"
    },
    {
      "name": "period",
      "type": "string",
      "required": false,
      "default": "daily",
      "description": "榜单周期：daily、weekly、monthly、quarterly、yearly、all"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, period, source, topics[] }"
  },
  "examples": [
    "openwalk exec linuxdo/hot",
    "openwalk exec linuxdo/hot -- 20 weekly"
  ],
  "domains": [
    "linux.do"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "linuxdo",
    "hot",
    "topics"
  ]
}
|#

(defun %normalized-args (args)
  (let ((arg1 (if (null? args) #f (car args)))
        (arg2 (if (or (null? args) (null? (cdr args))) #f (cadr args))))
    (cond
      ((null? args) '())
      ((and arg1 (string->number arg1))
       (if arg2
           (list "--count" arg1 "--period" arg2)
           (list "--count" arg1)))
      (arg2
       (list "--period" arg1 "--count" arg2))
      (else
       (list "--period" arg1)))))

(defun main (args)
  (let ((normalized-args (%normalized-args args)))
    (open "https://linux.do")
    (js-file-call "main.js" normalized-args)))

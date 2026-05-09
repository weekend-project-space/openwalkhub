#| @meta
{
  "name": "reddit/hot",
  "description": "获取 Reddit 热门帖子并返回结构化结果",
  "args": [
    {
      "name": "subreddit",
      "type": "string",
      "required": false,
      "description": "可选的 subreddit 名称，不带 r/ 前缀"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 25,
      "description": "返回帖子数量，默认 25，最大 100"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ subreddit, count, posts[] }"
  },
  "examples": [
    "openwalk exec reddit/hot",
    "openwalk exec reddit/hot -- LocalLLaMA 20"
  ],
  "domains": [
    "www.reddit.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "reddit",
    "hot",
    "posts"
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
           (list "--count" arg1 "--subreddit" arg2)
           (list "--count" arg1)))
      (arg2
       (list "--subreddit" arg1 "--count" arg2))
      (else
       (list "--subreddit" arg1)))))

(defun main (args)
  (let ((normalized-args (%normalized-args args)))
    (open "https://www.reddit.com")
    (js-file-call "main.js" normalized-args)))

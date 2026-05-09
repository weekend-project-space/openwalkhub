#| @meta
{
  "name": "hackernews/thread",
  "description": "获取 Hacker News 帖子详情和评论列表并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": true,
      "description": "Hacker News item ID"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ post, comments[] }"
  },
  "examples": [
    "openwalk exec hackernews/thread -- 12345678"
  ],
  "domains": [
    "news.ycombinator.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "hackernews",
    "thread",
    "comments"
  ]
}
|#

(defun main (args)
  (let* ((params (parse-args args))
         (item-id (alist-get params "id")))
    (open
      (string-append "https://news.ycombinator.com/item?id=" item-id))
    (js-wait
      "(() => {
        return !!document.querySelector('.fatitem, .athing.comtr');
      })()")
    (js-file-call "main.js" args)))

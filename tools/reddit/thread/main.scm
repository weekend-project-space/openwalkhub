#| @meta
{
  "name": "reddit/thread",
  "description": "获取 Reddit 帖子详情和评论列表并返回结构化结果",
  "args": [
    {
      "name": "url",
      "type": "string",
      "required": true,
      "description": "Reddit 帖子 URL"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ post, comments_total, comments[] }"
  },
  "examples": [
    "openwalk exec reddit/thread -- https://www.reddit.com/r/LocalLLaMA/comments/1rrisqn/example/"
  ],
  "domains": [
    "www.reddit.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "reddit",
    "thread",
    "comments"
  ]
}
|#

(defun main (args)
  (open "https://www.reddit.com")
  (js-file-call "main.js" args))

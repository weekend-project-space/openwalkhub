#| @meta
{
  "name": "reddit/context",
  "description": "获取 Reddit 评论的 ancestor chain 并返回结构化结果",
  "args": [
    {
      "name": "url",
      "type": "string",
      "required": true,
      "description": "Reddit comment URL"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ post, target_comment, ancestor_chain[] }"
  },
  "examples": [
    "openwalk exec reddit/context -- https://www.reddit.com/r/LocalLLaMA/comments/1rso48p/comment/oa8domi/"
  ],
  "domains": [
    "www.reddit.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "reddit",
    "context",
    "comments"
  ]
}
|#

(defun main (args)
  (open "https://www.reddit.com")
  (js-file-call "main.js" args))

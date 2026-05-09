#| @meta
{
  "name": "v2ex/topic",
  "description": "获取 V2EX 主题详情和回复并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": true,
      "description": "V2EX topic ID"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ topic_source, replies_source, id, title, content, node, author, replies, created, url, comment_count, comments[] }"
  },
  "examples": [
    "openwalk exec v2ex/topic -- 1024"
  ],
  "domains": [
    "www.v2ex.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "v2ex",
    "topic",
    "replies"
  ]
}
|#

(defun main (args)
  (open "https://www.v2ex.com")
  (js-run "main.js" args))

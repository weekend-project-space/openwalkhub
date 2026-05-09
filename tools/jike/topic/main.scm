#| @meta
{
  "name": "jike/topic",
  "description": "获取 JIKE 主题详情和回复并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": true,
      "description": "主题 tid 或 slug"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ id, title, category, author, posts, view_count, comments[] }"
  },
  "examples": [
    "openwalk exec jike/topic -- 35558",
    "openwalk exec jike/topic -- 35558/deeplx-免费-api-每天-50万字符配额"
  ],
  "domains": [
    "jike.info"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "jike",
    "topic",
    "comments"
  ]
}
|#

(defun main (args)
  (open "https://jike.info")
  (js-run "main.js" args))

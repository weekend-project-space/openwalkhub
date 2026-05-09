#| @meta
{
  "name": "linkedin/search",
  "description": "搜索 LinkedIn 帖子并返回结构化结果",
  "args": [
    {
      "name": "query",
      "type": "string",
      "required": true,
      "description": "搜索关键词"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 10,
      "description": "返回结果数量，默认 10，最大 30"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, count, posts[] }"
  },
  "examples": [
    "openwalk exec linkedin/search -- \"AI agent\""
  ],
  "domains": [
    "www.linkedin.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "linkedin",
    "search",
    "posts"
  ]
}
|#

(defun main (args)
  (open "https://www.linkedin.com")
  (js-run "main.js" args))

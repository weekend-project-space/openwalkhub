#| @meta
{
  "name": "devto/search",
  "description": "搜索 Dev.to 文章并返回结构化结果",
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
      "default": 20,
      "description": "返回结果数量，默认 20，最大 60"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, count, articles[] }"
  },
  "examples": [
    "openwalk exec devto/search -- \"rust programming\""
  ],
  "domains": [
    "dev.to"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "devto",
    "search",
    "articles"
  ]
}
|#

(defun main (args)
  (open "https://dev.to")
  (js-file-call "main.js" args))

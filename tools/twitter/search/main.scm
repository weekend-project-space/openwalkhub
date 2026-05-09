#| @meta
{
  "name": "twitter/search",
  "description": "搜索推文并返回结构化结果",
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
      "description": "返回结果数量，默认 20，最大 50"
    },
    {
      "name": "type",
      "type": "string",
      "required": false,
      "default": "latest",
      "description": "结果类型：latest 或 top"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, product, count, tweets[] }"
  },
  "examples": [
    "openwalk exec twitter/search -- \"claude code\""
  ],
  "domains": [
    "x.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "twitter",
    "search",
    "tweets"
  ]
}
|#

(defun main (args)
  (open "https://x.com")
  (js-file-call "main.js" args))

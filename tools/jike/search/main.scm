#| @meta
{
  "name": "jike/search",
  "description": "搜索 JIKE 主题和帖子并返回结构化结果",
  "args": [
    {
      "name": "keyword",
      "type": "string",
      "required": true,
      "description": "搜索关键词"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 10,
      "description": "返回条数，默认 10，最大 20"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ keyword, count, posts[] }"
  },
  "examples": [
    "openwalk exec jike/search -- ChatGPT",
    "openwalk exec jike/search -- DeepLX 10"
  ],
  "domains": [
    "jike.info"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "jike",
    "search"
  ]
}
|#

(defun main (args)
  (open "https://jike.info")
  (js-run "main.js" args))

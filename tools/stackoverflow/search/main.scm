#| @meta
{
  "name": "stackoverflow/search",
  "description": "搜索 Stack Overflow 问题并返回结构化结果",
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
      "description": "返回结果数量，默认 10，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, count, has_more, quota_remaining, questions[] }"
  },
  "examples": [
    "openwalk exec stackoverflow/search -- \"python async await\""
  ],
  "domains": [
    "stackoverflow.com",
    "api.stackexchange.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "stackoverflow",
    "search",
    "questions"
  ]
}
|#

(defun main (args)
  (open "https://stackoverflow.com")
  (js-file-call "main.js" args))

#| @meta
{
  "name": "twitter/tweets",
  "description": "获取用户最近推文并返回结构化结果",
  "args": [
    {
      "name": "screen_name",
      "type": "string",
      "required": true,
      "description": "Twitter handle，不带 @"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回推文数量，默认 20，最大 100"
    },
    {
      "name": "cursor",
      "type": "string",
      "required": false,
      "description": "分页 cursor"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ screen_name, user_id, count, next_cursor, tweets[] }"
  },
  "examples": [
    "openwalk exec twitter/tweets -- plantegg"
  ],
  "domains": [
    "x.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "twitter",
    "tweets",
    "timeline"
  ]
}
|#

(defun main (args)
  (open "https://x.com")
  (js-file-call "main.js" args))

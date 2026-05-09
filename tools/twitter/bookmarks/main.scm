#| @meta
{
  "name": "twitter/bookmarks",
  "description": "获取 Twitter 书签列表并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回书签数量，默认 20，最大 100"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, tweets[] }"
  },
  "examples": [
    "openwalk exec twitter/bookmarks -- 10"
  ],
  "domains": [
    "x.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "twitter",
    "bookmarks",
    "tweets"
  ]
}
|#

(defun main (args)
  (open "https://x.com")
  (js-run "main.js" args))

#| @meta
{
  "name": "twitter/for_you",
  "description": "获取 For You 时间线并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回推文数量，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, tweets[] }"
  },
  "examples": [
    "openwalk exec twitter/for_you"
  ],
  "domains": [
    "x.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "twitter",
    "for-you",
    "timeline"
  ]
}
|#

(defun main (args)
  (open "https://x.com")
  (js-run "main.js" args))

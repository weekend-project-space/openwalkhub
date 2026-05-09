#| @meta
{
  "name": "twitter/notifications",
  "description": "获取 Twitter 通知并返回结构化结果",
  "args": [
    {
      "name": "type",
      "type": "string",
      "required": false,
      "default": "all",
      "description": "通知类型：all、mentions、likes、retweets"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回通知数量，默认 20，最大 50"
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
    "description": "{ type, count, notifications[] } 或 { engagement, mentions, total }"
  },
  "examples": [
    "openwalk exec twitter/notifications",
    "openwalk exec twitter/notifications -- mentions"
  ],
  "domains": [
    "x.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "twitter",
    "notifications",
    "mentions"
  ]
}
|#

(defun main (args)
  (open "https://x.com")
  (js-run "main.js" args))

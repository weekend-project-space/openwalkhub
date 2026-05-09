#| @meta
{
  "name": "bilibili/feed",
  "description": "获取 Bilibili 关注动态 feed 并返回结构化结果",
  "args": [
    {
      "name": "type",
      "type": "string",
      "required": false,
      "default": "all",
      "description": "动态类型：all、video、article"
    },
    {
      "name": "page",
      "type": "number",
      "required": false,
      "default": 1,
      "description": "页码，默认 1"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回数量，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ type, page, count, items[] }"
  },
  "examples": [
    "openwalk exec bilibili/feed",
    "openwalk exec bilibili/feed -- --type video --count 10"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com",
    "t.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "bilibili",
    "feed",
    "dynamic"
  ]
}
|#

(defun main (args)
  (open "https://t.bilibili.com")
  (js-file-call "main.js" args))

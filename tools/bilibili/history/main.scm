#| @meta
{
  "name": "bilibili/history",
  "description": "获取 Bilibili 观看历史并返回结构化结果",
  "args": [
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
    "description": "{ count, items[] }"
  },
  "examples": [
    "openwalk exec bilibili/history -- 10"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "bilibili",
    "history",
    "videos"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-run "main.js" args))

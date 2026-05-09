#| @meta
{
  "name": "bilibili/trending",
  "description": "获取 Bilibili 热搜词并返回结构化结果",
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
    "openwalk exec bilibili/trending"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "trending",
    "keywords"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-file-call "main.js" args))

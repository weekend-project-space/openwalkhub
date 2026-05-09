#| @meta
{
  "name": "bilibili/user-opus",
  "description": "获取 Bilibili 用户图文动态列表并返回结构化结果",
  "args": [
    {
      "name": "mid",
      "type": "string",
      "required": true,
      "description": "用户 mid"
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
    "description": "{ mid, count, items[] }"
  },
  "examples": [
    "openwalk exec bilibili/user-opus -- 2",
    "openwalk exec bilibili/user-opus -- --mid 2 --count 10"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com",
    "t.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "user",
    "opus"
  ]
}
|#

(defun main (args)
  (open "https://t.bilibili.com")
  (js-file-call "main.js" args))

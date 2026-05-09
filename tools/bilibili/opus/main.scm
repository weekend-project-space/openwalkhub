#| @meta
{
  "name": "bilibili/opus",
  "description": "获取 Bilibili 图文动态详情并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": true,
      "description": "动态 ID"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ id, author, title, text, images[], stat, url }"
  },
  "examples": [
    "openwalk exec bilibili/opus -- 949321621570527281"
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
    "opus",
    "dynamic"
  ]
}
|#

(defun main (args)
  (open "https://t.bilibili.com")
  (js-run "main.js" args))

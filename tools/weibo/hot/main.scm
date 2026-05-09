#| @meta
{
  "name": "weibo/hot",
  "description": "获取微博热搜榜并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回条数，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, items[] }"
  },
  "examples": [
    "openwalk exec weibo/hot",
    "openwalk exec weibo/hot -- 10"
  ],
  "domains": [
    "s.weibo.com",
    "weibo.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "weibo",
    "hot",
    "trending"
  ]
}
|#

(defun main (args)
  (open "https://s.weibo.com")
  (js-file-call "main.js" args))

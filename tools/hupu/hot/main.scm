#| @meta
{
  "name": "hupu/hot",
  "description": "获取虎扑热帖并返回结构化结果",
  "args": [],
  "returns": {
    "type": "object",
    "description": "{ count, items[] }"
  },
  "examples": [
    "openwalk exec hupu/hot"
  ],
  "domains": [
    "bbs.hupu.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "hupu",
    "hot",
    "posts"
  ]
}
|#

(defun main (args)
  (open "https://bbs.hupu.com")
  (js-file-call "main.js" args))

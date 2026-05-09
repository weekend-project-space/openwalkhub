#| @meta
{
  "name": "v2ex/hot",
  "description": "获取 V2EX 热门主题并返回结构化结果",
  "args": [],
  "returns": {
    "type": "object",
    "description": "{ source, count, topics[] }"
  },
  "examples": [
    "openwalk exec v2ex/hot"
  ],
  "domains": [
    "www.v2ex.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "v2ex",
    "hot",
    "topics"
  ]
}
|#

(defun main (args)
  (open "https://www.v2ex.com")
  (js-file-call "main.js" args))

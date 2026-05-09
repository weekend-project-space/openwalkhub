#| @meta
{
  "name": "v2ex/latest",
  "description": "获取 V2EX 最新主题并返回结构化结果",
  "args": [],
  "returns": {
    "type": "object",
    "description": "{ source, count, topics[] }"
  },
  "examples": [
    "openwalk exec v2ex/latest"
  ],
  "domains": [
    "www.v2ex.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "v2ex",
    "latest",
    "topics"
  ]
}
|#

(defun main (args)
  (open "https://www.v2ex.com")
  (js-run "main.js" args))

#| @meta
{
  "name": "jike/latest",
  "description": "获取 JIKE 最新主题并返回结构化结果",
  "args": [
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
    "description": "{ page, count, topics[] }"
  },
  "examples": [
    "openwalk exec jike/latest",
    "openwalk exec jike/latest -- --page 2 --count 10"
  ],
  "domains": [
    "jike.info"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "jike",
    "latest",
    "topics"
  ]
}
|#

(defun main (args)
  (open "https://jike.info")
  (js-file-call "main.js" args))

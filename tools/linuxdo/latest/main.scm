#| @meta
{
  "name": "linuxdo/latest",
  "description": "获取 Linux.do 最新主题并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 30,
      "description": "返回结果数量，默认 30，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, source, topics[] }"
  },
  "examples": [
    "openwalk exec linuxdo/latest",
    "openwalk exec linuxdo/latest -- 20"
  ],
  "domains": [
    "linux.do"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "linuxdo",
    "latest",
    "topics"
  ]
}
|#

(defun main (args)
  (open "https://linux.do")
  (js-run "main.js" args))

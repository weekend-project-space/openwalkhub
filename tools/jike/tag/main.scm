#| @meta
{
  "name": "jike/tag",
  "description": "获取 JIKE 标签页主题列表并返回结构化结果",
  "args": [
    {
      "name": "tag",
      "type": "string",
      "required": true,
      "description": "标签名"
    },
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
    "description": "{ tag, count, topics[] }"
  },
  "examples": [
    "openwalk exec jike/tag -- anyviewer",
    "openwalk exec jike/tag -- ChatGPT 10"
  ],
  "domains": [
    "jike.info"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "jike",
    "tag",
    "topics"
  ]
}
|#

(defun main (args)
  (open "https://jike.info")
  (js-file-call "main.js" args))

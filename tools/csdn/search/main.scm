#| @meta
{
  "name": "csdn/search",
  "description": "搜索 CSDN 技术文章并返回结构化结果",
  "args": [
    {
      "name": "query",
      "type": "string",
      "required": true,
      "description": "搜索关键词"
    },
    {
      "name": "page",
      "type": "number",
      "required": false,
      "default": 1,
      "description": "页码，默认 1"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, page, total, count, results[] }"
  },
  "examples": [
    "openwalk exec csdn/search -- \"Python\""
  ],
  "domains": [
    "so.csdn.net"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "csdn",
    "search",
    "articles"
  ]
}
|#

(defun main (args)
  (open "https://so.csdn.net")
  (js-run "main.js" args))

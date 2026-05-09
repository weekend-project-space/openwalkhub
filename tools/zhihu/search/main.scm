#| @meta
{
  "name": "zhihu/search",
  "description": "搜索知乎问题和回答并返回结构化结果",
  "args": [
    {
      "name": "keyword",
      "type": "string",
      "required": true,
      "description": "搜索关键词"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 10,
      "description": "返回结果数量，默认 10，最大 20"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ keyword, count, has_more, results[] }"
  },
  "examples": [
    "openwalk exec zhihu/search -- AI",
    "openwalk exec zhihu/search -- \"大模型\" 10"
  ],
  "domains": [
    "www.zhihu.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "zhihu",
    "search"
  ]
}
|#

(defun main (args)
  (open "https://www.zhihu.com")
  (js-file-call "main.js" args))

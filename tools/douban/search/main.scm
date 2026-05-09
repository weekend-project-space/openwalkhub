#| @meta
{
  "name": "douban/search",
  "description": "搜索豆瓣内容并返回结构化结果",
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
      "description": "返回条数，默认 10，最大 20"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ keyword, count, results[] }"
  },
  "examples": [
    "openwalk exec douban/search -- 三体",
    "openwalk exec douban/search -- \"机器学习\" 10"
  ],
  "domains": [
    "www.douban.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "douban",
    "search"
  ]
}
|#

(defun main (args)
  (open "https://www.douban.com")
  (js-run "main.js" args))

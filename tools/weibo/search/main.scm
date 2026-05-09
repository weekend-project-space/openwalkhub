#| @meta
{
  "name": "weibo/search",
  "description": "搜索微博内容并返回结构化结果",
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
    "description": "{ keyword, count, posts[] }"
  },
  "examples": [
    "openwalk exec weibo/search -- AI",
    "openwalk exec weibo/search -- \"大模型\" 10"
  ],
  "domains": [
    "s.weibo.com",
    "weibo.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "weibo",
    "search",
    "posts"
  ]
}
|#

(defun main (args)
  (open "https://s.weibo.com")
  (js-run "main.js" args))

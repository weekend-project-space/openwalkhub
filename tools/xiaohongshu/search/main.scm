#| @meta
{
  "name": "xiaohongshu/search",
  "description": "搜索小红书公开页面并返回结构化结果",
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
    "description": "{ keyword, count, notes[] }"
  },
  "examples": [
    "openwalk exec xiaohongshu/search -- 穿搭",
    "openwalk exec xiaohongshu/search -- AI 10"
  ],
  "domains": [
    "www.xiaohongshu.com",
    "xiaohongshu.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "xiaohongshu",
    "search",
    "notes"
  ]
}
|#

(defun main (args)
  (open "https://www.xiaohongshu.com")
  (js-run "main.js" args))

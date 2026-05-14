#| @meta
{
  "name": "xiaohongshu/search",
  "description": "搜索小红书站内笔记并返回结构化结果（需登录）",
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
    },
    {
      "name": "sort",
      "type": "string",
      "required": false,
      "default": "general",
      "description": "排序方式：general、latest、likes、comments、collects"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ keyword, sort, count, has_more, notes[] }"
  },
  "examples": [
    "openwalk exec xiaohongshu/search -- 穿搭",
    "openwalk exec xiaohongshu/search -- AI 10",
    "openwalk exec xiaohongshu/search -- AI 10 latest"
  ],
  "domains": [
    "www.xiaohongshu.com",
    "xiaohongshu.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
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

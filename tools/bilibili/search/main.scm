#| @meta
{
  "name": "bilibili/search",
  "description": "搜索 Bilibili 视频并返回结构化结果",
  "args": [
    {
      "name": "keyword",
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
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "每页结果数量，默认 20，最大 50"
    },
    {
      "name": "order",
      "type": "string",
      "required": false,
      "default": "totalrank",
      "description": "排序：totalrank、click、pubdate、dm、stow"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ keyword, page, total, count, videos[] }"
  },
  "examples": [
    "openwalk exec bilibili/search -- 编程"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "search",
    "videos"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-file-call "main.js" args))

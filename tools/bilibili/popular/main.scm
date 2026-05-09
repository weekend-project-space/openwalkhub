#| @meta
{
  "name": "bilibili/popular",
  "description": "获取 Bilibili 热门视频并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回视频数量，默认 20，最大 50"
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
    "description": "{ page, count, no_more, videos[] }"
  },
  "examples": [
    "openwalk exec bilibili/popular -- 10"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "popular",
    "videos"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-file-call "main.js" args))

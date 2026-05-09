#| @meta
{
  "name": "bilibili/ranking",
  "description": "获取 Bilibili 排行榜视频并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回视频数量，默认 20，最大 100"
    },
    {
      "name": "category",
      "type": "number",
      "required": false,
      "default": 0,
      "description": "分类 rid，默认 0=全站"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ category, count, videos[] }"
  },
  "examples": [
    "openwalk exec bilibili/ranking",
    "openwalk exec bilibili/ranking -- --category 36"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "ranking",
    "videos"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-run "main.js" args))

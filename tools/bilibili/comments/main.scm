#| @meta
{
  "name": "bilibili/comments",
  "description": "获取 Bilibili 视频评论并返回结构化结果",
  "args": [
    {
      "name": "bvid",
      "type": "string",
      "required": true,
      "description": "视频 BV ID"
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
      "description": "每页评论数量，默认 20，最大 30"
    },
    {
      "name": "sort",
      "type": "number",
      "required": false,
      "default": 2,
      "description": "排序：0=时间，2=热度"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ bvid, aid, title, page, total, count, top_comments, comments[] }"
  },
  "examples": [
    "openwalk exec bilibili/comments -- BV1LGwHzrE4A"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "comments",
    "video"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-run "main.js" args))

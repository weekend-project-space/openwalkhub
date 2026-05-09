#| @meta
{
  "name": "bilibili/video",
  "description": "获取 Bilibili 视频详情并返回结构化结果",
  "args": [
    {
      "name": "bvid",
      "type": "string",
      "required": true,
      "description": "视频 BV ID，例如 BV1LGwHzrE4A"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ bvid, aid, title, description, stat, pages[], related[] }"
  },
  "examples": [
    "openwalk exec bilibili/video -- BV1LGwHzrE4A"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "video",
    "details"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-run "main.js" args))

#| @meta
{
  "name": "youtube/feed",
  "description": "获取 YouTube 首页或订阅 feed 并返回结构化结果",
  "args": [
    {
      "name": "type",
      "type": "string",
      "required": false,
      "default": "home",
      "description": "feed 类型：home 或 subscriptions"
    },
    {
      "name": "max",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回视频数量，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ feed, source, videoCount, videos[] }"
  },
  "examples": [
    "openwalk exec youtube/feed",
    "openwalk exec youtube/feed -- subscriptions"
  ],
  "domains": [
    "www.youtube.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "youtube",
    "feed",
    "subscriptions"
  ]
}
|#

(defun main (args)
  (open "https://www.youtube.com")
  (js-file-call "main.js" args))

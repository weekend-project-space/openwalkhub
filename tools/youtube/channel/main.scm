#| @meta
{
  "name": "youtube/channel",
  "description": "获取 YouTube 频道信息和近期视频并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": false,
      "description": "频道 ID（UCxxxx）或 handle（@name），默认当前页面频道"
    },
    {
      "name": "max",
      "type": "number",
      "required": false,
      "default": 10,
      "description": "返回近期视频数量，默认 10，最大 30"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ channelId, name, handle, subscriberCount, tabs[], recentVideos[] }"
  },
  "examples": [
    "openwalk exec youtube/channel -- @programmingwithmosh"
  ],
  "domains": [
    "www.youtube.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "youtube",
    "channel",
    "videos"
  ]
}
|#

(defun main (args)
  (open "https://www.youtube.com")
  (js-run "main.js" args))

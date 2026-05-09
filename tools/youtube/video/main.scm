#| @meta
{
  "name": "youtube/video",
  "description": "获取 YouTube 视频详情并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": false,
      "description": "Video ID，默认当前页面视频"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ videoId, title, channel, channelId, viewCount, likes, publishDate, url }"
  },
  "examples": [
    "openwalk exec youtube/video -- d56mG7DezGs"
  ],
  "domains": [
    "www.youtube.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "youtube",
    "video",
    "details"
  ]
}
|#

(defun main (args)
  (open "https://www.youtube.com")
  (js-run "main.js" args))

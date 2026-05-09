#| @meta
{
  "name": "youtube/comments",
  "description": "获取 YouTube 视频评论并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": false,
      "description": "Video ID，默认当前页面视频"
    },
    {
      "name": "max",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回评论数量，默认 20，最大 100"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ videoId, commentCountText, fetchedCount, comments[] }"
  },
  "examples": [
    "openwalk exec youtube/comments -- d56mG7DezGs"
  ],
  "domains": [
    "www.youtube.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "youtube",
    "comments",
    "video"
  ]
}
|#

(defun main (args)
  (open "https://www.youtube.com")
  (js-file-call "main.js" args))

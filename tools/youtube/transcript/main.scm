#| @meta
{
  "name": "youtube/transcript",
  "description": "获取 YouTube 视频字幕并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": false,
      "description": "Video ID，默认当前页面视频"
    },
    {
      "name": "lang",
      "type": "string",
      "required": false,
      "description": "字幕语言代码，例如 en、ja"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ videoId, language, segmentCount, segments[], fullText }"
  },
  "examples": [
    "openwalk exec youtube/transcript",
    "openwalk exec youtube/transcript -- d56mG7DezGs --lang en"
  ],
  "domains": [
    "www.youtube.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "youtube",
    "transcript",
    "captions"
  ]
}
|#

(defun main (args)
  (open "https://www.youtube.com")
  (js-run "main.js" args))

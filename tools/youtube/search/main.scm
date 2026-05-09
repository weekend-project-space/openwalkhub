#| @meta
{
  "name": "youtube/search",
  "description": "搜索 YouTube 视频并返回结构化结果",
  "args": [
    {
      "name": "query",
      "type": "string",
      "required": true,
      "description": "搜索关键词"
    },
    {
      "name": "max",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回结果数量，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, resultCount, videos[] }"
  },
  "examples": [
    "openwalk exec youtube/search -- \"TypeScript tutorial\""
  ],
  "domains": [
    "www.youtube.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "youtube",
    "search",
    "videos"
  ]
}
|#

(defun main (args)
  (open "https://www.youtube.com")
  (js-file-call "main.js" args))

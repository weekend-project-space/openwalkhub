#| @meta
{
  "name": "xiaoyuzhoufm/podcast",
  "description": "获取小宇宙播客详情并返回结构化结果",
  "args": [
    {
      "name": "pid",
      "type": "string",
      "required": true,
      "description": "Podcast ID"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ pid, title, subscriptionCount, episodeCount, episodes[] }"
  },
  "examples": [
    "openwalk exec xiaoyuzhoufm/podcast -- 626b46ea9cbbf0451cf5a962"
  ],
  "domains": [
    "www.xiaoyuzhoufm.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "xiaoyuzhoufm",
    "podcast",
    "episodes"
  ]
}
|#

(defun main (args)
  (open "https://www.xiaoyuzhoufm.com")
  (js-run "main.js" args))

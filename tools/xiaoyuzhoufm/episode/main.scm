#| @meta
{
  "name": "xiaoyuzhoufm/episode",
  "description": "获取小宇宙单集详情并返回结构化结果",
  "args": [
    {
      "name": "eid",
      "type": "string",
      "required": true,
      "description": "Episode ID"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ eid, title, podcastTitle, playCount, commentCount, shownotes, links[] }"
  },
  "examples": [
    "openwalk exec xiaoyuzhoufm/episode -- 69ba2e32f8b8079bfaef73e5"
  ],
  "domains": [
    "www.xiaoyuzhoufm.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "xiaoyuzhoufm",
    "episode",
    "podcast"
  ]
}
|#

(defun main (args)
  (open "https://www.xiaoyuzhoufm.com")
  (js-run "main.js" args))

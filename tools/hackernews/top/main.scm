#| @meta
{
  "name": "hackernews/top",
  "description": "获取 Hacker News 热门帖子并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回帖子数量，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, posts[] }"
  },
  "examples": [
    "openwalk exec hackernews/top",
    "openwalk exec hackernews/top -- 10"
  ],
  "domains": [
    "news.ycombinator.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "hackernews",
    "top",
    "posts"
  ]
}
|#

(defun main (args)
  (open "https://news.ycombinator.com/")
  (js-wait "(() => document.querySelectorAll('tr.athing').length > 0)()")
  (js-file-call "main.js" args))

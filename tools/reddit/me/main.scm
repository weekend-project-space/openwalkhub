#| @meta
{
  "name": "reddit/me",
  "description": "获取当前 Reddit 登录用户信息并返回结构化结果",
  "args": [],
  "returns": {
    "type": "object",
    "description": "{ name, id, url, comment_karma, link_karma, total_karma, created_utc }"
  },
  "examples": [
    "openwalk exec reddit/me"
  ],
  "domains": [
    "www.reddit.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "reddit",
    "me",
    "profile"
  ]
}
|#

(defun main (args)
  (open "https://www.reddit.com")
  (js-file-call "main.js" args))

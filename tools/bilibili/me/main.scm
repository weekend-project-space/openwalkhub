#| @meta
{
  "name": "bilibili/me",
  "description": "获取当前 Bilibili 登录用户信息并返回结构化结果",
  "args": [],
  "returns": {
    "type": "object",
    "description": "{ mid, username, url, level, coins, vip, follower, following }"
  },
  "examples": [
    "openwalk exec bilibili/me"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "bilibili",
    "me",
    "profile"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-file-call "main.js" args))

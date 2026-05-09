#| @meta
{
  "name": "reddit/posts",
  "description": "获取 Reddit 用户发帖列表并返回结构化结果",
  "args": [
    {
      "name": "username",
      "type": "string",
      "required": false,
      "description": "Reddit 用户名，默认当前登录用户"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ username, total, posts[] }"
  },
  "examples": [
    "openwalk exec reddit/posts",
    "openwalk exec reddit/posts -- spez"
  ],
  "domains": [
    "www.reddit.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "reddit",
    "posts",
    "profile"
  ]
}
|#

(defun main (args)
  (open "https://www.reddit.com")
  (js-file-call "main.js" args))

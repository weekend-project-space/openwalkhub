#| @meta
{
  "name": "twitter/user",
  "description": "获取 Twitter 用户 profile 并返回结构化结果",
  "args": [
    {
      "name": "screen_name",
      "type": "string",
      "required": true,
      "description": "Twitter handle，不带 @"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ id, name, screen_name, bio, url, followers, following, tweets, verified }"
  },
  "examples": [
    "openwalk exec twitter/user -- yan5xu"
  ],
  "domains": [
    "x.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "twitter",
    "user",
    "profile"
  ]
}
|#

(defun main (args)
  (open "https://x.com")
  (js-run "main.js" args))

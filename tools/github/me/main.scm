#| @meta
{
  "name": "github/me",
  "description": "获取当前 GitHub 登录用户信息并返回结构化结果",
  "args": [],
  "returns": {
    "type": "object",
    "description": "{ login, name, bio, url, public_repos, followers, following }"
  },
  "examples": [
    "openwalk exec github/me"
  ],
  "domains": [
    "github.com",
    "api.github.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "github",
    "me",
    "profile"
  ]
}
|#

(defun main (args)
  (open "https://github.com")
  (js-file-call "main.js" args))

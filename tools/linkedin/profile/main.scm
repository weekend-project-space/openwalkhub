#| @meta
{
  "name": "linkedin/profile",
  "description": "获取 LinkedIn 用户 profile 并返回结构化结果",
  "args": [
    {
      "name": "username",
      "type": "string",
      "required": true,
      "description": "linkedin.com/in/<username> 中的用户名"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ firstName, lastName, headline, location, industry, profileUrl }"
  },
  "examples": [
    "openwalk exec linkedin/profile -- williamhgates"
  ],
  "domains": [
    "www.linkedin.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "linkedin",
    "profile",
    "people"
  ]
}
|#

(defun main (args)
  (open "https://www.linkedin.com")
  (js-run "main.js" args))

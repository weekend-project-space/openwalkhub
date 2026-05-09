#| @meta
{
  "name": "github/issue-create",
  "description": "创建 GitHub issue 并返回结构化结果",
  "args": [
    {
      "name": "repo",
      "type": "string",
      "required": true,
      "description": "owner/repo 格式"
    },
    {
      "name": "title",
      "type": "string",
      "required": true,
      "description": "Issue 标题"
    },
    {
      "name": "body",
      "type": "string",
      "required": false,
      "description": "Issue 正文，Markdown"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ number, title, url, state }"
  },
  "examples": [
    "openwalk exec github/issue-create -- epiral/bb-sites --title \"bug\" --body \"detail\""
  ],
  "domains": [
    "github.com",
    "api.github.com"
  ],
  "readOnly": false,
  "requiresLogin": true,
  "tags": [
    "github",
    "issue",
    "create"
  ]
}
|#

(defun main (args)
  (open "https://github.com")
  (js-file-call "main.js" args))

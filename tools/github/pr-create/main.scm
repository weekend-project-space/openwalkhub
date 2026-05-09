#| @meta
{
  "name": "github/pr-create",
  "description": "创建 GitHub Pull Request 并返回结构化结果",
  "args": [
    {
      "name": "repo",
      "type": "string",
      "required": true,
      "description": "目标仓库，owner/repo 格式"
    },
    {
      "name": "title",
      "type": "string",
      "required": true,
      "description": "PR 标题"
    },
    {
      "name": "head",
      "type": "string",
      "required": true,
      "description": "源分支，user:branch 或 branch"
    },
    {
      "name": "base",
      "type": "string",
      "required": false,
      "default": "main",
      "description": "目标分支，默认 main"
    },
    {
      "name": "body",
      "type": "string",
      "required": false,
      "description": "PR 描述，Markdown"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ number, title, url, state }"
  },
  "examples": [
    "openwalk exec github/pr-create -- epiral/bb-sites --title \"feat\" --head myuser:feat-branch"
  ],
  "domains": [
    "github.com",
    "api.github.com"
  ],
  "readOnly": false,
  "requiresLogin": true,
  "tags": [
    "github",
    "pull-request",
    "create"
  ]
}
|#

(defun main (args)
  (open "https://github.com")
  (js-file-call "main.js" args))

#| @meta
{
  "name": "github/issues",
  "description": "获取 GitHub 仓库 issue 列表并返回结构化结果",
  "args": [
    {
      "name": "repo",
      "type": "string",
      "required": true,
      "description": "owner/repo 格式"
    },
    {
      "name": "state",
      "type": "string",
      "required": false,
      "default": "open",
      "description": "open、closed 或 all"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ repo, state, count, issues[] }"
  },
  "examples": [
    "openwalk exec github/issues -- epiral/bb-browser",
    "openwalk exec github/issues -- epiral/bb-browser closed"
  ],
  "domains": [
    "github.com",
    "api.github.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "github",
    "issues",
    "repository"
  ]
}
|#

(defun main (args)
  (open "https://github.com")
  (js-run "main.js" args))

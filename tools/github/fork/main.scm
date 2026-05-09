#| @meta
{
  "name": "github/fork",
  "description": "Fork 一个 GitHub 仓库并返回结构化结果",
  "args": [
    {
      "name": "repo",
      "type": "string",
      "required": true,
      "description": "要 fork 的仓库，owner/repo 格式"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ full_name, url, clone_url }"
  },
  "examples": [
    "openwalk exec github/fork -- epiral/bb-sites"
  ],
  "domains": [
    "github.com",
    "api.github.com"
  ],
  "readOnly": false,
  "requiresLogin": true,
  "tags": [
    "github",
    "fork",
    "repository"
  ]
}
|#

(defun main (args)
  (open "https://github.com")
  (js-run "main.js" args))

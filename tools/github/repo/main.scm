#| @meta
{
  "name": "github/repo",
  "description": "获取 GitHub 仓库信息并返回结构化结果",
  "args": [
    {
      "name": "repo",
      "type": "string",
      "required": true,
      "description": "owner/repo 格式"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ full_name, description, language, stars, forks, topics[], license }"
  },
  "examples": [
    "openwalk exec github/repo -- weekend-project-space/openwalk"
  ],
  "domains": [
    "github.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "github",
    "repo",
    "repository"
  ]
}
|#

(defun main (args)
  (open "https://github.com")
  (js-file-call "main.js" args))

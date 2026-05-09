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
  (js-call args
    " const repo = args.repo || '';
      const title = args.title || '';
      if (!repo) {
        return {
          error: 'Missing argument: repo',
        };
      }
      if (!title) {
        return {
          error: 'Missing argument: title',
        };
      }

      const source = 'https://api.github.com/repos/' + repo + '/issues';
      const resp = await fetch(source, {
        method: 'POST',
        headers: {
          Accept: 'application/vnd.github+json',
          'Content-Type': 'application/json',
        },
        credentials: 'include',
        body: JSON.stringify({
          title,
          body: args.body || '',
        }),
      });

      if (!resp.ok) {
        const status = resp.status;
        if (status === 401 || status === 403) {
          return {
            error: 'HTTP ' + status,
            hint: 'Not logged in to GitHub',
            source,
          };
        }
        if (status === 404) {
          return {
            error: 'Repo not found: ' + repo,
            source,
          };
        }
        return {
          error: 'HTTP ' + status,
          source,
        };
      }

      const issue = await resp.json();
      return {
        source,
        number: issue.number || 0,
        title: issue.title || '',
        url: issue.html_url || '',
        state: issue.state || '',
      };
    "))

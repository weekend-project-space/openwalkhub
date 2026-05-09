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
  (js-call args
    " const repo = args.repo || '';
      if (!repo) {
        return {
          error: 'Missing argument: repo',
        };
      }

      const state = args.state || 'open';
      const source =
        'https://api.github.com/repos/' +
        repo +
        '/issues?state=' +
        encodeURIComponent(state) +
        '&per_page=30';

      const resp = await fetch(source, {
        headers: {Accept: 'application/vnd.github+json'},
        credentials: 'include',
      });
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          source,
        };
      }

      const issues = await resp.json();
      return {
        source,
        repo,
        state,
        count: issues.length,
        issues: issues.map((issue) => ({
          number: issue.number || 0,
          title: issue.title || '',
          state: issue.state || '',
          url: issue.html_url || '',
          author: issue.user?.login || '',
          labels: (issue.labels || []).map((label) => label.name || ''),
          comments: issue.comments || 0,
          created_at: issue.created_at || '',
          is_pr: !!issue.pull_request,
        })),
      };
    "))

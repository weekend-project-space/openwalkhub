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
  (js-call args
    " const source = 'https://api.github.com/user';
      const resp = await fetch(source, {credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: resp.status === 401 ? 'Not logged into github.com' : 'API error',
          source,
        };
      }

      const data = await resp.json();
      return {
        source,
        login: data.login || '',
        name: data.name || '',
        bio: data.bio || '',
        url: data.html_url || (data.login ? 'https://github.com/' + data.login : ''),
        public_repos: data.public_repos || 0,
        followers: data.followers || 0,
        following: data.following || 0,
        created_at: data.created_at || '',
      };
    "))

#| @meta
{
  "name": "reddit/me",
  "description": "获取当前 Reddit 登录用户信息并返回结构化结果",
  "args": [],
  "returns": {
    "type": "object",
    "description": "{ name, id, url, comment_karma, link_karma, total_karma, created_utc }"
  },
  "examples": [
    "openwalk exec reddit/me"
  ],
  "domains": [
    "www.reddit.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "reddit",
    "me",
    "profile"
  ]
}
|#

(defun main (args)
  (open "https://www.reddit.com")
  (js-call args
    " const html = document.documentElement.outerHTML;
      const idMatch =
        html.match(/current-user-id=\\\"(t2_[a-z0-9]+)\\\"/) ||
        html.match(/user-id=\\\"(t2_[a-z0-9]+)\\\"/);

      if (!idMatch) {
        return {
          error: 'Not logged in',
          hint: 'Open reddit.com and log in.',
        };
      }

      const userId = idMatch[1];
      const idSource =
        'https://www.reddit.com/api/user_data_by_account_ids.json?ids=' +
        encodeURIComponent(userId);
      const idResp = await fetch(idSource, {credentials: 'include'});
      if (!idResp.ok) {
        return {
          error: 'HTTP ' + idResp.status,
          hint: 'Open reddit.com and log in.',
          source: idSource,
        };
      }

      const idData = await idResp.json();
      const username = idData?.[userId]?.name || '';
      if (!username) {
        return {
          error: 'Cannot resolve username for ' + userId,
          hint: 'Open reddit.com and log in.',
          source: idSource,
        };
      }

      const profileSource =
        'https://www.reddit.com/user/' +
        encodeURIComponent(username) +
        '/about.json';
      const resp = await fetch(profileSource, {credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: 'Profile fetch failed',
          source: profileSource,
        };
      }

      const data = await resp.json();
      if (!data?.data?.name) {
        return {
          error: 'Unexpected response',
          hint: 'Open reddit.com and log in.',
          source: profileSource,
        };
      }

      return {
        source: profileSource,
        name: data.data.name || '',
        id: data.data.id || '',
        url: data.data.name
          ? `https://www.reddit.com/user/${data.data.name}`
          : '',
        comment_karma: data.data.comment_karma || 0,
        link_karma: data.data.link_karma || 0,
        total_karma: data.data.total_karma || 0,
        created_utc: data.data.created_utc || 0,
      };
    "))

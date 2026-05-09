#| @meta
{
  "name": "reddit/posts",
  "description": "获取 Reddit 用户发帖列表并返回结构化结果",
  "args": [
    {
      "name": "username",
      "type": "string",
      "required": false,
      "description": "Reddit 用户名，默认当前登录用户"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ username, total, posts[] }"
  },
  "examples": [
    "openwalk exec reddit/posts",
    "openwalk exec reddit/posts -- spez"
  ],
  "domains": [
    "www.reddit.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "reddit",
    "posts",
    "profile"
  ]
}
|#

(defun main (args)
  (open "https://www.reddit.com")
  (js-call args
    " let username = args.username || '';
      if (!username) {
        const idMatch = document.cookie.match(/t2_([a-z0-9]+)_/);
        if (!idMatch) {
          return {
            error: 'Cannot determine username',
            hint: 'Provide username or log in to reddit.com',
          };
        }

        const userId = 't2_' + idMatch[1];
        const idSource =
          'https://www.reddit.com/api/user_data_by_account_ids.json?ids=' +
          encodeURIComponent(userId);
        const idResp = await fetch(idSource, {credentials: 'include'});
        if (idResp.ok) {
          const idData = await idResp.json();
          username = idData?.[userId]?.name || '';
        }

        if (!username) {
          return {
            error: 'Cannot determine username',
            hint: 'Provide username or log in to reddit.com',
          };
        }
      }

      let after = null;
      let allPosts = [];
      let page = 0;

      do {
        const source =
          'https://www.reddit.com/user/' +
          encodeURIComponent(username) +
          '/submitted/.json?limit=100&raw_json=1' +
          (after ? '&after=' + encodeURIComponent(after) : '');
        const resp = await fetch(source, {credentials: 'include'});
        if (!resp.ok) {
          return {
            error: 'HTTP ' + resp.status,
            hint: resp.status === 404
              ? 'User not found: ' + username
              : 'API error',
            source,
          };
        }

        const data = await resp.json();
        if (!data?.data?.children) {
          return {
            error: 'Unexpected response',
            hint: 'Reddit may be rate-limiting or returning a login page',
            source,
          };
        }

        const posts = data.data.children.map((child) => {
          const post = child.data || {};
          return {
            id: post.name || '',
            title: post.title || '',
            subreddit: post.subreddit_name_prefixed || '',
            score: post.score || 0,
            num_comments: post.num_comments || 0,
            created_utc: post.created_utc || 0,
            permalink: post.permalink
              ? `https://www.reddit.com${post.permalink}`
              : '',
            selftext_preview: (post.selftext || '').substring(0, 200),
          };
        });

        allPosts = allPosts.concat(posts);
        after = data.data.after || null;
        page += 1;

        if (after) {
          await new Promise((resolve) => setTimeout(resolve, 500));
        }
      } while (after && page < 20);

      return {
        username,
        total: allPosts.length,
        posts: allPosts,
      };
    "))

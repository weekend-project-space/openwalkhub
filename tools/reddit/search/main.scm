#| @meta
{
  "name": "reddit/search",
  "description": "搜索 Reddit 帖子并返回结构化结果",
  "args": [
    {
      "name": "query",
      "type": "string",
      "required": true,
      "description": "搜索关键词"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 25,
      "description": "返回帖子数量，默认 25，最大 100"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, count, posts[] }"
  },
  "examples": [
    "openwalk exec reddit/search -- \"claude code\"",
    "openwalk exec reddit/search -- AI 20"
  ],
  "domains": [
    "www.reddit.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "reddit",
    "search"
  ]
}
|#

(defun main (args)
  (open "https://www.reddit.com")
  (js-call args
    " const query = args.query;
      const source =
        'https://www.reddit.com/search.json?q=' +
        encodeURIComponent(query) +
        '&sort=relevance&t=all&limit=' +
        args.count +
        '&raw_json=1';

      try {
        const resp = await fetch(source);
        if (!resp.ok) {
          return {
            error: 'HTTP ' + resp.status,
            hint: 'Open https://www.reddit.com first, ensure you can access the JSON endpoint, then retry.',
            source,
          };
        }

        const data = await resp.json();
        const posts = (data.data?.children || []).map((child, index) => {
          const post = child.data || {};
          return {
            rank: index + 1,
            id: post.name || '',
            title: post.title || '',
            author: post.author || '',
            subreddit: post.subreddit_name_prefixed || '',
            score: post.score || 0,
            num_comments: post.num_comments || 0,
            created_utc: post.created_utc || 0,
            url: post.url || '',
            permalink: post.permalink
              ? `https://www.reddit.com${post.permalink}`
              : '',
            selftext_preview: (post.selftext || '').slice(0, 200),
            is_self: !!post.is_self,
            link_flair_text: post.link_flair_text || null,
          };
        });

        return {
          query,
          count: posts.length,
          posts,
        };
      } catch (error) {
        return {
          error: 'Unexpected response',
          hint: 'Open https://www.reddit.com first, ensure you can access the JSON endpoint, then retry.',
          detail: String(error),
          source,
        };
      }
    "))

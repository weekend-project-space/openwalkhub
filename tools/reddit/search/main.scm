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
      "name": "subreddit",
      "type": "string",
      "required": false,
      "description": "限定 subreddit，不带 r/ 前缀"
    },
    {
      "name": "sort",
      "type": "string",
      "required": false,
      "default": "relevance",
      "description": "排序：relevance、hot、top、new、comments"
    },
    {
      "name": "time",
      "type": "string",
      "required": false,
      "default": "all",
      "description": "时间范围：all、hour、day、week、month、year"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 25,
      "description": "返回帖子数量，默认 25，最大 100"
    },
    {
      "name": "after",
      "type": "string",
      "required": false,
      "description": "分页用的 fullname 游标"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, subreddit, sort, time, count, after, posts[] }"
  },
  "examples": [
    "openwalk exec reddit/search -- \"claude code\"",
    "openwalk exec reddit/search -- AI 20",
    "openwalk exec reddit/search -- \"claude code\" --sort top --time week"
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
      const subreddit = args.subreddit || '';
      const sort = args.sort || 'relevance';
      const time = args.time || 'all';
      const count = Math.min(Number(args.count) || 25, 100);
      const source = subreddit
        ? 'https://www.reddit.com/r/' +
          encodeURIComponent(subreddit) +
          '/search.json?restrict_sr=on&q=' +
          encodeURIComponent(query)
        : 'https://www.reddit.com/search.json?q=' +
          encodeURIComponent(query);
      const url =
        source +
        '&sort=' +
        encodeURIComponent(sort) +
        '&t=' +
        encodeURIComponent(time) +
        '&limit=' +
        count +
        '&raw_json=1' +
        (args.after ? '&after=' + encodeURIComponent(args.after) : '');

      try {
        const resp = await fetch(url, {credentials: 'include'});
        if (!resp.ok) {
          return {
            error: 'HTTP ' + resp.status,
            hint: resp.status === 404
              ? 'Subreddit not found'
              : 'Open https://www.reddit.com first, ensure you can access the JSON endpoint, then retry.',
            source: url,
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
          subreddit: subreddit || null,
          sort,
          time,
          count: posts.length,
          after: data.data?.after || null,
          posts,
        };
      } catch (error) {
        return {
          error: 'Unexpected response',
          hint: 'Open https://www.reddit.com first, ensure you can access the JSON endpoint, then retry.',
          detail: String(error),
          source: url,
        };
      }
    "))

#| @meta
{
  "name": "reddit/hot",
  "description": "获取 Reddit 热门帖子并返回结构化结果",
  "args": [
    {
      "name": "subreddit",
      "type": "string",
      "required": false,
      "description": "可选的 subreddit 名称，不带 r/ 前缀"
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
    "description": "{ subreddit, count, posts[] }"
  },
  "examples": [
    "openwalk exec reddit/hot",
    "openwalk exec reddit/hot -- LocalLLaMA 20"
  ],
  "domains": [
    "www.reddit.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "reddit",
    "hot",
    "posts"
  ]
}
|#

(define (main args)
  (define arg1 (if (null? args) #f (car args)))
  (define arg2 (if (or (null? args) (null? (cdr args))) #f (cadr args)))
  (define subreddit
    (if (and arg1 (not (string->number arg1)))
        arg1
        #f))
  (define count-text
    (cond
      ((and arg1 (string->number arg1)) arg1)
      (arg2 arg2)
      (else "25")))
  (define source
    (if subreddit
        (string-append
          "https://www.reddit.com/r/"
          subreddit
          "/hot.json?limit="
          count-text
          "&raw_json=1")
        (string-append
          "https://www.reddit.com/hot.json?limit="
          count-text
          "&raw_json=1")))
  (open source)
  (js-wait
    "(() => {
      const raw = (
        document.body?.innerText ||
        document.documentElement?.innerText ||
        ''
      ).trim();
      return raw.length > 0;
    })()")
  (js-eval
    (string-append
      "(() => {
        const raw = (
          document.body?.innerText ||
          document.documentElement?.innerText ||
          ''
        ).trim();

        try {
          const data = JSON.parse(raw);
          const posts = (data.data?.children || []).map((child, index) => {
            const post = child.data || {};
            return {
              rank: index + 1,
              id: post.name || '',
              title: post.title || '',
              author: post.author || '',
              subreddit: post.subreddit_name_prefixed || '',
              score: post.score || 0,
              upvote_ratio: post.upvote_ratio || 0,
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
            subreddit: '"
      (if subreddit subreddit "front page")
      "',
            count: posts.length,
            posts,
          };
        } catch (error) {
          return {
            error: 'Unexpected response',
            hint: 'Open https://www.reddit.com first, ensure you can access the JSON endpoint, then retry.',
            preview: raw.slice(0, 200),
          };
        }
      })()")))

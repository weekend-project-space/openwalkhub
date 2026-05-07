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

(defun %normalized-args (args)
  (let ((arg1 (if (null? args) #f (car args)))
        (arg2 (if (or (null? args) (null? (cdr args))) #f (cadr args))))
    (cond
      ((null? args) '())
      ((and arg1 (string->number arg1))
       (if arg2
           (list "--count" arg1 "--subreddit" arg2)
           (list "--count" arg1)))
      (arg2
       (list "--subreddit" arg1 "--count" arg2))
      (else
       (list "--subreddit" arg1)))))

(defun main (args)
  (let* ((normalized-args (%normalized-args args))
         (params (parse-args normalized-args))
         (subreddit (alist-get params "subreddit"))
         (count-text (number->string (alist-get params "count")))
         (source
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
                 "&raw_json=1"))))
    (open "https://www.reddit.com")
    (js-eval
      (string-append
        "(async () => {
          const source = '"
        source
        "';

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
              detail: String(error),
              source,
            };
          }
        })()"))))

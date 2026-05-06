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

(define (encode-char ch)
  (cond
    ((char=? ch #\space) "%20")
    ((char=? ch #\") "%22")
    ((char=? ch #\#) "%23")
    ((char=? ch #\%) "%25")
    ((char=? ch #\&) "%26")
    ((char=? ch #\+) "%2B")
    ((char=? ch #\/) "%2F")
    ((char=? ch #\?) "%3F")
    ((char=? ch #\=) "%3D")
    (else (string ch))))

(define (url-encode-lite value)
  (let loop ((chars (string->list value)) (parts '()))
    (if (null? chars)
        (apply string-append (reverse parts))
        (loop (cdr chars) (cons (encode-char (car chars)) parts)))))

(define (main args)
  (if (null? args)
      (list
        (cons "error" "Missing argument: query")
        (cons "hint" "Provide a search query"))
      (let ((query (car args))
            (count-text
              (if (or (null? args) (null? (cdr args)))
                  "25"
                  (cadr args))))
        (open
          (string-append
            "https://www.reddit.com/search.json?q="
            (url-encode-lite query)
            "&sort=relevance&t=all&limit="
            count-text
            "&raw_json=1"))
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
                query: new URL(location.href).searchParams.get('q') || '',
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
          })()"))))

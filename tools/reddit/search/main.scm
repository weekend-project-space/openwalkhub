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

(defun %encode-char (ch)
  (cond
    ((= (char->integer ch) 32) "%20")
    ((= (char->integer ch) 34) "%22")
    ((= (char->integer ch) 39) "%27")
    ((= (char->integer ch) 35) "%23")
    ((= (char->integer ch) 37) "%25")
    ((= (char->integer ch) 38) "%26")
    ((= (char->integer ch) 43) "%2B")
    ((= (char->integer ch) 92) "%5C")
    ((= (char->integer ch) 47) "%2F")
    ((= (char->integer ch) 63) "%3F")
    ((= (char->integer ch) 61) "%3D")
    ((= (char->integer ch) 10) "%0A")
    ((= (char->integer ch) 13) "%0D")
    ((= (char->integer ch) 9) "%09")
    (else (string ch))))

(defun %url-encode-lite (value)
  (let loop ((chars (string->list value)) (parts '()))
    (if (null? chars)
        (apply string-append (reverse parts))
        (loop (cdr chars) (cons (%encode-char (car chars)) parts)))))

(defun main (args)
  (let* ((params (parse-args args))
         (query (alist-get params "query"))
         (count-value (alist-get params "count")))
    (let ((source
            (string-append
              "https://www.reddit.com/search.json?q="
              (%url-encode-lite query)
              "&sort=relevance&t=all&limit="
              (number->string count-value)
              "&raw_json=1")))
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
                query: new URL(source).searchParams.get('q') || '',
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
          })()")))))

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
    ((char=? ch #\space) "%20")
    ((char=? ch #\") "%22")
    ((char=? ch #\') "%27")
    ((char=? ch #\#) "%23")
    ((char=? ch #\%) "%25")
    ((char=? ch #\&) "%26")
    ((char=? ch #\+) "%2B")
    ((char=? ch #\\) "%5C")
    ((char=? ch #\/) "%2F")
    ((char=? ch #\?) "%3F")
    ((char=? ch #\=) "%3D")
    ((char=? ch #\newline) "%0A")
    ((char=? ch #\return) "%0D")
    ((char=? ch #\tab) "%09")
    (else (string ch))))

(defun %url-encode-lite (value)
  (let loop ((chars (string->list value)) (parts '()))
    (if (null? chars)
        (apply string-append (reverse parts))
        (loop (cdr chars) (cons (%encode-char (car chars)) parts)))))

(defun main (args)
  (if (null? args)
      (list
        (cons "error" "Missing argument: query")
        (cons "hint" "Provide a search query"))
      (let ((query (car args))
            (raw-count
              (if (or (null? args) (null? (cdr args)))
                  #f
                  (string->number (cadr args)))))
        (define count-text
          (number->string
            (cond
              ((not raw-count) 25)
              ((< raw-count 1) 1)
              ((> raw-count 100) 100)
              (else (inexact->exact (floor raw-count))))))
        (define source
          (string-append
            "https://www.reddit.com/search.json?q="
            (%url-encode-lite query)
            "&sort=relevance&t=all&limit="
            count-text
            "&raw_json=1"))
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

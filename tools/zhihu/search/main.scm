#| @meta
{
  "name": "zhihu/search",
  "description": "搜索知乎问题和回答并返回结构化结果",
  "args": [
    {
      "name": "keyword",
      "type": "string",
      "required": true,
      "description": "搜索关键词"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 10,
      "description": "返回结果数量，默认 10，最大 20"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ keyword, count, has_more, results[] }"
  },
  "examples": [
    "openwalk exec zhihu/search -- AI",
    "openwalk exec zhihu/search -- \"大模型\" 10"
  ],
  "domains": [
    "www.zhihu.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "zhihu",
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
        (cons "error" "Missing argument: keyword")
        (cons "hint" "Provide a search keyword"))
      (let ((keyword (car args))
            (raw-count
              (if (or (null? args) (null? (cdr args)))
                  #f
                  (string->number (cadr args)))))
        (define count-text
          (number->string
            (cond
              ((not raw-count) 10)
              ((< raw-count 1) 1)
              ((> raw-count 20) 20)
              (else (inexact->exact (floor raw-count))))))
        (define source
          (string-append
            "https://www.zhihu.com/api/v4/search_v3?q="
            (url-encode-lite keyword)
            "&t=general&offset=0&limit="
            count-text))
        (open
          source)
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
            const source = '"
            source
            "';
            try {
              const xhr = new XMLHttpRequest();
              xhr.open('GET', source, false);
              xhr.setRequestHeader('accept', 'application/json, text/plain, */*');
              xhr.send(null);

              if (xhr.status < 200 || xhr.status >= 300) {
                return {
                  error: `HTTP ${xhr.status}`,
                  hint: xhr.status === 401 || xhr.status === 403
                    ? 'Open https://www.zhihu.com first, ensure you are logged in if needed, then retry.'
                    : 'Search request failed.',
                };
              }

              const data = JSON.parse(xhr.responseText || '{}');
              const strip = (html) => (
                html || ''
              )
                .replace(/<[^>]+>/g, '')
                .replace(/&nbsp;/g, ' ')
                .replace(/&lt;/g, '<')
                .replace(/&gt;/g, '>')
                .replace(/&amp;/g, '&')
                .trim();

              const results = (data.data || [])
                .filter((item) => item.type === 'search_result')
                .map((item, index) => {
                  const object = item.object || {};
                  const question = object.question || {};

                  return {
                    rank: index + 1,
                    type: object.type || '',
                    id: object.id || '',
                    title: strip(object.title || question.name || ''),
                    excerpt: strip(object.excerpt || ''),
                    url: object.type === 'answer'
                      ? `https://www.zhihu.com/question/${question.id}/answer/${object.id}`
                      : object.type === 'article'
                        ? `https://zhuanlan.zhihu.com/p/${object.id}`
                        : `https://www.zhihu.com/question/${object.id}`,
                    author: object.author?.name || '',
                    voteup_count: object.voteup_count || 0,
                    comment_count: object.comment_count || 0,
                    question_id: question.id || null,
                    question_title: strip(question.name || ''),
                    created_time: object.created_time || 0,
                    updated_time: object.updated_time || 0,
                  };
                });

              return {
                keyword: new URL(source).searchParams.get('q') || '',
                count: results.length,
                has_more: !data.paging?.is_end,
                results,
              };
            } catch (error) {
              return {
                error: 'Unexpected response',
                hint: 'Open https://www.zhihu.com first, ensure you can access the API, then retry.',
                detail: String(error),
              };
            }
          })()")))))

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
         (keyword (alist-get params "keyword"))
         (count-value (alist-get params "count")))
    (let ((source
            (string-append
              "https://www.zhihu.com/api/v4/search_v3?q="
              (%url-encode-lite keyword)
              "&t=general&offset=0&limit="
              (number->string count-value))))
      (open "https://www.zhihu.com")
      (js-eval
        (string-append
          "(async () => {
          const source = '"
          source
          "';
          try {
            const resp = await fetch(source, {
              headers: {
                accept: 'application/json, text/plain, */*',
              },
            });

            if (!resp.ok) {
              return {
                error: `HTTP ${resp.status}`,
                hint: resp.status === 401 || resp.status === 403
                  ? 'Open https://www.zhihu.com first, ensure you are logged in if needed, then retry.'
                  : 'Search request failed.',
                source,
              };
            }

            const data = await resp.json();
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
              source,
            };
          }
        })()")))))

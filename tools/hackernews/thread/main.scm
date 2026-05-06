#| @meta
{
  "name": "hackernews/thread",
  "description": "获取 Hacker News 帖子详情和评论列表并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": true,
      "description": "Hacker News item ID"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ post, comments[] }"
  },
  "examples": [
    "openwalk exec hackernews/thread -- 12345678"
  ],
  "domains": [
    "news.ycombinator.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "hackernews",
    "thread",
    "comments"
  ]
}
|#

(define (main args)
  (if (null? args)
      (list
        (cons "error" "Missing argument: id")
        (cons "hint" "Provide a Hacker News item ID"))
      (let ((item-id (car args)))
        (open
          (string-append "https://news.ycombinator.com/item?id=" item-id))
        (js-wait
          "(() => {
            return !!document.querySelector('.fatitem, .athing.comtr');
          })()")
        (js-eval
          "(() => {
            const textOf = (node) => (node?.textContent || '').replace(/\\s+/g, ' ').trim();
            const htmlOf = (node) => node?.innerHTML || '';

            const titleLink = document.querySelector('.fatitem .titleline > a');
            const subtext = document.querySelector('.fatitem .subtext');
            const scoreEl = subtext?.querySelector('.score');
            const authorEl = subtext?.querySelector('.hnuser');
            const commentLink = Array.from(subtext?.querySelectorAll('a') || [])
              .find((link) => /comment|discuss/i.test((link.textContent || '').trim()));
            const commentCountText = (commentLink?.textContent || '0').trim();
            const commentCount = commentCountText === 'discuss'
              ? 0
              : Number.parseInt(commentCountText, 10) || 0;
            const mainTextNode = document.querySelector('.fatitem .toptext .commtext, .fatitem .commtext');

            const comments = Array.from(document.querySelectorAll('tr.athing.comtr')).map((row) => {
              const indent = Number.parseInt(
                row.querySelector('td.ind img')?.getAttribute('width') || '0',
                10
              ) || 0;
              const depth = Math.floor(indent / 40);
              const commentNode = row.querySelector('.commtext');
              const authorNode = row.querySelector('.hnuser');
              const ageLink = row.querySelector('.age a');

              return {
                id: row.getAttribute('id') || '',
                author: textOf(authorNode),
                depth,
                age: textOf(ageLink),
                url: ageLink?.href || '',
                text: textOf(commentNode),
                html: htmlOf(commentNode),
              };
            });

            return {
              post: {
                id: new URL(location.href).searchParams.get('id') || '',
                title: textOf(titleLink),
                url: titleLink?.href || '',
                hn_url: location.href,
                author: textOf(authorEl),
                score: Number.parseInt(scoreEl?.textContent || '0', 10) || 0,
                comments_count: commentCount,
                text: textOf(mainTextNode),
                html: htmlOf(mainTextNode),
              },
              comments,
            };
          })()"))))

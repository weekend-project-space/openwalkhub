#| @meta
{
  "name": "v2ex/topic",
  "description": "获取 V2EX 主题详情和回复并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": true,
      "description": "V2EX topic ID"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ id, title, content, node, nodeSlug, author, replies, created, url, comments[] }"
  },
  "examples": [
    "openwalk exec v2ex/topic -- 1024"
  ],
  "domains": [
    "www.v2ex.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "v2ex",
    "topic",
    "replies"
  ]
}
|#

(define (main args)
  (if (null? args)
      (list
        (cons "error" "Missing argument: id")
        (cons "hint" "Provide a topic ID"))
      (let ((topic-id (car args)))
        (browser-open
          (string-append "https://www.v2ex.com/api/topics/show.json?id=" topic-id))
        (js-wait
          "(() => {
            const raw = (
              document.body?.innerText ||
              document.documentElement?.innerText ||
              ''
            ).trim();
            return raw.startsWith('[');
          })()")
        (js-eval
          "(() => {
            const raw = (
              document.body?.innerText ||
              document.documentElement?.innerText ||
              '[]'
            ).trim();
            const topics = JSON.parse(raw);
            const topic = topics[0] || null;
            localStorage.setItem(
              'openwalk-v2ex-topic',
              JSON.stringify(topic)
            );
            return topic;
          })()")
        (page-goto
          (string-append "https://www.v2ex.com/api/replies/show.json?topic_id=" topic-id))
        (js-wait
          "(() => {
            const raw = (
              document.body?.innerText ||
              document.documentElement?.innerText ||
              ''
            ).trim();
            return raw.startsWith('[');
          })()")
        (js-eval
          "(() => {
            const topic = JSON.parse(
              localStorage.getItem('openwalk-v2ex-topic') || 'null'
            );
            const raw = (
              document.body?.innerText ||
              document.documentElement?.innerText ||
              '[]'
            ).trim();
            const replies = JSON.parse(raw);

            if (!topic) {
              return {
                error: 'Topic not found',
              };
            }

            return {
              id: topic.id,
              title: topic.title || '',
              content: topic.content || '',
              node: topic.node?.title || '',
              nodeSlug: topic.node?.name || '',
              author: topic.member?.username || '',
              replies: topic.replies || 0,
              created: topic.created || 0,
              url: topic.url || '',
              comments: replies.map((reply, index) => ({
                author: reply.member?.username || '',
                content: reply.content || '',
                created: reply.created || 0,
              })),
            };
          })()"))))

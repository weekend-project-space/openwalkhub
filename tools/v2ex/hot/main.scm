#| @meta
{
  "name": "v2ex/hot",
  "description": "获取 V2EX 热门主题并返回结构化结果",
  "args": [],
  "returns": {
    "type": "object",
    "description": "{ source, count, topics[] }"
  },
  "examples": [
    "openwalk exec v2ex/hot"
  ],
  "domains": [
    "www.v2ex.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "v2ex",
    "hot",
    "topics"
  ]
}
|#

(define (main args)
  (open "https://www.v2ex.com/api/topics/hot.json")
  (js-wait
    "(() => {
      const raw = (
        document.body?.innerText ||
        document.documentElement?.innerText ||
        ''
      ).trim();
      return raw.includes('\"title\"');
    })()")
  (js-eval
    "(() => {
      const source = 'https://www.v2ex.com/api/topics/hot.json';
      const raw = (
        document.body?.innerText ||
        document.documentElement?.innerText ||
        '[]'
      ).trim();
      const topics = JSON.parse(raw);

      return {
        source,
        count: topics.length,
        topics: topics.map((topic, index) => ({
          index: index + 1,
          id: topic.id,
          title: topic.title || '',
          content: (topic.content || '').slice(0, 300),
          node: topic.node?.title || '',
          nodeSlug: topic.node?.name || '',
          author: topic.member?.username || '',
          replies: topic.replies || 0,
          created: topic.created || 0,
          url: topic.url || '',
        })),
      };
    })()"))

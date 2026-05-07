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

(defun main (args)
  (open "https://www.v2ex.com")
  (js-call ()
    " const source = 'https://www.v2ex.com/api/topics/hot.json';
      const resp = await fetch(source);
      if (!resp.ok) return {error: 'HTTP ' + resp.status};
      const topics = await resp.json();

      return {
        source,
        count: topics.length,
        topics: topics.map((t, index) => ({
          index: index + 1,
          id: t.id,
          title: t.title || '',
          content: (t.content || '').slice(0, 300),
          node: t.node?.title || '',
          author: t.member?.username || '',
          replies: t.replies || 0,
          created: t.created || 0,
          url: t.url || '',
        })),
      };
    "))

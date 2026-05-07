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
    "description": "{ topic_source, replies_source, id, title, content, node, author, replies, created, url, comment_count, comments[] }"
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

(defun main (args)
  (open "https://www.v2ex.com")
  (js-call args
      " const topicId = args.id;
        const topicSource =
          'https://www.v2ex.com/api/topics/show.json?id=' +
          encodeURIComponent(topicId);
        const repliesSource =
          'https://www.v2ex.com/api/replies/show.json?topic_id=' +
          encodeURIComponent(topicId);
        const sourceInfo = {
          topic_source: topicSource,
          replies_source: repliesSource,
        };
        const httpError = (status, source) => ({
          ...sourceInfo,
          error: 'HTTP ' + status,
          source,
        });

        const [topicResp, repliesResp] = await Promise.all([
          fetch(topicSource),
          fetch(repliesSource),
        ]);

        if (!topicResp.ok) {
          return httpError(topicResp.status, topicSource);
        }

        if (!repliesResp.ok) {
          return httpError(repliesResp.status, repliesSource);
        }

        const [topics, replies] = await Promise.all([
          topicResp.json(),
          repliesResp.json(),
        ]);
        const topic = topics[0] || null;

        if (!topic) {
          return {
            ...sourceInfo,
            error: 'Topic not found',
            id: topicId,
          };
        }

        return {
          ...sourceInfo,
          id: topic.id,
          title: topic.title || '',
          content: topic.content || '',
          node: topic.node?.title || '',
          author: topic.member?.username || '',
          replies: topic.replies || 0,
          created: topic.created || 0,
          url: topic.url || '',
          comment_count: replies.length,
          comments: replies.map((reply, index) => ({
            index: index + 1,
            id: reply.id,
            author: reply.member?.username || '',
            content: reply.content || '',
            created: reply.created || 0,
          })),
        };
      "))

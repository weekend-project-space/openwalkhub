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

(defun main (args)
  (if (null? args)
      (list
        (cons "error" "Missing argument: id")
        (cons "hint" "Provide a topic ID"))
      (let ((topic-id (car args)))
        (if (not (string->number topic-id))
            (list
              (cons "error" "Invalid argument: id")
              (cons "hint" "Provide a numeric topic ID"))
            (begin
              (open "https://www.v2ex.com")
              (js-eval
                (string-append
                  "(async () => {
                    const topicId = '"
                  topic-id
                  "';
                    const topicSource =
                      'https://www.v2ex.com/api/topics/show.json?id=' +
                      encodeURIComponent(topicId);
                    const repliesSource =
                      'https://www.v2ex.com/api/replies/show.json?topic_id=' +
                      encodeURIComponent(topicId);

                    const [topicResp, repliesResp] = await Promise.all([
                      fetch(topicSource),
                      fetch(repliesSource),
                    ]);

                    if (!topicResp.ok) {
                      return {
                        error: 'HTTP ' + topicResp.status,
                        source: topicSource,
                      };
                    }

                    if (!repliesResp.ok) {
                      return {
                        error: 'HTTP ' + repliesResp.status,
                        source: repliesSource,
                      };
                    }

                    const topics = await topicResp.json();
                    const replies = await repliesResp.json();
                    const topic = topics[0] || null;

                    if (!topic) {
                      return {
                        error: 'Topic not found',
                        id: topicId,
                      };
                    }

                    return {
                      id: topic.id,
                      title: topic.title || '',
                      content: topic.content || '',
                      node: topic.node?.title || '',
                      author: topic.member?.username || '',
                      replies: topic.replies || 0,
                      created: topic.created || 0,
                      url: topic.url || '',
                      comments: replies.map((reply, index) => ({
                        index: index + 1,
                        id: reply.id,
                        author: reply.member?.username || '',
                        content: reply.content || '',
                        created: reply.created || 0,
                      })),
                    };
                  })()"))))))

async (args) => {
  const topicId = args.id;
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
}

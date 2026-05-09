async (args) => {
  const source = 'https://www.v2ex.com/api/topics/hot.json';
  const resp = await fetch(source);

  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      source,
    };
  }

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
}

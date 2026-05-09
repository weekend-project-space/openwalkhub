async (args) => {
  const source = 'https://www.v2ex.com/api/topics/latest.json';
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
    topics: topics.map((t) => ({
      id: t.id,
      title: t.title || '',
      node: t.node?.title || '',
      author: t.member?.username || '',
      replies: t.replies || 0,
    })),
  };
}

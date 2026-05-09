async (args) => {
  const tag = args.tag || '';
  if (!tag) {
    return {
      error: 'Missing argument: tag',
    };
  }

  const count = Math.min(Math.max(parseInt(args.count, 10) || 20, 1), 50);
  const source =
    'https://jike.info/api/tags/' +
    encodeURIComponent(tag);
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      hint: resp.status === 404 ? 'Tag not found' : 'API error',
      source,
    };
  }

  const data = await resp.json();
  const topics = (data.topics || []).slice(0, count).map((topic, index) => ({
    rank: index + 1,
    tid: topic.tid || 0,
    title: topic.title || '',
    slug: topic.slug || '',
    url: topic.slug
      ? 'https://jike.info/topic/' + topic.slug
      : topic.tid
        ? 'https://jike.info/topic/' + topic.tid
        : '',
    category: topic.category?.name || '',
    author: topic.user?.username || topic.username || '',
    posts: topic.postcount || topic.posts || 0,
    views: topic.viewcount || 0,
    tags: (topic.tags || []).map((item) =>
      typeof item === 'string' ? item : item.value || item.name || ''
    ),
    last_post_at: topic.lastposttimeISO || topic.lastposttime || null,
  }));

  return {
    source,
    tag,
    count: topics.length,
    topics,
  };
}

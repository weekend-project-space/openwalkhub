async (args) => {
  const page = Math.max(parseInt(args.page, 10) || 1, 1);
  const count = Math.min(Math.max(parseInt(args.count, 10) || 20, 1), 50);
  const source =
    'https://jike.info/api/recent?page=' +
    page;
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      source,
    };
  }

  const data = await resp.json();
  const topics = (data.topics || []).slice(0, count).map((topic, index) => ({
    rank: (page - 1) * count + index + 1,
    tid: topic.tid || 0,
    title: topic.title || '',
    slug: topic.slug || '',
    url: topic.slug
      ? 'https://jike.info/topic/' + topic.slug
      : topic.tid
        ? 'https://jike.info/topic/' + topic.tid
        : '',
    category: topic.category?.name || '',
    category_slug: topic.category?.slug || '',
    author: topic.user?.username || topic.username || '',
    author_uid: topic.user?.uid || topic.uid || 0,
    tags: (topic.tags || []).map((tag) =>
      typeof tag === 'string' ? tag : tag.value || tag.name || ''
    ),
    posts: topic.postcount || topic.posts || 0,
    views: topic.viewcount || 0,
    replies: Math.max((topic.postcount || topic.posts || 1) - 1, 0),
    created_at: topic.timestampISO || null,
    last_post_at: topic.lastposttimeISO || topic.lastposttime || null,
    teaser:
      topic.teaser?.content ||
      topic.teaser?.text ||
      '',
  }));

  return {
    source,
    page,
    count: topics.length,
    topics,
  };
}

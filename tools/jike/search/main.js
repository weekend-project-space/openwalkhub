async (args) => {
  const keyword = args.keyword || '';
  if (!keyword) {
    return {
      error: 'Missing argument: keyword',
    };
  }

  const count = Math.min(Math.max(parseInt(args.count, 10) || 10, 1), 20);
  const source =
    'https://jike.info/api/search?term=' +
    encodeURIComponent(keyword) +
    '&in=titlesposts';
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      source,
    };
  }

  const data = await resp.json();
  const posts = (data.posts || data.results || []).slice(0, count).map((post, index) => ({
    rank: index + 1,
    pid: post.pid || 0,
    tid: post.tid || 0,
    topic_title: post.topic?.title || post.topicTitle || post.title || '',
    url:
      post.topic?.slug
        ? 'https://jike.info/topic/' + post.topic.slug
        : post.slug
          ? 'https://jike.info/topic/' + post.slug
          : post.tid
            ? 'https://jike.info/topic/' + post.tid
            : '',
    author: post.user?.username || post.username || '',
    author_uid: post.user?.uid || post.uid || 0,
    category: post.category?.name || '',
    category_slug: post.category?.slug || '',
    content:
      post.content ||
      post.teaser ||
      post.excerpt ||
      '',
    created_at: post.timestampISO || null,
    votes: post.votes || 0,
  }));

  return {
    source,
    keyword,
    count: posts.length,
    posts,
  };
}

async (args) => {
  const query = args.query;
  const subreddit = args.subreddit || '';
  const sort = args.sort || 'relevance';
  const time = args.time || 'all';
  const count = Math.min(Number(args.count) || 25, 100);
  const source = subreddit
    ? 'https://www.reddit.com/r/' +
      encodeURIComponent(subreddit) +
      '/search.json?restrict_sr=on&q=' +
      encodeURIComponent(query)
    : 'https://www.reddit.com/search.json?q=' +
      encodeURIComponent(query);
  const url =
    source +
    '&sort=' +
    encodeURIComponent(sort) +
    '&t=' +
    encodeURIComponent(time) +
    '&limit=' +
    count +
    '&raw_json=1' +
    (args.after ? '&after=' + encodeURIComponent(args.after) : '');

  try {
    const resp = await fetch(url, {credentials: 'include'});
    if (!resp.ok) {
      return {
        error: 'HTTP ' + resp.status,
        hint: resp.status === 404
          ? 'Subreddit not found'
          : 'Open https://www.reddit.com first, ensure you can access the JSON endpoint, then retry.',
        source: url,
      };
    }

    const data = await resp.json();
    const posts = (data.data?.children || []).map((child, index) => {
      const post = child.data || {};
      return {
        rank: index + 1,
        id: post.name || '',
        title: post.title || '',
        author: post.author || '',
        subreddit: post.subreddit_name_prefixed || '',
        score: post.score || 0,
        num_comments: post.num_comments || 0,
        created_utc: post.created_utc || 0,
        url: post.url || '',
        permalink: post.permalink
          ? `https://www.reddit.com${post.permalink}`
          : '',
        selftext_preview: (post.selftext || '').slice(0, 200),
        is_self: !!post.is_self,
        link_flair_text: post.link_flair_text || null,
      };
    });

    return {
      query,
      subreddit: subreddit || null,
      sort,
      time,
      count: posts.length,
      after: data.data?.after || null,
      posts,
    };
  } catch (error) {
    return {
      error: 'Unexpected response',
      hint: 'Open https://www.reddit.com first, ensure you can access the JSON endpoint, then retry.',
      detail: String(error),
      source: url,
    };
  }
}

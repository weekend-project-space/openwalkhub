async (args) => {
  const subreddit = args.subreddit || '';
  const count = args.count;
  const source = subreddit
    ? 'https://www.reddit.com/r/' +
      encodeURIComponent(subreddit) +
      '/hot.json?limit=' +
      count +
      '&raw_json=1'
    : 'https://www.reddit.com/hot.json?limit=' +
      count +
      '&raw_json=1';

  try {
    const resp = await fetch(source);
    if (!resp.ok) {
      return {
        error: 'HTTP ' + resp.status,
        hint: 'Open https://www.reddit.com first, ensure you can access the JSON endpoint, then retry.',
        source,
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
        upvote_ratio: post.upvote_ratio || 0,
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
      subreddit: subreddit || 'front page',
      count: posts.length,
      posts,
    };
  } catch (error) {
    return {
      error: 'Unexpected response',
      hint: 'Open https://www.reddit.com first, ensure you can access the JSON endpoint, then retry.',
      detail: String(error),
      source,
    };
  }
}

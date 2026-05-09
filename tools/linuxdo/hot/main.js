async (args) => {
  const validPeriods = [
    'daily',
    'weekly',
    'monthly',
    'quarterly',
    'yearly',
    'all',
  ];
  const period = validPeriods.includes(args.period) ? args.period : 'daily';
  const primarySource =
    'https://linux.do/top.json?period=' + encodeURIComponent(period);
  const fallbackSource = 'https://linux.do/latest.json';
  const limit = Math.min(50, Math.max(1, Number(args.count) || 30));

  const toResult = (data, source) => {
    const topics = (data.topic_list?.topics || [])
      .slice(0, limit)
      .map((topic, index) => ({
        rank: index + 1,
        id: topic.id,
        title: topic.title || '',
        slug: topic.slug || '',
        url: topic.slug
          ? `https://linux.do/t/${topic.slug}/${topic.id}`
          : `https://linux.do/t/topic/${topic.id}`,
        posts_count: topic.posts_count || 0,
        reply_count: Math.max((topic.posts_count || 1) - 1, 0),
        views: topic.views || 0,
        like_count: topic.like_count || 0,
        created_at: topic.created_at || '',
        bumped_at: topic.bumped_at || '',
        last_posted_at: topic.last_posted_at || '',
        pinned: !!topic.pinned,
        pinned_globally: !!topic.pinned_globally,
        visible: topic.visible !== false,
        excerpt: topic.excerpt || '',
        category_id: topic.category_id || 0,
        tags: topic.tags || [],
      }));

    return {
      count: topics.length,
      period,
      source,
      topics,
    };
  };

  try {
    const primaryResp = await fetch(primarySource);
    if (primaryResp.ok) {
      const data = await primaryResp.json();
      if (data?.topic_list?.topics) {
        return toResult(data, primarySource);
      }
    }
  } catch (error) {
  }

  try {
    const fallbackResp = await fetch(fallbackSource, {
      headers: {
        accept: 'application/json, text/plain, */*',
        'x-requested-with': 'XMLHttpRequest',
      },
    });

    if (fallbackResp.ok) {
      const fallbackData = await fallbackResp.json();
      return toResult(fallbackData, fallbackSource);
    }

    return {
      error: `HTTP ${fallbackResp.status || 403}`,
      hint: 'Open https://linux.do in your browser first, ensure you are logged in if required, then retry.',
    };
  } catch (error) {
    return {
      error: 'Unexpected response',
      hint: 'Open https://linux.do in your browser first, ensure you are logged in if required, then retry.',
      detail: String(error),
    };
  }
}

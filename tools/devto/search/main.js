async (args) => {
  const query = args.query;
  if (!query) {
    return {
      error: 'query is required',
    };
  }

  const count = Math.min(Number(args.count) || 20, 60);
  const appId = 'PRSOBFP46H';
  const apiKey = '9aa7d31610cba78851c9b1f63776a9dd';
  const source =
    'https://' +
    appId +
    '-dsn.algolia.net/1/indexes/Article_production/query?x-algolia-application-id=' +
    appId +
    '&x-algolia-api-key=' +
    apiKey;

  const resp = await fetch(source, {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: JSON.stringify({
      query,
      hitsPerPage: String(count),
      queryType: 'prefixNone',
      page: '0',
    }),
  });

  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      hint: 'Algolia API error',
      source,
    };
  }

  const data = await resp.json();
  const hits = data.hits || [];

  return {
    source,
    query,
    count: hits.length,
    articles: hits.map((article) => ({
      title: article.title || '',
      url: article.path ? 'https://dev.to' + article.path : '',
      author: article.user?.name || '',
      username: article.user?.username || '',
      published_at: article.readable_publish_date || null,
      reactions: article.public_reactions_count || 0,
      comments: article.comments_count || 0,
      tags: article.tag_list || [],
      reading_time: article.reading_time || null,
    })),
  };
}

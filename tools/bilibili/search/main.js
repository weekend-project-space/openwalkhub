async (args) => {
  const keyword = args.keyword || '';
  if (!keyword) {
    return {
      error: 'Missing argument: keyword',
    };
  }

  const page = parseInt(args.page, 10) || 1;
  const ps = Math.min(parseInt(args.count, 10) || 20, 50);
  const order = args.order || 'totalrank';
  const params = new URLSearchParams({
    search_type: 'video',
    keyword,
    page: String(page),
    page_size: String(ps),
    order,
  });
  const source =
    'https://api.bilibili.com/x/web-interface/wbi/search/type?' +
    params.toString();
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      hint: 'Not logged in?',
      source,
    };
  }

  const data = await resp.json();
  if (data.code !== 0) {
    return {
      error: data.message || 'API error ' + data.code,
      hint: 'Not logged in?',
      source,
    };
  }

  const stripHtml = (text) => (text || '').replace(/<[^>]*>/g, '');
  const videos = (data.data?.result || []).map((item) => ({
    bvid: item.bvid || '',
    title: stripHtml(item.title || ''),
    author: item.author || '',
    duration: item.duration || '',
    play: item.play || 0,
    danmaku: item.danmaku || 0,
    like: item.like || 0,
    favorites: item.favorites || 0,
    pub_date: item.pubdate
      ? new Date(item.pubdate * 1000).toISOString()
      : null,
    url: item.bvid
      ? 'https://www.bilibili.com/video/' + item.bvid
      : '',
  }));

  return {
    source,
    keyword,
    page,
    total: data.data?.numResults || 0,
    count: videos.length,
    videos,
  };
}

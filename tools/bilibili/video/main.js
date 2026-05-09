async (args) => {
  const bvid = args.bvid || '';
  if (!bvid) {
    return {
      error: 'Missing argument: bvid',
    };
  }

  const source =
    'https://api.bilibili.com/x/web-interface/view?bvid=' +
    encodeURIComponent(bvid);
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
      hint: data.code === -404 ? 'Video not found' : 'Not logged in?',
      source,
    };
  }

  const video = data.data;
  const result = {
    source,
    bvid: video.bvid || '',
    aid: video.aid || 0,
    title: video.title || '',
    description: video.desc || '',
    cover: video.pic || '',
    duration: video.duration || 0,
    duration_text:
      Math.floor((video.duration || 0) / 60) +
      ':' +
      String((video.duration || 0) % 60).padStart(2, '0'),
    author: video.owner?.name || '',
    author_mid: video.owner?.mid || 0,
    author_face: video.owner?.face || '',
    category: video.tname || '',
    tags: video.tag || null,
    pub_date: video.pubdate
      ? new Date(video.pubdate * 1000).toISOString()
      : null,
    stat: {
      view: video.stat?.view || 0,
      like: video.stat?.like || 0,
      dislike: video.stat?.dislike || 0,
      coin: video.stat?.coin || 0,
      favorite: video.stat?.favorite || 0,
      share: video.stat?.share || 0,
      reply: video.stat?.reply || 0,
      danmaku: video.stat?.danmaku || 0,
    },
    pages: (video.pages || []).map((page) => ({
      page: page.page || 0,
      cid: page.cid || 0,
      title: page.part || '',
      duration: page.duration || 0,
    })),
    url: video.bvid
      ? 'https://www.bilibili.com/video/' + video.bvid
      : '',
  };

  try {
    const relatedSource =
      'https://api.bilibili.com/x/web-interface/archive/related?bvid=' +
      encodeURIComponent(bvid);
    const resp2 = await fetch(relatedSource, {credentials: 'include'});
    const data2 = await resp2.json();
    if (data2.code === 0 && data2.data) {
      result.related = data2.data.slice(0, 5).map((item) => ({
        bvid: item.bvid || '',
        title: item.title || '',
        author: item.owner?.name || '',
        view: item.stat?.view || 0,
        duration: item.duration || 0,
        url: item.bvid
          ? 'https://www.bilibili.com/video/' + item.bvid
          : '',
      }));
    }
  } catch (error) {
  }

  return result;
}

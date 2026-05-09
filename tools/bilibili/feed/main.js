async (args) => {
  const inputType = (args.type || 'all').toLowerCase();
  const typeMap = {
    all: 'all',
    video: 'video',
    article: 'article',
  };
  const feedType = typeMap[inputType];
  if (!feedType) {
    return {
      error: 'Invalid argument: type',
      hint: 'Use all, video, or article',
    };
  }

  const page = Math.max(parseInt(args.page, 10) || 1, 1);
  const count = Math.min(Math.max(parseInt(args.count, 10) || 20, 1), 50);
  const offset = page > 1 ? String((page - 1) * count) : '';
  const params = new URLSearchParams({
    timezone_offset: '-480',
    type: feedType,
    page: String(page),
  });
  if (offset) {
    params.set('offset', offset);
  }

  const source =
    'https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all?' +
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

  const modulesToText = (module) => {
    if (!module) return '';
    if (typeof module.text === 'string') return module.text;
    if (Array.isArray(module.rich_text_nodes)) {
      return module.rich_text_nodes
        .map((node) => node.text || node.orig_text || '')
        .join('')
        .trim();
    }
    return '';
  };

  const items = (data.data?.items || []).slice(0, count).map((item, index) => {
    const author = item.modules?.module_author || {};
    const dynamic = item.modules?.module_dynamic || {};
    const major = dynamic.major || {};
    const archive = major.archive || {};
    const article = major.article || {};
    const opus = major.opus || {};
    const desc = modulesToText(dynamic.desc || dynamic.summary || opus.summary);
    const common = {
      rank: (page - 1) * count + index + 1,
      id: item.id_str || item.basic?.comment_id_str || '',
      type: item.type || '',
      author: author.name || '',
      author_mid: author.mid || 0,
      author_face: author.face || '',
      author_pub_time: author.pub_ts
        ? new Date(author.pub_ts * 1000).toISOString()
        : null,
      description: desc,
    };

    if (archive.bvid || archive.aid) {
      return {
        ...common,
        kind: 'video',
        title: archive.title || '',
        cover: archive.cover || '',
        duration_text: archive.duration_text || '',
        view: archive.stat?.play || 0,
        danmaku: archive.stat?.danmaku || 0,
        url: archive.bvid
          ? 'https://www.bilibili.com/video/' + archive.bvid
          : archive.jump_url || '',
      };
    }

    if (article.id || article.jump_url) {
      return {
        ...common,
        kind: 'article',
        title: article.title || '',
        cover: article.covers?.[0] || '',
        images: article.covers || [],
        url: article.jump_url || '',
      };
    }

    if (opus.jump_url || opus.pics?.length) {
      return {
        ...common,
        kind: 'opus',
        title: '',
        cover: opus.pics?.[0]?.url || '',
        images: (opus.pics || []).map((pic) => pic.url || ''),
        url: opus.jump_url || '',
      };
    }

    return {
      ...common,
      kind: 'dynamic',
      title: '',
      cover: '',
      url:
        item.id_str
          ? 'https://t.bilibili.com/' + item.id_str
          : '',
    };
  });

  return {
    source,
    type: feedType,
    page,
    count: items.length,
    has_more: !!data.data?.has_more,
    offset: data.data?.offset || null,
    update_baseline: data.data?.update_baseline || null,
    items,
  };
}

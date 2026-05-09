async (args) => {
  const id = args.id || '';
  if (!id) {
    return {
      error: 'Missing argument: id',
    };
  }

  const source =
    'https://api.bilibili.com/x/polymer/web-dynamic/v1/detail?id=' +
    encodeURIComponent(id);
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      hint: 'Dynamic not found or unavailable',
      source,
    };
  }

  const data = await resp.json();
  if (data.code !== 0) {
    return {
      error: data.message || 'API error ' + data.code,
      hint: 'Dynamic not found or unavailable',
      source,
    };
  }

  const item = data.data?.item;
  if (!item) {
    return {
      error: 'Dynamic not found',
      source,
    };
  }

  const author = item.modules?.module_author || {};
  const dynamic = item.modules?.module_dynamic || {};
  const stat = item.modules?.module_stat || {};
  const major = dynamic.major || {};
  const opus = major.opus || {};
  const paragraphNodes = opus.paragraphs || [];

  const textParts = [];
  for (const paragraph of paragraphNodes) {
    for (const node of paragraph.nodes || []) {
      const text =
        node.word?.words ||
        node.text ||
        node.orig_text ||
        node.emoji?.text ||
        '';
      if (text) {
        textParts.push(text);
      }
    }
    if (paragraph.nodes?.length) {
      textParts.push('\n');
    }
  }

  let text = textParts.join('').trim();
  if (!text && Array.isArray(dynamic.desc?.rich_text_nodes)) {
    text = dynamic.desc.rich_text_nodes
      .map((node) => node.text || node.orig_text || '')
      .join('')
      .trim();
  }

  return {
    source,
    id: item.id_str || id,
    type: item.type || '',
    title: opus.title || '',
    text,
    summary: dynamic.desc?.text || '',
    images: (opus.pics || []).map((pic) => ({
      url: pic.url || '',
      width: pic.width || 0,
      height: pic.height || 0,
    })),
    author: author.name || '',
    author_mid: author.mid || 0,
    author_face: author.face || '',
    pub_date: author.pub_ts
      ? new Date(author.pub_ts * 1000).toISOString()
      : null,
    stat: {
      like: stat.like?.count || 0,
      repost: stat.forward?.count || 0,
      reply: stat.comment?.count || 0,
    },
    url:
      opus.jump_url ||
      (item.id_str ? 'https://t.bilibili.com/' + item.id_str : ''),
  };
}

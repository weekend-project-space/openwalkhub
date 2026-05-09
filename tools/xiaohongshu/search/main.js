async (args) => {
  const keyword = args.keyword || '';
  if (!keyword) {
    return {
      error: 'Missing argument: keyword',
    };
  }

  const limit = Math.min(Math.max(parseInt(args.count, 10) || 10, 1), 20);
  const source =
    'https://www.xiaohongshu.com/search_result?keyword=' +
    encodeURIComponent(keyword);
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      hint: 'Open the search page first, ensure it is publicly accessible, then retry.',
      source,
    };
  }

  const html = await resp.text();
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const cards = [...doc.querySelectorAll('section.note-item, .note-item')]
    .slice(0, limit);

  const cleanText = (text) =>
    String(text || '').replace(/\s+/g, ' ').trim();

  const notes = cards.map((card, index) => {
    const link = card.querySelector('a.cover, a[href*="/explore/"]');
    const titleEl = card.querySelector('.title span, .title');
    const userEl = card.querySelector('.author .name, .user-name');
    const likeEl = card.querySelector('.like-wrapper .count, .like');
    const imgEl = card.querySelector('img');
    const href = link?.getAttribute('href') || '';
    const url = href.startsWith('http')
      ? href
      : href
        ? 'https://www.xiaohongshu.com' + href
        : '';
    const noteIdMatch = url.match(/\/explore\/([^/?]+)/);

    return {
      rank: index + 1,
      note_id: noteIdMatch ? noteIdMatch[1] : '',
      title: cleanText(titleEl?.textContent || ''),
      author: cleanText(userEl?.textContent || ''),
      likes_text: cleanText(likeEl?.textContent || ''),
      cover: imgEl?.getAttribute('src') || '',
      url,
    };
  });

  if (notes.length > 0) {
    return {
      source,
      keyword,
      count: notes.length,
      notes,
    };
  }

  const stateMatch = html.match(/<script[^>]*>window\.__INITIAL_STATE__\s*=\s*(\{[\s\S]*?\})<\/script>/);
  if (!stateMatch) {
    return {
      error: 'Search results not found',
      hint: 'The search page may require login or changed its structure',
      source,
    };
  }

  const state = JSON.parse(stateMatch[1]);
  const noteItems =
    state.searchResult?.noteList ||
    state.searchResult?.notes ||
    [];
  const normalized = noteItems.slice(0, limit).map((item, index) => ({
    rank: index + 1,
    note_id: item.id || item.noteId || '',
    title: item.displayTitle || item.title || '',
    author: item.user?.nickname || item.author?.nickname || '',
    likes_text: String(item.interactInfo?.likedCount || item.likeCount || ''),
    cover:
      item.cover?.urlDefault ||
      item.cover?.url ||
      item.image || '',
    url:
      item.id || item.noteId
        ? 'https://www.xiaohongshu.com/explore/' + (item.id || item.noteId)
        : '',
  }));

  return {
    source,
    keyword,
    count: normalized.length,
    notes: normalized,
  };
}

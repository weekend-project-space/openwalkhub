async (args) => {
  const keyword = args.keyword || '';
  if (!keyword) {
    return {
      error: 'Missing argument: keyword',
    };
  }

  const limit = Math.min(Math.max(parseInt(args.count, 10) || 10, 1), 20);
  const source =
    'https://s.weibo.com/weibo?q=' +
    encodeURIComponent(keyword) +
    '&Refer=top';
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      hint: 'Open https://s.weibo.com first, ensure you can access the page, then retry.',
      source,
    };
  }

  const html = await resp.text();
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const cards = [...doc.querySelectorAll('.card-wrap')]
    .filter((card) => card.querySelector('.content .txt'))
    .slice(0, limit);

  const cleanText = (text) =>
    String(text || '').replace(/\s+/g, ' ').trim();
  const toNumber = (text) =>
    parseInt(String(text || '').replace(/[^0-9]/g, ''), 10) || 0;

  const posts = cards.map((card, index) => {
    const userLink = card.querySelector('.content .name');
    const textNode = card.querySelector('.content .txt');
    const fromLink = card.querySelector('.from a');
    const actionItems = [...card.querySelectorAll('.card-act li')];
    const detailHref = fromLink?.getAttribute('href') || '';
    const detailUrl = detailHref.startsWith('http')
      ? detailHref
      : detailHref
        ? 'https:' + detailHref
        : '';

    return {
      rank: index + 1,
      mid: card.getAttribute('mid') || '',
      author: cleanText(userLink?.textContent || ''),
      author_url: userLink?.href || '',
      text: cleanText(textNode?.textContent || ''),
      url: detailUrl,
      created_at: cleanText(fromLink?.textContent || ''),
      reposts: toNumber(actionItems[1]?.textContent || ''),
      comments: toNumber(actionItems[2]?.textContent || ''),
      likes: toNumber(actionItems[3]?.textContent || ''),
    };
  });

  return {
    source,
    keyword,
    count: posts.length,
    posts,
  };
}

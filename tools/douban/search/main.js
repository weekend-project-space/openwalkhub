async (args) => {
  const keyword = args.keyword || '';
  if (!keyword) {
    return {
      error: 'Missing argument: keyword',
    };
  }

  const limit = Math.min(Math.max(parseInt(args.count, 10) || 10, 1), 20);
  const source =
    'https://www.douban.com/search?q=' +
    encodeURIComponent(keyword);
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      hint: 'Open https://www.douban.com first, ensure you can access the page, then retry.',
      source,
    };
  }

  const html = await resp.text();
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const blocks = [...doc.querySelectorAll('.result')]
    .filter((item) => item.querySelector('.content .title a'))
    .slice(0, limit);

  const cleanText = (text) =>
    String(text || '').replace(/\s+/g, ' ').trim();

  const results = blocks.map((item, index) => {
    const titleLink = item.querySelector('.content .title a');
    const typeTag = item.querySelector('.content .title span');
    const ratingEl = item.querySelector('.rating_nums');
    const metaEl = item.querySelector('.subject-cast, .metadata');
    const abstractEl = item.querySelector('.content p');
    const picEl = item.querySelector('.pic img');

    return {
      rank: index + 1,
      type: cleanText(typeTag?.textContent || '').replace(/[\[\]]/g, ''),
      title: cleanText(titleLink?.textContent || ''),
      url: titleLink?.href || '',
      rating: ratingEl ? Number(ratingEl.textContent) || 0 : 0,
      meta: cleanText(metaEl?.textContent || ''),
      abstract: cleanText(abstractEl?.textContent || ''),
      cover: picEl?.getAttribute('src') || '',
    };
  });

  return {
    source,
    keyword,
    count: results.length,
    results,
  };
}

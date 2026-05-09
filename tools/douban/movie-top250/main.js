async (args) => {
  const page = Math.max(parseInt(args.page, 10) || 1, 1);
  const start = (page - 1) * 25;
  const source =
    'https://movie.douban.com/top250?start=' +
    start;
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      hint: 'Open https://movie.douban.com first, ensure you can access the page, then retry.',
      source,
    };
  }

  const html = await resp.text();
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const movies = [...doc.querySelectorAll('ol.grid_view > li')];
  const cleanText = (text) =>
    String(text || '').replace(/\s+/g, ' ').trim();

  const items = movies.map((movie) => {
    const rank = parseInt(movie.querySelector('.pic em')?.textContent || '0', 10) || 0;
    const titleNodes = [...movie.querySelectorAll('.title')];
    const title = cleanText(titleNodes[0]?.textContent || '');
    const altTitle = cleanText(titleNodes.slice(1).map((node) => node.textContent || '').join(' / '));
    const rating = Number(movie.querySelector('.rating_num')?.textContent || 0) || 0;
    const quote = cleanText(movie.querySelector('.inq')?.textContent || '');
    const meta = cleanText(movie.querySelector('.bd p')?.textContent || '');
    const link = movie.querySelector('.pic a');
    const image = movie.querySelector('.pic img');

    return {
      rank,
      title,
      alt_title: altTitle,
      rating,
      quote,
      meta,
      url: link?.href || '',
      cover: image?.getAttribute('src') || '',
    };
  });

  return {
    source,
    page,
    count: items.length,
    items,
  };
}

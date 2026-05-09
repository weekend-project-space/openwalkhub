async (args) => {
  const limit = Math.min(50, Math.max(1, Number(args.count) || 20));
  const rows = Array.from(document.querySelectorAll('tr.athing')).slice(0, limit);
  const posts = rows
    .map((row, index) => {
      const id = Number(row.getAttribute('id'));
      const titleLink = row.querySelector('.titleline > a');
      const subtextRow = row.nextElementSibling;
      const scoreEl = subtextRow?.querySelector('.score');
      const authorEl = subtextRow?.querySelector('.hnuser');
      const links = Array.from(subtextRow?.querySelectorAll('a') || []);
      const commentsLink =
        links.find((link) => /comment/i.test((link.textContent || '').trim())) ||
        links[links.length - 1];
      const commentsText = (commentsLink?.textContent || '0').trim();
      const comments = commentsText === 'discuss'
        ? 0
        : Number.parseInt(commentsText, 10) || 0;

      return {
        rank: index + 1,
        id,
        title: titleLink?.textContent?.trim() || '',
        url: titleLink?.href || '',
        hn_url: `https://news.ycombinator.com/item?id=${id}`,
        author: authorEl?.textContent?.trim() || '',
        score: Number.parseInt(scoreEl?.textContent || '0', 10) || 0,
        comments,
      };
    })
    .filter((post) => post.id && post.title);

  return {
    count: posts.length,
    posts,
  };
}

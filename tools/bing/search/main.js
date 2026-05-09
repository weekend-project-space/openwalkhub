async (args) => {
  const limit = Math.max(1, Number(args.count) || 10);
  const query = document.querySelector('#sb_form_q')?.value?.trim() || '';
  const results = Array.from(document.querySelectorAll('#b_results li.b_algo'))
    .map((item, index) => {
      const anchor = item.querySelector('h2 > a');
      if (!anchor) {
        return null;
      }

      const title = (anchor.innerText || anchor.textContent || '').trim();
      if (!title) {
        return null;
      }

      const snippetNode = item.querySelector('.b_caption p, p');
      const snippet = snippetNode
        ? (snippetNode.innerText || snippetNode.textContent || '').trim()
        : '';

      return {
        index: index + 1,
        title,
        url: anchor.href || '',
        snippet,
      };
    })
    .filter(Boolean)
    .slice(0, limit);

  return {
    query,
    count: results.length,
    results,
  };
}

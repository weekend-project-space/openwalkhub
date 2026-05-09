async (args) => {
  const query = args.query || '';
  if (!query) {
    return {
      error: 'Missing argument: query',
    };
  }

  const maxResults = Math.min(parseInt(args.count, 10) || 10, 30);
  const jsessionid = document.cookie
    .split(';')
    .map((cookie) => cookie.trim())
    .find((cookie) => cookie.startsWith('JSESSIONID='))
    ?.split('=')
    .slice(1)
    .join('=');
  if (!jsessionid) {
    return {
      error: 'No JSESSIONID cookie',
      hint: 'Please log in to https://www.linkedin.com first.',
    };
  }

  const csrfToken = jsessionid.replace(/"/g, '');
  const source =
    '/search/results/content/?keywords=' +
    encodeURIComponent(query);
  const resp = await fetch(source, {
    credentials: 'include',
    headers: {'csrf-token': csrfToken},
  });
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      hint: 'Search fetch failed. Are you logged in?',
      source: 'https://www.linkedin.com' + source,
    };
  }

  const html = await resp.text();
  const postMeta = [];
  const metaRe = new RegExp('\\"actorName\\":\\"([^\"]+)\\"', 'g');
  let match;
  while ((match = metaRe.exec(html)) !== null) {
    const name = match[1];
    const nearby = html.substring(match.index, Math.min(match.index + 2000, html.length));
    const rawSlug =
      (nearby.match(new RegExp('\\"postSlugUrl\\":\\"(https:[^\"]+)\\"')) || [])[1] ||
      '';
    const slug = rawSlug.replace(/\\/g, '').split('\"')[0];
    postMeta.push({name, slug});
  }

  const textBlocks = [];
  let searchIndex = 0;
  const marker = '\"textProps\"';

  while (true) {
    const markerIndex = html.indexOf(marker, searchIndex);
    if (markerIndex === -1) break;

    const block = html.substring(markerIndex, Math.min(markerIndex + 15000, html.length));
    const hasTextAttr = block.substring(0, 300).includes('text-attr');
    let fullText = '';

    if (hasTextAttr) {
      const segments = [];
      const pattern1 = new RegExp('\\"children\\":\\[null,\\"(.*?)\\"\\]', 'g');
      let seg;
      while ((seg = pattern1.exec(block)) !== null) {
        const text = seg[1];
        if (text.length > 0 && !text.startsWith('$')) {
          segments.push(text);
        }
      }

      const pattern2 = new RegExp('\\[\\"\\$\\",\\"br\\",null,\\{\\}\\],\\"(.*?)\\"\\]', 'g');
      while ((seg = pattern2.exec(block)) !== null) {
        const text = seg[1];
        if (text.length > 0 && !text.startsWith('$')) {
          segments.push(text);
        }
      }

      if (segments.length > 0) {
        fullText = segments.join('\n');
      }
    } else {
      const directMatch =
        block.match(new RegExp('\\"children\\":\\[\\"((?:[^"\\\\]|\\\\.)*)\\"\\]')) ||
        [];
      if (directMatch[1]) {
        fullText = directMatch[1].replace(/\\n/g, '\n');
      }
    }

    if (fullText.length > 20) {
      fullText = fullText
        .replace(/\\u00a0/g, '\u00a0')
        .replace(/\\u2019/g, '\u2019')
        .replace(/\\u2018/g, '\u2018')
        .replace(/\\u201c/g, '\u201c')
        .replace(/\\u201d/g, '\u201d')
        .replace(/\\u2014/g, '\u2014')
        .replace(/\\u2013/g, '\u2013');

      const key = fullText.substring(0, 100);
      if (!textBlocks.some((item) => item.text.substring(0, 100) === key)) {
        textBlocks.push({pos: markerIndex, text: fullText});
      }
    }

    searchIndex = markerIndex + 1;
  }

  const posts = [];
  const limit = Math.min(postMeta.length, textBlocks.length, maxResults);
  for (let index = 0; index < limit; index += 1) {
    posts.push({
      author: postMeta[index].name || '',
      url: postMeta[index].slug || '',
      text: textBlocks[index].text.substring(0, 800),
    });
  }

  if (posts.length === 0 && postMeta.length > 0) {
    const fallbackLimit = Math.min(postMeta.length, maxResults);
    for (let index = 0; index < fallbackLimit; index += 1) {
      posts.push({
        author: postMeta[index].name || '',
        url: postMeta[index].slug || '',
        text: '(text extraction failed)',
      });
    }
  }

  if (posts.length === 0) {
    return {
      error: 'No posts found',
      hint: 'Fetched ' + html.length + ' bytes but could not extract posts. Make sure you are logged in.',
      source: 'https://www.linkedin.com' + source,
    };
  }

  return {
    source: 'https://www.linkedin.com' + source,
    query,
    count: posts.length,
    posts,
  };
}

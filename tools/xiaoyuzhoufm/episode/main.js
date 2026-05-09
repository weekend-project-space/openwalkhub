async (args) => {
  if (!args.eid) {
    return {
      error: 'Missing argument: eid',
    };
  }

  const indexSource = 'https://www.xiaoyuzhoufm.com/';
  const indexResp = await fetch(indexSource, {credentials: 'include'});
  if (!indexResp.ok) {
    return {
      error: 'Cannot fetch index: HTTP ' + indexResp.status,
      source: indexSource,
    };
  }

  const indexHtml = await indexResp.text();
  const buildMatch = indexHtml.match(/"buildId":"([^"]+)"/);
  if (!buildMatch) {
    return {
      error: 'Cannot find buildId',
      source: indexSource,
    };
  }

  const buildId = buildMatch[1];
  const source =
    'https://www.xiaoyuzhoufm.com/_next/data/' +
    buildId +
    '/episode/' +
    args.eid +
    '.json?id=' +
    args.eid;

  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'API HTTP ' + resp.status,
      source,
    };
  }

  const data = await resp.json();
  const episode = data.pageProps?.episode;
  if (!episode) {
    return {
      error: 'No episode data',
      source,
    };
  }

  let shownotes = '';
  let links = [];
  let guests = [];
  if (episode.shownotes) {
    const doc = new DOMParser().parseFromString(episode.shownotes, 'text/html');
    shownotes = doc.body.textContent?.trim() || '';

    const anchors = doc.querySelectorAll('a[href], a[data-url]');
    for (const anchor of anchors) {
      const href =
        anchor.getAttribute('href') ||
        anchor.getAttribute('data-url') ||
        '';
      const text = anchor.textContent?.trim() || '';
      if (href && href.startsWith('http')) {
        links.push({text, url: href});
      }
    }

    const guestMatch = shownotes.match(/嘉宾[：:]\s*([\s\S]*?)(?:本期|Shownotes|时间线|$)/i);
    if (guestMatch) {
      guests = guestMatch[1]
        .split('\n')
        .filter((line) => line.trim().length > 2)
        .slice(0, 5)
        .map((line) => line.trim());
    }
  }

  return {
    source,
    eid: args.eid,
    title: episode.title || '',
    podcastTitle: episode.podcast?.title || null,
    podcastPid: episode.podcast?.pid || null,
    playCount: episode.playCount || 0,
    commentCount: episode.commentCount || 0,
    favoriteCount: episode.favoriteCount || 0,
    duration: episode.duration || 0,
    durationMin: Math.round((episode.duration || 0) / 60),
    pubDate: episode.pubDate || '',
    guests,
    links,
    shownotes: shownotes.substring(0, 3000),
    url: 'https://www.xiaoyuzhoufm.com/episode/' + args.eid,
  };
}

async (args) => {
  if (!args.pid) {
    return {
      error: 'Missing argument: pid',
    };
  }

  const source =
    'https://www.xiaoyuzhoufm.com/podcast/' +
    encodeURIComponent(args.pid);
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      source,
    };
  }

  const html = await resp.text();
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const nextDataEl = doc.querySelector('#__NEXT_DATA__');
  if (!nextDataEl) {
    return {
      error: 'No __NEXT_DATA__ found',
      source,
    };
  }

  const nextData = JSON.parse(nextDataEl.textContent);
  const podcast = nextData?.props?.pageProps?.podcast;
  if (!podcast) {
    return {
      error: 'No podcast data',
      source,
    };
  }

  const buildId = nextData.buildId;
  const eids = [];
  const seen = {};
  for (const match of html.match(/episode\/([a-f0-9]{24})/g) || []) {
    const eid = match.replace('episode/', '');
    if (!seen[eid]) {
      seen[eid] = true;
      eids.push(eid);
    }
  }

  let schemaTitles = [];
  for (const script of doc.querySelectorAll('script')) {
    const text = script.textContent || '';
    if (text.includes('"@context"') && text.includes('workExample')) {
      try {
        const schema = JSON.parse(text);
        schemaTitles = (schema.workExample || []).map((item) => ({
          title: item.name || null,
          date: item.datePublished ? item.datePublished.substring(0, 10) : null,
          description: (item.description || '').substring(0, 200),
        }));
      } catch (error) {
      }
      break;
    }
  }

  const episodeList = [];
  for (let index = 0; index < eids.length; index += 1) {
    const meta = schemaTitles[index] || {};
    episodeList.push({
      eid: eids[index],
      title: meta.title || null,
      date: meta.date || null,
      description: meta.description || null,
      playCount: null,
      commentCount: null,
      favoriteCount: null,
    });
  }

  if (buildId && episodeList.length > 0) {
    const results = await Promise.all(
      episodeList.slice(0, 20).map(async (episode) => {
        if (!episode.eid) return null;
        const apiUrl =
          'https://www.xiaoyuzhoufm.com/_next/data/' +
          buildId +
          '/episode/' +
          episode.eid +
          '.json?id=' +
          episode.eid;
        try {
          const r = await fetch(apiUrl, {credentials: 'include'});
          return r.ok ? await r.json() : null;
        } catch (error) {
          return null;
        }
      })
    );

    for (let index = 0; index < results.length; index += 1) {
      const episodeData = results[index]?.pageProps?.episode;
      if (!episodeData) continue;

      episodeList[index].playCount = episodeData.playCount || 0;
      episodeList[index].commentCount = episodeData.commentCount || 0;
      episodeList[index].favoriteCount = episodeData.favoriteCount || 0;

      if (episodeData.shownotes) {
        const tmp = new DOMParser().parseFromString(episodeData.shownotes, 'text/html');
        const links = [];
        for (const anchor of tmp.querySelectorAll('a[href]')) {
          const href =
            anchor.getAttribute('href') ||
            anchor.getAttribute('data-url') ||
            '';
          if (href && href.startsWith('http')) {
            links.push(href);
          }
        }
        episodeList[index].shownotes =
          (tmp.body.textContent || '').trim().substring(0, 2000);
        episodeList[index].links = links;
      }
    }
  }

  return {
    source,
    pid: args.pid,
    title: podcast.title || '',
    author: podcast.author || '',
    description: (podcast.description || '').substring(0, 500),
    subscriptionCount: podcast.subscriptionCount || 0,
    episodeCount: podcast.episodeCount || 0,
    latestEpisodePubDate: podcast.latestEpisodePubDate || '',
    url: source,
    episodes: episodeList.slice(0, 20),
  };
}

async (args) => {
  const query = args.query || '';
  if (!query) {
    return {
      error: 'Missing argument: query',
      hint: 'Provide a search query',
    };
  }

  const cfg = window.ytcfg?.data_ || {};
  const apiKey = cfg.INNERTUBE_API_KEY;
  const context = cfg.INNERTUBE_CONTEXT;
  if (!apiKey || !context) {
    return {
      error: 'YouTube config not found',
      hint: 'Make sure you are on youtube.com',
    };
  }

  const max = Math.min(parseInt(args.max, 10) || 20, 50);
  const source =
    '/youtubei/v1/search?key=' +
    apiKey +
    '&prettyPrint=false';
  const resp = await fetch(source, {
    method: 'POST',
    credentials: 'include',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({context, query}),
  });

  if (!resp.ok) {
    return {
      error: 'Search API returned HTTP ' + resp.status,
      hint: 'YouTube API error',
      source: 'https://www.youtube.com' + source,
    };
  }

  const data = await resp.json();
  const contents =
    data.contents?.twoColumnSearchResultsRenderer?.primaryContents?.sectionListRenderer?.contents ||
    [];
  const videos = [];

  for (const section of contents) {
    const items = section.itemSectionRenderer?.contents || [];
    for (const item of items) {
      if (item.videoRenderer && videos.length < max) {
        const video = item.videoRenderer;
        videos.push({
          videoId: video.videoId || '',
          title: video.title?.runs?.[0]?.text || '',
          channel: video.ownerText?.runs?.[0]?.text || '',
          channelId:
            video.ownerText?.runs?.[0]?.navigationEndpoint?.browseEndpoint?.browseId || '',
          views:
            video.viewCountText?.simpleText ||
            video.shortViewCountText?.simpleText ||
            '',
          duration: video.lengthText?.simpleText || 'LIVE',
          publishedTime: video.publishedTimeText?.simpleText || '',
          description:
            (video.detailedMetadataSnippets?.[0]?.snippetText?.runs || [])
              .map((run) => run.text || '')
              .join('')
              .substring(0, 200),
          url: video.videoId
            ? 'https://www.youtube.com/watch?v=' + video.videoId
            : '',
        });
      }
    }
  }

  return {
    source: 'https://www.youtube.com' + source,
    query,
    resultCount: videos.length,
    videos,
  };
}

async (args) => {
  const cfg = window.ytcfg?.data_ || {};
  const apiKey = cfg.INNERTUBE_API_KEY;
  const context = cfg.INNERTUBE_CONTEXT;
  if (!apiKey || !context) {
    return {
      error: 'YouTube config not found',
      hint: 'Make sure you are on youtube.com',
    };
  }

  const max = Math.min(parseInt(args.max, 10) || 10, 30);
  let browseId = args.id || '';

  if (!browseId) {
    const match = location.href.match(/youtube\.com\/(channel\/|c\/|@)([^/?]+)/);
    if (match) {
      browseId = match[1] === 'channel/' ? match[2] : '@' + match[2].replace(/^@/, '');
    }
  }
  if (!browseId) {
    return {
      error: 'No channel ID or handle',
      hint: 'Provide a channel ID (UCxxxx) or handle (@name)',
    };
  }

  let resolvedBrowseId = browseId;
  if (browseId.startsWith('@')) {
    const resolveSource =
      '/youtubei/v1/navigation/resolve_url?key=' +
      apiKey +
      '&prettyPrint=false';
    const resolveResp = await fetch(resolveSource, {
      method: 'POST',
      credentials: 'include',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        context,
        url: 'https://www.youtube.com/' + browseId,
      }),
    });
    if (resolveResp.ok) {
      const resolveData = await resolveResp.json();
      resolvedBrowseId =
        resolveData.endpoint?.browseEndpoint?.browseId || browseId;
    }
  }

  const source =
    '/youtubei/v1/browse?key=' +
    apiKey +
    '&prettyPrint=false';
  const resp = await fetch(source, {
    method: 'POST',
    credentials: 'include',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
      context,
      browseId: resolvedBrowseId,
    }),
  });

  if (!resp.ok) {
    return {
      error: 'Channel API returned HTTP ' + resp.status,
      hint: resp.status === 404 ? 'Channel not found' : 'API error',
      source: 'https://www.youtube.com' + source,
    };
  }

  const data = await resp.json();
  const metadata = data.metadata?.channelMetadataRenderer || {};
  const header =
    data.header?.pageHeaderRenderer ||
    data.header?.c4TabbedHeaderRenderer ||
    {};

  let subscriberCount = '';
  if (
    header.content?.pageHeaderViewModel?.metadata?.contentMetadataViewModel?.metadataRows
  ) {
    const rows =
      header.content.pageHeaderViewModel.metadata.contentMetadataViewModel.metadataRows;
    for (const row of rows) {
      for (const part of row.metadataParts || []) {
        const text = part.text?.content || '';
        if (text.includes('subscriber')) {
          subscriberCount = text;
        }
      }
    }
  }

  const tabs = data.contents?.twoColumnBrowseResultsRenderer?.tabs || [];
  const tabNames = tabs
    .map((tab) => tab.tabRenderer?.title || tab.expandableTabRenderer?.title || '')
    .filter(Boolean);
  const recentVideos = [];

  const homeTab = tabs.find((tab) => tab.tabRenderer?.selected);
  if (homeTab) {
    const sections =
      homeTab.tabRenderer?.content?.sectionListRenderer?.contents || [];
    for (const section of sections) {
      const shelfItems = section.itemSectionRenderer?.contents || [];
      for (const shelf of shelfItems) {
        const items =
          shelf.shelfRenderer?.content?.horizontalListRenderer?.items || [];
        for (const item of items) {
          const lvm = item.lockupViewModel;
          if (
            lvm &&
            lvm.contentType === 'LOCKUP_CONTENT_TYPE_VIDEO' &&
            recentVideos.length < max
          ) {
            const meta = lvm.metadata?.lockupMetadataViewModel;
            const rows =
              meta?.metadata?.contentMetadataViewModel?.metadataRows || [];
            let viewsAndTime = (rows[0]?.metadataParts || [])
              .map((part) => part.text?.content || '')
              .filter(Boolean)
              .join(' | ');
            const overlays =
              lvm.contentImage?.thumbnailViewModel?.overlays || [];
            let duration = '';
            for (const overlay of overlays) {
              for (const badge of overlay.thumbnailBottomOverlayViewModel?.badges || []) {
                if (badge.thumbnailBadgeViewModel?.text) {
                  duration = badge.thumbnailBadgeViewModel.text;
                }
              }
            }
            recentVideos.push({
              videoId: lvm.contentId || '',
              title: meta?.title?.content || '',
              duration,
              viewsAndTime,
              url: lvm.contentId
                ? 'https://www.youtube.com/watch?v=' + lvm.contentId
                : '',
            });
          }

          if (item.gridVideoRenderer && recentVideos.length < max) {
            const video = item.gridVideoRenderer;
            recentVideos.push({
              videoId: video.videoId || '',
              title:
                video.title?.runs?.[0]?.text ||
                video.title?.simpleText ||
                '',
              duration:
                video.thumbnailOverlays?.[0]?.thumbnailOverlayTimeStatusRenderer?.text?.simpleText ||
                '',
              viewsAndTime:
                (video.shortViewCountText?.simpleText || '') +
                (video.publishedTimeText?.simpleText
                  ? ' | ' + video.publishedTimeText.simpleText
                  : ''),
              url: video.videoId
                ? 'https://www.youtube.com/watch?v=' + video.videoId
                : '',
            });
          }
        }
      }
    }
  }

  return {
    source: 'https://www.youtube.com' + source,
    channelId: metadata.externalId || resolvedBrowseId,
    name: metadata.title || '',
    handle: metadata.vanityChannelUrl?.split('/').pop() || '',
    description: (metadata.description || '').substring(0, 500),
    subscriberCount,
    channelUrl:
      metadata.channelUrl ||
      'https://www.youtube.com/channel/' + resolvedBrowseId,
    keywords: metadata.keywords || '',
    isFamilySafe: metadata.isFamilySafe,
    tabs: tabNames,
    recentVideoCount: recentVideos.length,
    recentVideos,
  };
}

#| @meta
{
  "name": "youtube/video",
  "description": "获取 YouTube 视频详情并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": false,
      "description": "Video ID，默认当前页面视频"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ videoId, title, channel, channelId, viewCount, likes, publishDate, url }"
  },
  "examples": [
    "openwalk exec youtube/video -- d56mG7DezGs"
  ],
  "domains": [
    "www.youtube.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "youtube",
    "video",
    "details"
  ]
}
|#

(defun main (args)
  (open "https://www.youtube.com")
  (js-call args
    " const currentUrl = location.href;
      let videoId = args.id || '';

      if (!videoId) {
        const match = currentUrl.match(/[?&]v=([a-zA-Z0-9_-]{11})/);
        if (match) {
          videoId = match[1];
        }
      }
      if (!videoId) {
        return {
          error: 'No video ID',
          hint: 'Provide a video ID or navigate to a YouTube video page',
        };
      }

      const onVideoPage = currentUrl.includes('watch?v=' + videoId);
      if (onVideoPage && window.ytInitialPlayerResponse && window.ytInitialData) {
        const player = window.ytInitialPlayerResponse;
        const data = window.ytInitialData;
        const details = player.videoDetails || {};
        const microformat = player.microformat?.playerMicroformatRenderer || {};
        const results =
          data.contents?.twoColumnWatchNextResults?.results?.results?.contents || [];
        const primary =
          results.find((item) => item.videoPrimaryInfoRenderer)?.videoPrimaryInfoRenderer;
        const secondary =
          results.find((item) => item.videoSecondaryInfoRenderer)?.videoSecondaryInfoRenderer;
        const owner = secondary?.owner?.videoOwnerRenderer;

        let likeCount = '';
        const menuRenderer = primary?.videoActions?.menuRenderer;
        if (menuRenderer?.topLevelButtons) {
          for (const button of menuRenderer.topLevelButtons) {
            const segmented = button.segmentedLikeDislikeButtonViewModel;
            if (segmented) {
              likeCount =
                segmented.likeButtonViewModel?.likeButtonViewModel?.toggleButtonViewModel?.toggleButtonViewModel?.defaultButtonViewModel?.buttonViewModel?.title ||
                '';
            }
          }
        }

        const commentSection = results.find(
          (item) => item.itemSectionRenderer?.targetId === 'comments-section'
        );
        const commentToken =
          commentSection?.itemSectionRenderer?.contents?.[0]?.continuationItemRenderer?.continuationEndpoint?.continuationCommand?.token ||
          null;

        return {
          videoId: details.videoId || videoId,
          title: details.title || '',
          channel: details.author || '',
          channelId: details.channelId || '',
          channelUrl: owner?.navigationEndpoint?.browseEndpoint?.canonicalBaseUrl
            ? 'https://www.youtube.com' + owner.navigationEndpoint.browseEndpoint.canonicalBaseUrl
            : '',
          subscriberCount: owner?.subscriberCountText?.simpleText || '',
          description: (details.shortDescription || '').substring(0, 1000),
          duration: parseInt(details.lengthSeconds, 10) || 0,
          durationFormatted: (() => {
            const seconds = parseInt(details.lengthSeconds, 10) || 0;
            const h = Math.floor(seconds / 3600);
            const m = Math.floor((seconds % 3600) / 60);
            const s = seconds % 60;
            return h > 0
              ? h + ':' + String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0')
              : m + ':' + String(s).padStart(2, '0');
          })(),
          viewCount: parseInt(details.viewCount, 10) || 0,
          viewCountFormatted:
            primary?.viewCount?.videoViewCountRenderer?.viewCount?.simpleText || '',
          likes: likeCount,
          publishDate: microformat.publishDate || primary?.dateText?.simpleText || '',
          category: microformat.category || '',
          isLive: !!details.isLiveContent,
          keywords: (details.keywords || []).slice(0, 20),
          captionLanguages: (player.captions?.playerCaptionsTracklistRenderer?.captionTracks || [])
            .map((track) => ({
              lang: track.languageCode || '',
              name: track.name?.simpleText || '',
            })),
          url: details.videoId
            ? 'https://www.youtube.com/watch?v=' + details.videoId
            : 'https://www.youtube.com/watch?v=' + videoId,
          _commentContinuationToken: commentToken,
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

      const source =
        '/youtubei/v1/next?key=' +
        apiKey +
        '&prettyPrint=false';
      const resp = await fetch(source, {
        method: 'POST',
        credentials: 'include',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({context, videoId}),
      });

      if (!resp.ok) {
        return {
          error: 'API returned HTTP ' + resp.status,
          source: 'https://www.youtube.com' + source,
        };
      }

      const data = await resp.json();
      const results =
        data.contents?.twoColumnWatchNextResults?.results?.results?.contents || [];
      const primary =
        results.find((item) => item.videoPrimaryInfoRenderer)?.videoPrimaryInfoRenderer;
      const secondary =
        results.find((item) => item.videoSecondaryInfoRenderer)?.videoSecondaryInfoRenderer;
      const owner = secondary?.owner?.videoOwnerRenderer;

      let likeCount = '';
      const menuRenderer = primary?.videoActions?.menuRenderer;
      if (menuRenderer?.topLevelButtons) {
        for (const button of menuRenderer.topLevelButtons) {
          const segmented = button.segmentedLikeDislikeButtonViewModel;
          if (segmented) {
            likeCount =
              segmented.likeButtonViewModel?.likeButtonViewModel?.toggleButtonViewModel?.toggleButtonViewModel?.defaultButtonViewModel?.buttonViewModel?.title ||
              '';
          }
        }
      }

      return {
        source: 'https://www.youtube.com' + source,
        videoId,
        title: primary?.title?.runs?.[0]?.text || '',
        channel: owner?.title?.runs?.[0]?.text || '',
        channelId: owner?.navigationEndpoint?.browseEndpoint?.browseId || '',
        subscriberCount: owner?.subscriberCountText?.simpleText || '',
        viewCountFormatted:
          primary?.viewCount?.videoViewCountRenderer?.viewCount?.simpleText || '',
        likes: likeCount,
        publishDate: primary?.dateText?.simpleText || '',
        url: 'https://www.youtube.com/watch?v=' + videoId,
      };
    "))

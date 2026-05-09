#| @meta
{
  "name": "youtube/comments",
  "description": "获取 YouTube 视频评论并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": false,
      "description": "Video ID，默认当前页面视频"
    },
    {
      "name": "max",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回评论数量，默认 20，最大 100"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ videoId, commentCountText, fetchedCount, comments[] }"
  },
  "examples": [
    "openwalk exec youtube/comments -- d56mG7DezGs"
  ],
  "domains": [
    "www.youtube.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "youtube",
    "comments",
    "video"
  ]
}
|#

(defun main (args)
  (open "https://www.youtube.com")
  (js-call args
    " const currentUrl = location.href;
      let videoId = args.id || '';
      const max = Math.min(parseInt(args.max, 10) || 20, 100);

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

      const cfg = window.ytcfg?.data_ || {};
      const apiKey = cfg.INNERTUBE_API_KEY;
      const context = cfg.INNERTUBE_CONTEXT;
      if (!apiKey || !context) {
        return {
          error: 'YouTube config not found',
          hint: 'Make sure you are on youtube.com',
        };
      }

      let continuationToken = null;
      if (currentUrl.includes('watch?v=' + videoId) && window.ytInitialData) {
        const results =
          window.ytInitialData.contents?.twoColumnWatchNextResults?.results?.results?.contents ||
          [];
        const commentSection = results.find(
          (item) => item.itemSectionRenderer?.targetId === 'comments-section'
        );
        continuationToken =
          commentSection?.itemSectionRenderer?.contents?.[0]?.continuationItemRenderer?.continuationEndpoint?.continuationCommand?.token ||
          null;
      }

      if (!continuationToken) {
        const nextSource =
          '/youtubei/v1/next?key=' +
          apiKey +
          '&prettyPrint=false';
        const nextResp = await fetch(nextSource, {
          method: 'POST',
          credentials: 'include',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({context, videoId}),
        });
        if (!nextResp.ok) {
          return {
            error: 'Failed to get video data: HTTP ' + nextResp.status,
            source: 'https://www.youtube.com' + nextSource,
          };
        }

        const nextData = await nextResp.json();
        const results =
          nextData.contents?.twoColumnWatchNextResults?.results?.results?.contents || [];
        const commentSection = results.find(
          (item) => item.itemSectionRenderer?.targetId === 'comments-section'
        );
        continuationToken =
          commentSection?.itemSectionRenderer?.contents?.[0]?.continuationItemRenderer?.continuationEndpoint?.continuationCommand?.token ||
          null;
      }

      if (!continuationToken) {
        return {
          error: 'No comment section found',
          hint: 'Comments may be disabled for this video',
          videoId,
        };
      }

      const source =
        '/youtubei/v1/next?key=' +
        apiKey +
        '&prettyPrint=false';
      const commentResp = await fetch(source, {
        method: 'POST',
        credentials: 'include',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({context, continuation: continuationToken}),
      });

      if (!commentResp.ok) {
        return {
          error: 'Failed to fetch comments: HTTP ' + commentResp.status,
          source: 'https://www.youtube.com' + source,
        };
      }

      const commentData = await commentResp.json();
      const mutations =
        commentData.frameworkUpdates?.entityBatchUpdate?.mutations || [];
      const commentEntities = mutations.filter(
        (mutation) => mutation.payload?.commentEntityPayload
      );

      let headerInfo = null;
      const actions = commentData.onResponseReceivedEndpoints || [];
      for (const action of actions) {
        const items =
          action.reloadContinuationItemsCommand?.continuationItems || [];
        for (const item of items) {
          if (item.commentsHeaderRenderer) {
            headerInfo =
              item.commentsHeaderRenderer.countText?.runs
                ?.map((run) => run.text || '')
                .join('') || '';
          }
        }
      }

      const comments = commentEntities.slice(0, max).map((mutation, index) => {
        const payload = mutation.payload.commentEntityPayload;
        const props = payload.properties || {};
        const author = payload.author || {};
        const toolbar = payload.toolbar || {};
        return {
          rank: index + 1,
          author: author.displayName || '',
          authorChannelId: author.channelId || '',
          text: (props.content?.content || '').substring(0, 500),
          publishedTime: props.publishedTime || '',
          likes: toolbar.likeCountNotliked || '0',
          replyCount: toolbar.replyCount || '0',
          isPinned: !!payload.pinnedText,
        };
      });

      return {
        source: 'https://www.youtube.com' + source,
        videoId,
        commentCountText: headerInfo || '',
        fetchedCount: comments.length,
        comments,
      };
    "))

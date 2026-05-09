#| @meta
{
  "name": "youtube/transcript",
  "description": "获取 YouTube 视频字幕并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": false,
      "description": "Video ID，默认当前页面视频"
    },
    {
      "name": "lang",
      "type": "string",
      "required": false,
      "description": "字幕语言代码，例如 en、ja"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ videoId, language, segmentCount, segments[], fullText }"
  },
  "examples": [
    "openwalk exec youtube/transcript",
    "openwalk exec youtube/transcript -- d56mG7DezGs --lang en"
  ],
  "domains": [
    "www.youtube.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "youtube",
    "transcript",
    "captions"
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

      async function getPlayerResponse(targetVideoId) {
        const onVideoPage =
          location.href.includes('watch?v=' + targetVideoId) &&
          window.ytInitialPlayerResponse;
        if (onVideoPage) {
          return window.ytInitialPlayerResponse;
        }

        const cfg = window.ytcfg?.data_ || {};
        const apiKey = cfg.INNERTUBE_API_KEY;
        const context = cfg.INNERTUBE_CONTEXT;
        if (!apiKey || !context) {
          throw new Error('YouTube config not found');
        }

        const source =
          '/youtubei/v1/player?key=' +
          apiKey +
          '&prettyPrint=false';
        const resp = await fetch(source, {
          method: 'POST',
          credentials: 'include',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({context, videoId: targetVideoId}),
        });
        if (!resp.ok) {
          throw new Error('Player API returned HTTP ' + resp.status);
        }
        return await resp.json();
      }

      let playerResponse;
      try {
        playerResponse = await getPlayerResponse(videoId);
      } catch (error) {
        return {
          error: String(error.message || error),
          hint: 'Make sure you are on youtube.com',
        };
      }

      const trackList = playerResponse?.captions?.playerCaptionsTracklistRenderer;
      const tracks = trackList?.captionTracks || [];
      const availableTracks = tracks.map((track) => ({
        lang: track.languageCode || '',
        name: track.name?.simpleText || '',
        kind: track.kind || '',
      }));

      if (!tracks.length) {
        return {
          error: 'No captions available',
          hint: 'This video may not have captions/subtitles available.',
          videoId,
          availableTracks,
        };
      }

      let selectedTrack = null;
      if (args.lang) {
        selectedTrack =
          tracks.find((track) => track.languageCode === args.lang) || null;
        if (!selectedTrack) {
          return {
            error: 'Language \"' + args.lang + '\" not found',
            hint:
              'Available: ' +
              availableTracks
                .map((track) => track.lang + ' (' + (track.name || track.kind || '') + ')')
                .join(', '),
            videoId,
            availableTracks,
          };
        }
      } else {
        selectedTrack = tracks[0];
      }

      const source = selectedTrack.baseUrl || '';
      if (!source) {
        return {
          error: 'Caption track URL missing',
          videoId,
        };
      }

      const resp = await fetch(source, {credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'Transcript API returned HTTP ' + resp.status,
          source,
        };
      }

      const xml = await resp.text();
      const doc = new DOMParser().parseFromString(xml, 'application/xml');
      const segments = Array.from(doc.querySelectorAll('text')).map((node) => {
        const start = parseFloat(node.getAttribute('start') || '0') || 0;
        const duration = parseFloat(node.getAttribute('dur') || '0') || 0;
        const text = (node.textContent || '')
          .replace(/&#39;/g, \"'\")
          .replace(/&quot;/g, '\"')
          .replace(/&amp;/g, '&')
          .replace(/&lt;/g, '<')
          .replace(/&gt;/g, '>')
          .replace(/\\s+/g, ' ')
          .trim();
        return {
          start,
          duration,
          startFormatted: (() => {
            const total = Math.floor(start);
            const h = Math.floor(total / 3600);
            const m = Math.floor((total % 3600) / 60);
            const s = total % 60;
            return h > 0
              ? h + ':' + String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0')
              : m + ':' + String(s).padStart(2, '0');
          })(),
          text,
        };
      }).filter((segment) => segment.text);

      const fullText = segments.map((segment) => segment.text).join(' ');
      const lastSegment = segments[segments.length - 1];
      const totalDuration = lastSegment
        ? lastSegment.start + lastSegment.duration
        : 0;

      return {
        source,
        videoId,
        language: selectedTrack.languageCode || 'unknown',
        languageName: selectedTrack.name?.simpleText || '',
        kind: selectedTrack.kind || 'manual',
        segmentCount: segments.length,
        totalDuration,
        availableTracks,
        segments,
        fullText: fullText.substring(0, 5000),
      };
    "))

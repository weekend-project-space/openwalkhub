#| @meta
{
  "name": "bilibili/popular",
  "description": "获取 Bilibili 热门视频并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回视频数量，默认 20，最大 50"
    },
    {
      "name": "page",
      "type": "number",
      "required": false,
      "default": 1,
      "description": "页码，默认 1"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ page, count, no_more, videos[] }"
  },
  "examples": [
    "openwalk exec bilibili/popular -- 10"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "popular",
    "videos"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-call args
    " const ps = Math.min(parseInt(args.count, 10) || 20, 50);
      const pn = parseInt(args.page, 10) || 1;
      const source =
        'https://api.bilibili.com/x/web-interface/popular?ps=' +
        ps +
        '&pn=' +
        pn;
      const resp = await fetch(source, {credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: 'Not logged in?',
          source,
        };
      }

      const data = await resp.json();
      if (data.code !== 0) {
        return {
          error: data.message || 'API error ' + data.code,
          hint: 'Not logged in?',
          source,
        };
      }

      const videos = (data.data?.list || []).map((video, index) => ({
        rank: (pn - 1) * ps + index + 1,
        bvid: video.bvid || '',
        title: video.title || '',
        author: video.owner?.name || '',
        author_mid: video.owner?.mid || 0,
        cover: video.pic || '',
        duration: video.duration || 0,
        view: video.stat?.view || 0,
        like: video.stat?.like || 0,
        danmaku: video.stat?.danmaku || 0,
        reply: video.stat?.reply || 0,
        favorite: video.stat?.favorite || 0,
        coin: video.stat?.coin || 0,
        share: video.stat?.share || 0,
        category: video.tname || '',
        pub_date: video.pubdate
          ? new Date(video.pubdate * 1000).toISOString()
          : null,
        url: video.bvid
          ? 'https://www.bilibili.com/video/' + video.bvid
          : '',
        reason: video.rcmd_reason?.content || null,
      }));

      return {
        source,
        page: pn,
        count: videos.length,
        no_more: !!data.data?.no_more,
        videos,
      };
    "))

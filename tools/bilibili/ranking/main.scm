#| @meta
{
  "name": "bilibili/ranking",
  "description": "获取 Bilibili 排行榜视频并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回视频数量，默认 20，最大 100"
    },
    {
      "name": "category",
      "type": "number",
      "required": false,
      "default": 0,
      "description": "分类 rid，默认 0=全站"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ category, count, videos[] }"
  },
  "examples": [
    "openwalk exec bilibili/ranking",
    "openwalk exec bilibili/ranking -- --category 36"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "ranking",
    "videos"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-call args
    " const count = Math.min(parseInt(args.count, 10) || 20, 100);
      const rid = parseInt(args.category, 10) || 0;
      const source =
        'https://api.bilibili.com/x/web-interface/ranking/v2?rid=' +
        rid +
        '&type=all';
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

      const categoryNames = {
        0: 'all',
        1: 'anime',
        3: 'music',
        4: 'game',
        5: 'dance',
        36: 'knowledge',
        188: 'tech',
        160: 'life',
        211: 'food',
        217: 'animal',
        119: 'kichiku',
        155: 'fashion',
        202: 'info',
        165: 'ad',
        234: 'sports',
        223: 'car',
        177: 'documentary',
        181: 'movie',
        11: 'tv',
      };

      const videos = (data.data?.list || []).slice(0, count).map((video, index) => ({
        rank: index + 1,
        bvid: video.bvid || '',
        title: video.title || '',
        author: video.owner?.name || '',
        author_mid: video.owner?.mid || 0,
        cover: video.pic || '',
        duration: video.duration || 0,
        view: video.stat?.view || 0,
        like: video.stat?.like || 0,
        danmaku: video.stat?.danmaku || 0,
        coin: video.stat?.coin || 0,
        favorite: video.stat?.favorite || 0,
        category: video.tname || '',
        pub_date: video.pubdate
          ? new Date(video.pubdate * 1000).toISOString()
          : null,
        url: video.bvid
          ? 'https://www.bilibili.com/video/' + video.bvid
          : '',
      }));

      return {
        source,
        category: categoryNames[rid] || String(rid),
        count: videos.length,
        videos,
      };
    "))

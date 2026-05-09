#| @meta
{
  "name": "bilibili/search",
  "description": "搜索 Bilibili 视频并返回结构化结果",
  "args": [
    {
      "name": "keyword",
      "type": "string",
      "required": true,
      "description": "搜索关键词"
    },
    {
      "name": "page",
      "type": "number",
      "required": false,
      "default": 1,
      "description": "页码，默认 1"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "每页结果数量，默认 20，最大 50"
    },
    {
      "name": "order",
      "type": "string",
      "required": false,
      "default": "totalrank",
      "description": "排序：totalrank、click、pubdate、dm、stow"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ keyword, page, total, count, videos[] }"
  },
  "examples": [
    "openwalk exec bilibili/search -- 编程"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "search",
    "videos"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-call args
    " const keyword = args.keyword || '';
      if (!keyword) {
        return {
          error: 'Missing argument: keyword',
        };
      }

      const page = parseInt(args.page, 10) || 1;
      const ps = Math.min(parseInt(args.count, 10) || 20, 50);
      const order = args.order || 'totalrank';
      const params = new URLSearchParams({
        search_type: 'video',
        keyword,
        page: String(page),
        page_size: String(ps),
        order,
      });
      const source =
        'https://api.bilibili.com/x/web-interface/wbi/search/type?' +
        params.toString();
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

      const stripHtml = (text) => (text || '').replace(/<[^>]*>/g, '');
      const videos = (data.data?.result || []).map((item) => ({
        bvid: item.bvid || '',
        title: stripHtml(item.title || ''),
        author: item.author || '',
        duration: item.duration || '',
        play: item.play || 0,
        danmaku: item.danmaku || 0,
        like: item.like || 0,
        favorites: item.favorites || 0,
        pub_date: item.pubdate
          ? new Date(item.pubdate * 1000).toISOString()
          : null,
        url: item.bvid
          ? 'https://www.bilibili.com/video/' + item.bvid
          : '',
      }));

      return {
        source,
        keyword,
        page,
        total: data.data?.numResults || 0,
        count: videos.length,
        videos,
      };
    "))

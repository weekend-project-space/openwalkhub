#| @meta
{
  "name": "bilibili/history",
  "description": "获取 Bilibili 观看历史并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回数量，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, items[] }"
  },
  "examples": [
    "openwalk exec bilibili/history -- 10"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "bilibili",
    "history",
    "videos"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-call args
    " const ps = Math.min(parseInt(args.count, 10) || 20, 50);
      const source =
        'https://api.bilibili.com/x/web-interface/history/cursor?ps=' +
        ps +
        '&type=archive';
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
      if (!data.data?.list) {
        return {
          error: 'No history data',
          hint: 'Not logged in?',
          source,
        };
      }

      const items = (data.data.list || []).map((item) => {
        const progress =
          item.progress === -1
            ? 'completed'
            : item.progress > 0
              ? Math.floor(item.progress / 60) +
                ':' +
                String(item.progress % 60).padStart(2, '0')
              : 'not_started';
        const duration_text =
          item.duration > 0
            ? Math.floor(item.duration / 60) +
              ':' +
              String(item.duration % 60).padStart(2, '0')
            : null;
        return {
          bvid: item.history?.bvid || '',
          title: item.title || '',
          author: item.author_name || '',
          author_mid: item.author_mid || 0,
          cover: item.cover || '',
          duration: item.duration || 0,
          duration_text,
          progress,
          progress_seconds: item.progress || 0,
          view_at: item.view_at
            ? new Date(item.view_at * 1000).toISOString()
            : null,
          tag_name: item.tag_name || '',
          url: item.history?.bvid
            ? 'https://www.bilibili.com/video/' + item.history.bvid
            : null,
        };
      });

      return {
        source,
        count: items.length,
        items,
      };
    "))

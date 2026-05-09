#| @meta
{
  "name": "bilibili/trending",
  "description": "获取 Bilibili 热搜词并返回结构化结果",
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
    "openwalk exec bilibili/trending"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "trending",
    "keywords"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-call args
    " const count = Math.min(parseInt(args.count, 10) || 20, 50);
      const source =
        'https://api.bilibili.com/x/web-interface/wbi/search/square?limit=' +
        count;
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

      const items = (data.data?.trending?.list || [])
        .slice(0, count)
        .map((item, index) => ({
          rank: index + 1,
          keyword: item.keyword || '',
          show_name: item.show_name || '',
          is_hot: !!item.icon,
          icon: item.icon || null,
          search_url:
            'https://search.bilibili.com/all?keyword=' +
            encodeURIComponent(item.keyword || ''),
        }));

      return {
        source,
        count: items.length,
        items,
      };
    "))

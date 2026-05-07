#| @meta
{
  "name": "zhihu/hot",
  "description": "获取知乎热榜并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回结果数量，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, items[] }"
  },
  "examples": [
    "openwalk exec zhihu/hot",
    "openwalk exec zhihu/hot -- 10"
  ],
  "domains": [
    "www.zhihu.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "zhihu",
    "hot",
    "questions"
  ]
}
|#

(defun main (args)
  (open "https://www.zhihu.com")
  (js-call args
    " const limit = Math.min(50, Math.max(1, Number(args.count) || 20));
      const source = 'https://www.zhihu.com/api/v3/feed/topstory/hot-lists/total?limit=50';

      try {
        const resp = await fetch(source);
        if (!resp.ok) {
          return {
            error: 'HTTP ' + resp.status,
            hint: 'Open https://www.zhihu.com first, ensure you can access the API, then retry.',
            source,
          };
        }

        const data = await resp.json();
        const items = (data.data || [])
          .slice(0, limit)
          .map((item, index) => {
            const target = item.target || {};
            return {
              rank: index + 1,
              id: target.id,
              title: target.title || '',
              url: target.id ? `https://www.zhihu.com/question/${target.id}` : '',
              excerpt: target.excerpt || '',
              answer_count: target.answer_count || 0,
              follower_count: target.follower_count || 0,
              heat: item.detail_text || '',
              trend: item.trend === 0 ? 'stable' : item.trend > 0 ? 'up' : 'down',
              is_new: !!item.debut,
            };
          });

        return {
          count: items.length,
          items,
        };
      } catch (error) {
        return {
          error: 'Unexpected response',
          hint: 'Open https://www.zhihu.com first, ensure you can access the API, then retry.',
          detail: String(error),
          source,
        };
      }
    "))

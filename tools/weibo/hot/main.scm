#| @meta
{
  "name": "weibo/hot",
  "description": "获取微博热搜榜并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回条数，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, items[] }"
  },
  "examples": [
    "openwalk exec weibo/hot",
    "openwalk exec weibo/hot -- 10"
  ],
  "domains": [
    "s.weibo.com",
    "weibo.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "weibo",
    "hot",
    "trending"
  ]
}
|#

(defun main (args)
  (open "https://s.weibo.com")
  (js-call args
    " const limit = Math.min(Math.max(parseInt(args.count, 10) || 20, 1), 50);
      const source = 'https://s.weibo.com/top/summary?cate=realtimehot';
      const resp = await fetch(source, {credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: 'Open https://s.weibo.com first, ensure you can access the page, then retry.',
          source,
        };
      }

      const html = await resp.text();
      const doc = new DOMParser().parseFromString(html, 'text/html');
      const rows = [...doc.querySelectorAll('#pl_top_realtimehot table tbody tr')]
        .filter((row) => row.querySelector('.td-02 a'))
        .slice(0, limit);

      const toNumber = (text) =>
        parseInt(String(text || '').replace(/[^0-9]/g, ''), 10) || 0;

      const items = rows.map((row, index) => {
        const rankText = row.querySelector('.td-01')?.textContent || '';
        const link = row.querySelector('.td-02 a');
        const heatText = row.querySelector('.td-02 span')?.textContent || '';
        const labelText = row.querySelector('.td-03 a, .td-03 i')?.textContent || '';
        const href = link?.getAttribute('href') || '';
        const url = href.startsWith('http')
          ? href
          : href
            ? 'https://s.weibo.com' + href
            : '';

        return {
          rank: toNumber(rankText) || index + 1,
          keyword: link?.textContent?.replace(/\\s+/g, ' ').trim() || '',
          url,
          heat: heatText.trim(),
          heat_number: toNumber(heatText),
          label: labelText.trim() || null,
          is_pinned: rankText.includes('置顶'),
        };
      });

      return {
        source,
        count: items.length,
        items,
      };
    "))

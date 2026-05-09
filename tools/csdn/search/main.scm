#| @meta
{
  "name": "csdn/search",
  "description": "搜索 CSDN 技术文章并返回结构化结果",
  "args": [
    {
      "name": "query",
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
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, page, total, count, results[] }"
  },
  "examples": [
    "openwalk exec csdn/search -- \"Python\""
  ],
  "domains": [
    "so.csdn.net"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "csdn",
    "search",
    "articles"
  ]
}
|#

(defun main (args)
  (open "https://so.csdn.net")
  (js-call args
    " const query = args.query;
      if (!query) {
        return {
          error: 'Missing argument: query',
        };
      }

      const page = parseInt(args.page, 10) || 1;
      const source =
        'https://so.csdn.net/api/v3/search?q=' +
        encodeURIComponent(query) +
        '&t=all&p=' +
        page +
        '&s=0&tm=0&lv=-1&ft=0&l=&u=&ct=-1&pnt=-1&ry=-1&ss=-1&dct=-1&vco=-1&cc=-1&sc=-1&ald=-1&ep=&wp=0';

      const resp = await fetch(source, {credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: 'Make sure so.csdn.net is accessible',
          source,
        };
      }

      const data = await resp.json();
      const strip = (html) => (html || '')
        .replace(/<[^>]+>/g, '')
        .replace(/&nbsp;/g, ' ')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
        .replace(/&amp;/g, '&')
        .trim();

      const results = (data.result_vos || []).map((item, index) => ({
        rank: (page - 1) * 20 + index + 1,
        type: item.type || '',
        title: strip(item.title || ''),
        url: item.url || '',
        description: strip(item.description || item.body || '').substring(0, 300),
        author: item.nickname || item.author || '',
        views: parseInt(item.view, 10) || 0,
        likes: parseInt(item.digg, 10) || 0,
        collections: parseInt(item.collections, 10) || 0,
        created: item.create_time
          ? new Date(parseInt(item.create_time, 10)).toISOString()
          : null,
      }));

      return {
        source,
        query,
        page,
        total: data.total || 0,
        count: results.length,
        results,
      };
    "))

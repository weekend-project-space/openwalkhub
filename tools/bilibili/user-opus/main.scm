#| @meta
{
  "name": "bilibili/user-opus",
  "description": "获取 Bilibili 用户图文动态列表并返回结构化结果",
  "args": [
    {
      "name": "mid",
      "type": "string",
      "required": true,
      "description": "用户 mid"
    },
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
    "description": "{ mid, count, items[] }"
  },
  "examples": [
    "openwalk exec bilibili/user-opus -- 2",
    "openwalk exec bilibili/user-opus -- --mid 2 --count 10"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com",
    "t.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "user",
    "opus"
  ]
}
|#

(defun main (args)
  (open "https://t.bilibili.com")
  (js-call args
    " const mid = args.mid || '';
      if (!mid) {
        return {
          error: 'Missing argument: mid',
        };
      }

      const count = Math.min(Math.max(parseInt(args.count, 10) || 20, 1), 50);
      const params = new URLSearchParams({
        host_mid: String(mid),
      });
      const source =
        'https://api.bilibili.com/x/polymer/web-dynamic/v1/space?' +
        params.toString();
      const resp = await fetch(source, {credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: 'User not found or unavailable',
          source,
        };
      }

      const data = await resp.json();
      if (data.code !== 0) {
        return {
          error: data.message || 'API error ' + data.code,
          hint: 'User not found or unavailable',
          source,
        };
      }

      const toText = (dynamic) => {
        if (Array.isArray(dynamic.desc?.rich_text_nodes)) {
          return dynamic.desc.rich_text_nodes
            .map((node) => node.text || node.orig_text || '')
            .join('')
            .trim();
        }
        if (typeof dynamic.desc?.text === 'string') {
          return dynamic.desc.text;
        }
        return '';
      };

      const items = (data.data?.items || []).slice(0, count).map((item, index) => {
        const author = item.modules?.module_author || {};
        const dynamic = item.modules?.module_dynamic || {};
        const major = dynamic.major || {};
        const opus = major.opus || {};
        const archive = major.archive || {};
        const article = major.article || {};

        return {
          rank: index + 1,
          id: item.id_str || '',
          type: item.type || '',
          title: opus.title || archive.title || article.title || '',
          text: toText(dynamic),
          author: author.name || '',
          author_mid: author.mid || 0,
          pub_date: author.pub_ts
            ? new Date(author.pub_ts * 1000).toISOString()
            : null,
          cover:
            opus.pics?.[0]?.url ||
            article.covers?.[0] ||
            archive.cover ||
            '',
          images: (opus.pics || []).map((pic) => pic.url || ''),
          url:
            opus.jump_url ||
            article.jump_url ||
            (archive.bvid
              ? 'https://www.bilibili.com/video/' + archive.bvid
              : item.id_str
                ? 'https://t.bilibili.com/' + item.id_str
                : ''),
        };
      });

      return {
        source,
        mid,
        name: data.data?.user?.name || '',
        face: data.data?.user?.face || '',
        count: items.length,
        has_more: !!data.data?.has_more,
        offset: data.data?.offset || null,
        items,
      };
    "))

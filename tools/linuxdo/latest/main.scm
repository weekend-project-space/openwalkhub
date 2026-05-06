#| @meta
{
  "name": "linuxdo/latest",
  "description": "获取 Linux.do 最新主题并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 30,
      "description": "返回结果数量，默认 30，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, source, topics[] }"
  },
  "examples": [
    "openwalk exec linuxdo/latest",
    "openwalk exec linuxdo/latest -- 20"
  ],
  "domains": [
    "linux.do"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "linuxdo",
    "latest",
    "topics"
  ]
}
|#

(define (main args)
  (define count-text
    (if (null? args)
        "30"
        (car args)))
  (define source "https://linux.do/latest.json")
  (open source)
  (js-wait
    "(() => {
      const raw = (
        document.body?.innerText ||
        document.documentElement?.innerText ||
        ''
      ).trim();
      return raw.length > 0;
    })()")
  (js-eval
    (string-append
      "(() => {
        const source = 'https://linux.do/latest.json';
        const limit = Math.min(50, Math.max(1, Number("
      count-text
      ") || 30));
        const raw = (
          document.body?.innerText ||
          document.documentElement?.innerText ||
          ''
        ).trim();

        try {
          const data = JSON.parse(raw);
          const topics = (data.topic_list?.topics || [])
            .slice(0, limit)
            .map((topic, index) => ({
              rank: index + 1,
              id: topic.id,
              title: topic.title || '',
              slug: topic.slug || '',
              url: topic.slug
                ? `https://linux.do/t/${topic.slug}/${topic.id}`
                : `https://linux.do/t/topic/${topic.id}`,
              posts_count: topic.posts_count || 0,
              reply_count: Math.max((topic.posts_count || 1) - 1, 0),
              views: topic.views || 0,
              like_count: topic.like_count || 0,
              created_at: topic.created_at || '',
              bumped_at: topic.bumped_at || '',
              last_posted_at: topic.last_posted_at || '',
              pinned: !!topic.pinned,
              pinned_globally: !!topic.pinned_globally,
              visible: topic.visible !== false,
              excerpt: topic.excerpt || '',
              category_id: topic.category_id || 0,
              tags: topic.tags || [],
            }));

          return {
            count: topics.length,
            source,
            topics,
          };
        } catch (error) {
          return {
            error: 'Unexpected response',
            hint: 'Open https://linux.do first, ensure you can access the site, then retry.',
            source,
            preview: raw.slice(0, 200),
          };
        }
      })()")))


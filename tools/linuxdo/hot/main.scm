#| @meta
{
  "name": "linuxdo/hot",
  "description": "获取 Linux.do 热门主题并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 30,
      "description": "返回结果数量，默认 30，最大 50"
    },
    {
      "name": "period",
      "type": "string",
      "required": false,
      "default": "daily",
      "description": "榜单周期：daily、weekly、monthly、quarterly、yearly、all"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, period, source, topics[] }"
  },
  "examples": [
    "openwalk exec linuxdo/hot",
    "openwalk exec linuxdo/hot -- 20 weekly"
  ],
  "domains": [
    "linux.do"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "linuxdo",
    "hot",
    "topics"
  ]
}
|#

(define (main args)
  (define arg1 (if (null? args) #f (car args)))
  (define arg2 (if (or (null? args) (null? (cdr args))) #f (cadr args)))
  (define count-text
    (cond
      ((and arg1 (string->number arg1)) arg1)
      (else "30")))
  (define period
    (let ((candidate
            (cond
              ((and arg1 (not (string->number arg1))) arg1)
              (arg2 arg2)
              (else "daily"))))
      (if (member candidate '("daily" "weekly" "monthly" "quarterly" "yearly" "all"))
          candidate
          "daily")))
  (define primary-source
    (string-append "https://linux.do/top.json?period=" period))
  (define fallback-source "https://linux.do/latest.json")
  (open primary-source)
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
        const period = '"
      period
      "';
        const primarySource = '"
      primary-source
      "';
        const fallbackSource = 'https://linux.do/latest.json';
        const limit = Math.min(50, Math.max(1, Number("
      count-text
      ") || 30));

        const readJson = () => {
          const raw = (
            document.body?.innerText ||
            document.documentElement?.innerText ||
            ''
          ).trim();
          return {
            raw,
            data: JSON.parse(raw),
          };
        };

        const toResult = (data, source) => {
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
            period,
            source,
            topics,
          };
        };

        try {
          const { data } = readJson();
          if (data?.topic_list?.topics) {
            return toResult(data, primarySource);
          }
        } catch (error) {
        }

        try {
          const xhr = new XMLHttpRequest();
          xhr.open('GET', fallbackSource, false);
          xhr.setRequestHeader('accept', 'application/json, text/plain, */*');
          xhr.setRequestHeader('x-requested-with', 'XMLHttpRequest');
          xhr.send(null);

          if (xhr.status >= 200 && xhr.status < 300) {
            const fallbackData = JSON.parse(xhr.responseText || '{}');
            return toResult(fallbackData, fallbackSource);
          }

          return {
            error: `HTTP ${xhr.status || 403}`,
            hint: 'Open https://linux.do in your browser first, ensure you are logged in if required, then retry.',
          };
        } catch (error) {
          return {
            error: 'Unexpected response',
            hint: 'Open https://linux.do in your browser first, ensure you are logged in if required, then retry.',
          };
        }
      })()")))

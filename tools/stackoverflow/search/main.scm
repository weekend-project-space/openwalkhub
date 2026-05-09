#| @meta
{
  "name": "stackoverflow/search",
  "description": "搜索 Stack Overflow 问题并返回结构化结果",
  "args": [
    {
      "name": "query",
      "type": "string",
      "required": true,
      "description": "搜索关键词"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 10,
      "description": "返回结果数量，默认 10，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, count, has_more, quota_remaining, questions[] }"
  },
  "examples": [
    "openwalk exec stackoverflow/search -- \"python async await\""
  ],
  "domains": [
    "stackoverflow.com",
    "api.stackexchange.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "stackoverflow",
    "search",
    "questions"
  ]
}
|#

(defun main (args)
  (open "https://stackoverflow.com")
  (js-call args
    " const query = args.query;
      if (!query) {
        return {
          error: 'Missing argument: query',
          hint: 'Provide a search query string',
        };
      }

      const count = Math.min(parseInt(args.count, 10) || 10, 50);
      const source =
        'https://api.stackexchange.com/2.3/search?order=desc&sort=relevance&intitle=' +
        encodeURIComponent(query) +
        '&site=stackoverflow&pagesize=' +
        count;

      const resp = await fetch(source);
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          source,
        };
      }

      const data = await resp.json();
      if (data.error_id) {
        return {
          error: data.error_name || 'API error',
          message: data.error_message || '',
          source,
        };
      }

      const items = data.items || [];
      return {
        source,
        query,
        count: items.length,
        has_more: !!data.has_more,
        quota_remaining: data.quota_remaining || 0,
        questions: items.map((question) => ({
          id: question.question_id || 0,
          title: question.title || '',
          url: question.link || '',
          score: question.score || 0,
          answers: question.answer_count || 0,
          views: question.view_count || 0,
          tags: question.tags || [],
          author: question.owner?.display_name || '',
          is_answered: !!question.is_answered,
          created: question.creation_date || 0,
          last_activity: question.last_activity_date || 0,
        })),
      };
    "))

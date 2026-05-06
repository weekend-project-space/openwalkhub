#| @meta
{
  "name": "zhihu/question",
  "description": "获取知乎问题详情和回答列表并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": true,
      "description": "知乎问题 ID"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 5,
      "description": "返回回答数量，默认 5，最大 20"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ id, title, url, detail, excerpt, answer_count, follower_count, visit_count, comment_count, topics[], answers[] }"
  },
  "examples": [
    "openwalk exec zhihu/question -- 34816524",
    "openwalk exec zhihu/question -- 34816524 10"
  ],
  "domains": [
    "www.zhihu.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "zhihu",
    "question",
    "answers"
  ]
}
|#

(define (main args)
  (if (null? args)
      (list
        (cons "error" "Missing argument: id")
        (cons "hint" "Provide a Zhihu question ID"))
      (let ((question-id (car args))
            (count-text
              (if (or (null? args) (null? (cdr args)))
                  "5"
                  (cadr args))))
        (open
          (string-append
            "https://www.zhihu.com/api/v4/questions/"
            question-id
            "?include=data[*].detail,excerpt,answer_count,follower_count,visit_count,comment_count,topics"))
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
          "(() => {
            const raw = (
              document.body?.innerText ||
              document.documentElement?.innerText ||
              ''
            ).trim();

            try {
              const data = JSON.parse(raw);
              localStorage.setItem('openwalk-zhihu-question', JSON.stringify(data));
              return { ok: true };
            } catch (error) {
              return {
                error: 'Unexpected response',
                hint: 'Open https://www.zhihu.com first, ensure you can access the API, then retry.',
                preview: raw.slice(0, 200),
              };
            }
          })()")
        (page-goto
          (string-append
            "https://www.zhihu.com/api/v4/questions/"
            question-id
            "/answers?limit="
            count-text
            "&offset=0&sort_by=default&include=data[*].content,voteup_count,comment_count,author"))
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
              const raw = (
                document.body?.innerText ||
                document.documentElement?.innerText ||
                ''
              ).trim();

              try {
                const question = JSON.parse(
                  localStorage.getItem('openwalk-zhihu-question') || 'null'
                );
                const answerData = JSON.parse(raw);
                const strip = (html) => (
                  html || ''
                )
                  .replace(/<[^>]+>/g, '')
                  .replace(/&nbsp;/g, ' ')
                  .replace(/&lt;/g, '<')
                  .replace(/&gt;/g, '>')
                  .replace(/&amp;/g, '&')
                  .trim();

                if (!question) {
                  return {
                    error: 'Question not found',
                  };
                }

                const answers = (answerData.data || []).map((answer, index) => ({
                  rank: index + 1,
                  id: answer.id,
                  author: answer.author?.name || 'anonymous',
                  author_headline: answer.author?.headline || '',
                  voteup_count: answer.voteup_count || 0,
                  comment_count: answer.comment_count || 0,
                  content: strip(answer.content || '').slice(0, 800),
                  created_time: answer.created_time || 0,
                  updated_time: answer.updated_time || 0,
                }));

                return {
                  id: question.id,
                  title: question.title || '',
                  url: question.id
                    ? `https://www.zhihu.com/question/${question.id}`
                    : '',
                  detail: strip(question.detail || ''),
                  excerpt: question.excerpt || '',
                  answer_count: question.answer_count || 0,
                  follower_count: question.follower_count || 0,
                  visit_count: question.visit_count || 0,
                  comment_count: question.comment_count || 0,
                  topics: (question.topics || []).map((topic) => topic.name || ''),
                  answers_total: answerData.paging?.totals || answers.length,
                  answers,
                };
              } catch (error) {
                return {
                  error: 'Unexpected response',
                  hint: 'Open https://www.zhihu.com first, ensure you can access the API, then retry.',
                  preview: raw.slice(0, 200),
                };
              }
            })()")))))

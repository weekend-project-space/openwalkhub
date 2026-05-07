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

(defun main (args)
  (let* ((params (parse-args args))
         (question-id (alist-get params "id")))
    (if (not (string->number question-id))
        (list
          (cons "error" "Invalid argument: id")
          (cons "hint" "Provide a numeric Zhihu question ID"))
        (begin
          (open "https://www.zhihu.com")
          (js-eval
            (string-append
              "(async () => {
                const params = "
              (args->js-object args)
              ";
                const questionId = params.id;
                const limit = Math.min(20, Math.max(1, Number(params.count) || 5));
                const questionSource =
                  'https://www.zhihu.com/api/v4/questions/' +
                  encodeURIComponent(questionId) +
                  '?include=data[*].detail,excerpt,answer_count,follower_count,visit_count,comment_count,topics';
                const answersSource =
                  'https://www.zhihu.com/api/v4/questions/' +
                  encodeURIComponent(questionId) +
                  '/answers?limit=' +
                  limit +
                  '&offset=0&sort_by=default&include=data[*].content,voteup_count,comment_count,author';

                try {
                  const [questionResp, answersResp] = await Promise.all([
                    fetch(questionSource),
                    fetch(answersSource),
                  ]);

                  if (!questionResp.ok) {
                    return {
                      error: 'HTTP ' + questionResp.status,
                      hint: 'Open https://www.zhihu.com first, ensure you can access the API, then retry.',
                      source: questionSource,
                    };
                  }

                  if (!answersResp.ok) {
                    return {
                      error: 'HTTP ' + answersResp.status,
                      hint: 'Open https://www.zhihu.com first, ensure you can access the API, then retry.',
                      source: answersSource,
                    };
                  }

                  const [question, answerData] = await Promise.all([
                    questionResp.json(),
                    answersResp.json(),
                  ]);
                  const strip = (html) => (
                    html || ''
                  )
                    .replace(/<[^>]+>/g, '')
                    .replace(/&nbsp;/g, ' ')
                    .replace(/&lt;/g, '<')
                    .replace(/&gt;/g, '>')
                    .replace(/&amp;/g, '&')
                    .trim();

                  if (!question || question.error) {
                    return {
                      error: 'Question not found',
                      id: questionId,
                      question_source: questionSource,
                      answers_source: answersSource,
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
                    question_source: questionSource,
                    answers_source: answersSource,
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
                    detail: String(error),
                    question_source: questionSource,
                    answers_source: answersSource,
                  };
                }
              })()"))))))

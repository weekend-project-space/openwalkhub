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
  (open "https://www.zhihu.com")
  (js-file-call "main.js" args))

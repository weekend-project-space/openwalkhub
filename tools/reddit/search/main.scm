#| @meta
{
  "name": "reddit/search",
  "description": "搜索 Reddit 帖子并返回结构化结果",
  "args": [
    {
      "name": "query",
      "type": "string",
      "required": true,
      "description": "搜索关键词"
    },
    {
      "name": "subreddit",
      "type": "string",
      "required": false,
      "description": "限定 subreddit，不带 r/ 前缀"
    },
    {
      "name": "sort",
      "type": "string",
      "required": false,
      "default": "relevance",
      "description": "排序：relevance、hot、top、new、comments"
    },
    {
      "name": "time",
      "type": "string",
      "required": false,
      "default": "all",
      "description": "时间范围：all、hour、day、week、month、year"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 25,
      "description": "返回帖子数量，默认 25，最大 100"
    },
    {
      "name": "after",
      "type": "string",
      "required": false,
      "description": "分页用的 fullname 游标"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, subreddit, sort, time, count, after, posts[] }"
  },
  "examples": [
    "openwalk exec reddit/search -- \"claude code\"",
    "openwalk exec reddit/search -- AI 20",
    "openwalk exec reddit/search -- \"claude code\" --sort top --time week"
  ],
  "domains": [
    "www.reddit.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "reddit",
    "search"
  ]
}
|#

(defun main (args)
  (open "https://www.reddit.com")
  (js-file-call "main.js" args))

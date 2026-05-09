#| @meta
{
  "name": "douban/movie-top250",
  "description": "获取豆瓣电影 Top 250 并返回结构化结果",
  "args": [
    {
      "name": "page",
      "type": "number",
      "required": false,
      "default": 1,
      "description": "页码，默认 1，每页 25 条"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ page, count, items[] }"
  },
  "examples": [
    "openwalk exec douban/movie-top250",
    "openwalk exec douban/movie-top250 -- 2"
  ],
  "domains": [
    "movie.douban.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "douban",
    "movie",
    "top250"
  ]
}
|#

(defun main (args)
  (open "https://movie.douban.com")
  (js-run "main.js" args))

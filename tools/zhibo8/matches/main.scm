#| @meta
{
  "name": "zhibo8/matches",
  "description": "打开 zhibo8 首页，自动滚动加载赛程，并提取日期、时间、对阵的结构化 JSON",
  "args": [],
  "returns": {
    "type": "object",
    "description": "{ source, count, matches[] }"
  },
  "examples": [
    "openwalk exec zhibo8/matches"
  ],
  "domains": [
    "www.zhibo8.com",
    "zhibo8.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "zhibo8",
    "matches",
    "json"
  ]
}
|#

(defun main (args)
  (open "https://www.zhibo8.com")
  (js-run "main.js" args))

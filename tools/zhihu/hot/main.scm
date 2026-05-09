#| @meta
{
  "name": "zhihu/hot",
  "description": "获取知乎热榜并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回结果数量，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ count, items[] }"
  },
  "examples": [
    "openwalk exec zhihu/hot",
    "openwalk exec zhihu/hot -- 10"
  ],
  "domains": [
    "www.zhihu.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "zhihu",
    "hot",
    "questions"
  ]
}
|#

(defun main (args)
  (open "https://www.zhihu.com")
  (js-file-call "main.js" args))

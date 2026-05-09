#| @meta
{
  "name": "producthunt/today",
  "description": "获取 Product Hunt 今日产品并返回结构化结果",
  "args": [
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回产品数量，默认 20，最大 50"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ source, count, products[] }"
  },
  "examples": [
    "openwalk exec producthunt/today"
  ],
  "domains": [
    "www.producthunt.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "producthunt",
    "today",
    "products"
  ]
}
|#

(defun main (args)
  (open "https://www.producthunt.com")
  (js-run "main.js" args))

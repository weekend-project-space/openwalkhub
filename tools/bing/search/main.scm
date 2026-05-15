#| @meta
{
  "name": "bing/search",
  "description": "Bing 搜索并返回结构化结果",
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
      "description": "返回结果数量，默认 10"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ query, count, results[] }"
  },
  "examples": [
    "openwalk exec bing/search -- \"Claude Code\" 10"
  ],
  "domains": [
    "www.bing.com",
    "cn.bing.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "search",
    "bing"
  ]
}
|#

(defun main (args)
  (let* ((params (parse-args args))
         (query (alist-get params "query")))
    (open "https://cb.bing.com")
    (js-wait "(() => !!document.querySelector('#sb_form_q'))()")
    (element-fill "#sb_form_q" query)
    (keyboard-press "Enter")
    (page-wait-navigation)
    (js-wait "(() => !!document.querySelector('#b_results'))()")
    (js-run "main.js" args)))

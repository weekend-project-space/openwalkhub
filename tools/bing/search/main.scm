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
    (open "https://www.bing.com")
    (js-wait "(() => !!document.querySelector('#sb_form_q'))()")
    (element-fill "#sb_form_q" query)
    (keyboard-press "Enter")
    (page-wait-navigation)
    (js-wait "(() => !!document.querySelector('#b_results'))()")
    (js-eval
      (string-append
        "(() => {
          const params = "
        (args->js-object args)
        ";
          const limit = Math.max(1, Number(params.count) || 10);
          const query = document.querySelector('#sb_form_q')?.value?.trim() || '';
          const results = Array.from(document.querySelectorAll('#b_results li.b_algo'))
            .map((item, index) => {
              const anchor = item.querySelector('h2 > a');
              if (!anchor) {
                return null;
              }

              const title = (anchor.innerText || anchor.textContent || '').trim();
              if (!title) {
                return null;
              }

              const snippetNode = item.querySelector('.b_caption p, p');
              const snippet = snippetNode
                ? (snippetNode.innerText || snippetNode.textContent || '').trim()
                : '';

              return {
                index: index + 1,
                title,
                url: anchor.href || '',
                snippet,
              };
            })
            .filter(Boolean)
            .slice(0, limit);

          return {
            query,
            count: results.length,
            results,
          };
        })()"))))

#| @meta
{
  "name": "debug/open",
  "description": "打开页面并输出浏览器状态，将 snapshot 和 console 写入文件",
  "args": [
    {
      "name": "url",
      "type": "string",
      "description": "要打开的页面 URL",
      "required": false
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ openTabs, page, snapshotFile, consoleFile }"
  },
  "domains":[],
  "examples": [
    "openwalk exec debug/open https://www.baidu.com/"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": ["debug", "snapshot", "console"]
}
|#

(defun %wait-page-ready (retries)
  (if (<= retries 0)
      #f
      (with-exception-handler
        (lambda (ex)
          (time-sleep 1000)
          (%wait-page-ready (- retries 1)))
        (lambda ()
          (js-wait "document.readyState === 'complete'")
          (js-wait
            "(() => {
              const body = document.body;
              if (!body) return false;

              const text = (body.innerText || '').replace(/\\s+/g, ' ').trim();
              const hasMeaningfulText = text.length > 0;
              const hasRenderableBody = body.childElementCount > 0;

              return hasRenderableBody && hasMeaningfulText;
            })()")
          #t))))

(defun main (args)
  (define url (if (null? args) "https://www.bing.com/" (car args)))

  ;; 1. 打开页面
  (open url)

  ;; 2. 等待页面加载完成
  (%wait-page-ready 5)

  ;; 3. 获取 tabs
  (define tabs (tab-list))

  ;; 4. 获取 page 信息
  (define page
    (js-eval
      "(() => ({
        url: location.href,
        title: document.title
      }))()"))

  ;; 5. 获取 snapshot 和 console
  (define snapshot (openwalk-output-format(page-snapshot)))
  (define logs (console))

  ;; 6. 生成时间戳（安全文件名）
  (define ts
    (js-eval "new Date().toISOString().replace(/[:.]/g,'-')"))

  (define snapshot-path (string-append ".openwalk/snapshot-" ts ".yaml"))
  (define console-path (string-append ".openwalk/console-" ts ".log"))

  ;; 7. 写 snapshot 文件（结构数据）
  (define sp (open-output-file snapshot-path))
  (write snapshot sp)
  (close-output-port sp)

  ;; 8. 写 console 文件（文本日志）
  (define cp (open-output-file console-path))
  (for-each
    (lambda (line)
      (write-string line cp)
      (newline cp))
    logs)
  (close-output-port cp)

  ;; 9. 返回 Scheme dict
  (list
    (cons "openTabs" tabs)
    (cons "page" page)
    (cons "snapshotFile" snapshot-path)
    (cons "consoleFile" console-path))
)

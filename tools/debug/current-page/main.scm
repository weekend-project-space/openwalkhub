#| @meta
{
  "name": "debug/current-page",
  "description": "输出当前页面状态，将 snapshot 和 console 写入文件",
  "args": [],
  "returns": {
    "type": "object",
    "description": "{ openTabs, page, snapshotFile, consoleFile }"
  },
  "domains": [],
  "examples": [
    "openwalk exec debug/current-page"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": ["debug", "snapshot", "console"]
}
|#

(defun %wait-page-ready ()
  (js-wait "document.readyState === 'complete'")
  (js-wait
    "(() => {
      const body = document.body;
      if (!body) return false;

      const text = (body.innerText || '').replace(/\\s+/g, ' ').trim();
      const hasMeaningfulText = text.length > 0;
      const hasRenderableBody = body.childElementCount > 0;

      return hasRenderableBody && hasMeaningfulText;
    })()"))

(defun main (args)
  (%wait-page-ready)

  (define tabs (tab-list))
  (define page
    (js-eval
      "(() => ({
        url: location.href,
        title: document.title
      }))()"))
  (define snapshot (openwalk-output-format(page-snapshot)))
  (define logs (console))
  (define ts
    (js-eval "new Date().toISOString().replace(/[:.]/g,'-')"))
  (define snapshot-path (string-append ".openwalk/snapshot-" ts ".yaml"))
  (define console-path (string-append ".openwalk/console-" ts ".log"))

  (define sp (open-output-file snapshot-path))
  (write snapshot sp)
  (close-output-port sp)

  (define cp (open-output-file console-path))
  (for-each
    (lambda (line)
      (write-string line cp)
      (newline cp))
    logs)
  (close-output-port cp)

  (list
    (cons "openTabs" tabs)
    (cons "page" page)
    (cons "snapshotFile" snapshot-path)
    (cons "consoleFile" console-path)))

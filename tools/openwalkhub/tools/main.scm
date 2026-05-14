#| @meta
{
  "name": "openwalkhub/tools",
  "description": "返回hub可用的 OpenWalk 工具目录，直接给出精简命令清单，适合 AI 快速发现能力",
  "args": [],
  "returns": {
    "type": "string",
    "description": "每行一个工具：命令签名 + 一句话说明"
  },
  "examples": [
    "openwalk exec openwalkhub/tools"
  ],
  "domains": [],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "openwalk",
    "tools",
    "manifest"
  ]
}
|#
(defun read-lines (path)
  (call-with-input-file path
    (lambda (port)
      (let loop ((result '()))
        (let ((line (read-line port)))
          (if (eof-object? line)
              (reverse result)
              (loop (cons line result))))))))

(defun main (args)
  (read-lines
    (string-append (script-dir) "/manifest.txt")))
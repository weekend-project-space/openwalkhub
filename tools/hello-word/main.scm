#| @meta
{
  "name": "hello-word",
  "description": "返回一个简单的问候语，适合验证 Scheme tool 是否工作正常",
  "args": [
    {
      "name": "name",
      "type": "string",
      "required": false,
      "default": "world",
      "description": "可选的人名或目标词，默认 world"
    }
  ],
  "returns": {
    "type": "string",
    "description": "hello <name> 格式的问候语"
  },
  "examples": [
    "openwalk exec hello-word",
    "openwalk exec hello-word -- OpenWalk"
  ],
  "domains": [],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "hello",
    "demo",
    "smoke-test"
  ]
}
|#

(define (main args)
  (define target
    (if (null? args)
        "world"
        (car args)))
  (string-append "hello " target))


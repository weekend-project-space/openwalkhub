#| @meta
{
  "name": "linuxdo/topic",
  "description": "获取 Linux.do 主题详情和帖子列表并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": true,
      "description": "Linux.do topic ID"
    },
    {
      "name": "posts",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "返回帖子数量，默认 20，最大 100"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ source, topic, post_count, posts[] }"
  },
  "examples": [
    "openwalk exec linuxdo/topic -- 1812710",
    "openwalk exec linuxdo/topic -- 1812710 10"
  ],
  "domains": [
    "linux.do"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "linuxdo",
    "topic",
    "posts"
  ]
}
|#

(defun main (args)
  (open "https://linux.do")
  (js-file-call "main.js" args))

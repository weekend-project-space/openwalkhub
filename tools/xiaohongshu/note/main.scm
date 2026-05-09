#| @meta
{
  "name": "xiaohongshu/note",
  "description": "获取小红书笔记页面中的结构化信息",
  "args": [
    {
      "name": "url",
      "type": "string",
      "required": true,
      "description": "小红书笔记 URL"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ note_id, title, author, content, images[], tags[], url }"
  },
  "examples": [
    "openwalk exec xiaohongshu/note -- https://www.xiaohongshu.com/explore/6607bf2f000000001d0322ab"
  ],
  "domains": [
    "www.xiaohongshu.com",
    "xiaohongshu.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "xiaohongshu",
    "note",
    "content"
  ]
}
|#

(defun main (args)
  (open "https://www.xiaohongshu.com")
  (js-run "main.js" args))

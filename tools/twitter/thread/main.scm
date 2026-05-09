#| @meta
{
  "name": "twitter/thread",
  "description": "获取推文对话线程并返回结构化结果",
  "args": [
    {
      "name": "tweet_id",
      "type": "string",
      "required": true,
      "description": "Tweet ID，或完整 URL"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ tweet_id, count, tweets[] }"
  },
  "examples": [
    "openwalk exec twitter/thread -- 2032478407146311850"
  ],
  "domains": [
    "x.com"
  ],
  "readOnly": true,
  "requiresLogin": true,
  "tags": [
    "twitter",
    "thread",
    "replies"
  ]
}
|#

(defun main (args)
  (open "https://x.com")
  (js-run "main.js" args))

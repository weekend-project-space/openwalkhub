#| @meta
{
  "name": "reddit/context",
  "description": "获取 Reddit 评论的 ancestor chain 并返回结构化结果",
  "args": [
    {
      "name": "url",
      "type": "string",
      "required": true,
      "description": "Reddit comment URL"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ post, target_comment, ancestor_chain[] }"
  },
  "examples": [
    "openwalk exec reddit/context -- https://www.reddit.com/r/LocalLLaMA/comments/1rso48p/comment/oa8domi/"
  ],
  "domains": [
    "www.reddit.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "reddit",
    "context",
    "comments"
  ]
}
|#

(defun main (args)
  (open "https://www.reddit.com")
  (js-call args
    " const inputUrl = args.url || '';
      if (!inputUrl) {
        return {
          error: 'Missing argument: url',
          hint: 'Provide a Reddit comment URL',
        };
      }

      const path = inputUrl
        .replace(/https?:\\/\\/[^/]*/, '')
        .replace(/\\?.*/, '')
        .replace(/\\/*$/, '/');

      let commentId = (path.match(/\\/comment\\/([^/]+)/) || [])[1];
      if (!commentId) {
        const parts = path.match(/\\/comments\\/[^/]*\\/[^/]*\\/([^/]*)/);
        commentId = parts ? parts[1] : null;
      }
      if (!commentId) {
        return {
          error: 'Cannot extract comment_id from URL',
          hint: 'Expected: .../comment/<id>/',
        };
      }

      const postMatch = path.match(/(\\/r\\/[^/]+\\/comments\\/[^/]+\\/)/);
      if (!postMatch) {
        return {
          error: 'Cannot extract post path from URL',
          hint: 'Expected: /r/sub/comments/POST_ID/...',
        };
      }

      const apiPath = postMatch[1] + commentId + '/';
      const source =
        'https://www.reddit.com' +
        apiPath +
        '.json?context=10&raw_json=1';

      const resp = await fetch(source, {credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          source,
        };
      }

      const data = await resp.json();
      if (!data?.[0]?.data?.children?.[0]?.data) {
        return {
          error: 'Unexpected response',
          hint: 'Post may be deleted or URL is incorrect',
          source,
        };
      }

      const post = data[0].data.children[0].data;
      const flatten = (children, depth) => {
        let result = [];
        for (const child of children || []) {
          if (child.kind !== 't1') continue;
          const comment = child.data || {};
          result.push({
            id: comment.name || '',
            parent_id: comment.parent_id || '',
            author: comment.author || '',
            score: comment.score || 0,
            body: comment.body || '',
            depth,
          });

          if (comment.replies?.data?.children) {
            result = result.concat(flatten(comment.replies.data.children, depth + 1));
          }
        }
        return result;
      };

      const comments = flatten(data?.[1]?.data?.children || [], 0);
      const target = comments.find((comment) => comment.id === 't1_' + commentId);
      if (!target) {
        return {
          error: 'Comment t1_' + commentId + ' not found',
          hint: 'Comment may be deleted or URL is incorrect',
          source,
        };
      }

      let chain = [];
      let current = target;
      while (current) {
        chain.unshift(current);
        current = comments.find((comment) => comment.id === current.parent_id);
      }

      return {
        source,
        post: {
          id: post.name || '',
          title: post.title || '',
          author: post.author || '',
          url: post.permalink
            ? `https://www.reddit.com${post.permalink}`
            : '',
        },
        target_comment: target,
        ancestor_chain: chain,
      };
    "))

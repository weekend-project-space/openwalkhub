#| @meta
{
  "name": "reddit/thread",
  "description": "获取 Reddit 帖子详情和评论列表并返回结构化结果",
  "args": [
    {
      "name": "url",
      "type": "string",
      "required": true,
      "description": "Reddit 帖子 URL"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ post, comments_total, comments[] }"
  },
  "examples": [
    "openwalk exec reddit/thread -- https://www.reddit.com/r/LocalLLaMA/comments/1rrisqn/example/"
  ],
  "domains": [
    "www.reddit.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "reddit",
    "thread",
    "comments"
  ]
}
|#

(defun main (args)
  (open "https://www.reddit.com")
  (js-call args
    " const postUrl = args.url || '';
      if (!postUrl) {
        return {
          error: 'Empty argument: url',
          hint: 'Provide a non-empty Reddit post URL',
        };
      }

      const source = postUrl.endsWith('/')
        ? postUrl + '.json?limit=500&depth=10&raw_json=1'
        : postUrl + '/.json?limit=500&depth=10&raw_json=1';

      try {
        const resp = await fetch(source);
        if (!resp.ok) {
          return {
            error: 'HTTP ' + resp.status,
            hint: 'Open https://www.reddit.com first, ensure you can access the JSON endpoint, then retry.',
            source,
          };
        }

        const data = await resp.json();
        const post = data?.[0]?.data?.children?.[0]?.data;
        if (!post) {
          return {
            error: 'Unexpected response',
            hint: 'Post may be deleted or URL may be incorrect.',
            source,
          };
        }

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
              result = result.concat(
                flatten(comment.replies.data.children, depth + 1)
              );
            }
          }
          return result;
        };

        const comments = flatten(data?.[1]?.data?.children || [], 0);

        return {
          source,
          post: {
            id: post.name || '',
            title: post.title || '',
            author: post.author || '',
            subreddit: post.subreddit_name_prefixed || '',
            score: post.score || 0,
            num_comments: post.num_comments || 0,
            selftext: post.selftext || '',
            url: post.url || '',
            permalink: post.permalink
              ? `https://www.reddit.com${post.permalink}`
              : '',
            created_utc: post.created_utc || 0,
          },
          comments_total: comments.length,
          comments,
        };
      } catch (error) {
        return {
          error: 'Unexpected response',
          hint: 'Open https://www.reddit.com first, ensure you can access the JSON endpoint, then retry.',
          detail: String(error),
          source,
        };
      }
    "))

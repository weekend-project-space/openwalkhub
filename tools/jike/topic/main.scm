#| @meta
{
  "name": "jike/topic",
  "description": "获取 JIKE 主题详情和回复并返回结构化结果",
  "args": [
    {
      "name": "id",
      "type": "string",
      "required": true,
      "description": "主题 tid 或 slug"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ id, title, category, author, posts, view_count, comments[] }"
  },
  "examples": [
    "openwalk exec jike/topic -- 35558",
    "openwalk exec jike/topic -- 35558/deeplx-免费-api-每天-50万字符配额"
  ],
  "domains": [
    "jike.info"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "jike",
    "topic",
    "comments"
  ]
}
|#

(defun main (args)
  (open "https://jike.info")
  (js-call args
    " const input = args.id || '';
      if (!input) {
        return {
          error: 'Missing argument: id',
        };
      }

      const cleaned = input
        .replace(/^https?:\\/\\/jike\\.info\\//, '')
        .replace(/^topic\\//, '')
        .replace(/^\\/+|\\/+$/g, '');
      const source = 'https://jike.info/api/topic/' + cleaned;
      const resp = await fetch(source, {credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: resp.status === 404 ? 'Topic not found' : 'API error',
          source,
        };
      }

      const data = await resp.json();
      const posts = data.posts || [];
      const topicId = data.tid || parseInt(cleaned.split('/')[0], 10) || 0;

      const comments = posts.map((post, index) => ({
        index: index + 1,
        pid: post.pid || 0,
        author: post.user?.username || post.username || '',
        author_uid: post.user?.uid || post.uid || 0,
        content: post.content || post.raw || '',
        timestamp: post.timestamp || 0,
        created_at: post.timestampISO || null,
        edited_at: post.editedISO || null,
        votes: post.votes || post.upvotes || 0,
        replies: post.replies || 0,
      }));

      return {
        source,
        id: topicId,
        slug: data.slug || '',
        title: data.title || '',
        url: data.slug
          ? 'https://jike.info/topic/' + data.slug
          : topicId
            ? 'https://jike.info/topic/' + topicId
            : '',
        category: data.category?.name || '',
        category_slug: data.category?.slug || '',
        tags: (data.tags || []).map((tag) =>
          typeof tag === 'string' ? tag : tag.value || tag.name || ''
        ),
        author: comments[0]?.author || '',
        author_uid: comments[0]?.author_uid || 0,
        post_count: data.postcount || posts.length,
        view_count: data.viewcount || 0,
        created_at: data.timestampISO || comments[0]?.created_at || null,
        main_post: comments[0] || null,
        comment_count: Math.max(comments.length - 1, 0),
        comments,
      };
    "))

#| @meta
{
  "name": "bilibili/comments",
  "description": "获取 Bilibili 视频评论并返回结构化结果",
  "args": [
    {
      "name": "bvid",
      "type": "string",
      "required": true,
      "description": "视频 BV ID"
    },
    {
      "name": "page",
      "type": "number",
      "required": false,
      "default": 1,
      "description": "页码，默认 1"
    },
    {
      "name": "count",
      "type": "number",
      "required": false,
      "default": 20,
      "description": "每页评论数量，默认 20，最大 30"
    },
    {
      "name": "sort",
      "type": "number",
      "required": false,
      "default": 2,
      "description": "排序：0=时间，2=热度"
    }
  ],
  "returns": {
    "type": "object",
    "description": "{ bvid, aid, title, page, total, count, top_comments, comments[] }"
  },
  "examples": [
    "openwalk exec bilibili/comments -- BV1LGwHzrE4A"
  ],
  "domains": [
    "www.bilibili.com",
    "api.bilibili.com"
  ],
  "readOnly": true,
  "requiresLogin": false,
  "tags": [
    "bilibili",
    "comments",
    "video"
  ]
}
|#

(defun main (args)
  (open "https://www.bilibili.com")
  (js-call args
    " const bvid = args.bvid || '';
      if (!bvid) {
        return {
          error: 'Missing argument: bvid',
        };
      }

      const pn = parseInt(args.page, 10) || 1;
      const ps = Math.min(parseInt(args.count, 10) || 20, 30);
      const sort = args.sort !== undefined ? parseInt(args.sort, 10) : 2;

      const viewSource =
        'https://api.bilibili.com/x/web-interface/view?bvid=' +
        encodeURIComponent(bvid);
      const viewResp = await fetch(viewSource, {credentials: 'include'});
      if (!viewResp.ok) {
        return {
          error: 'HTTP ' + viewResp.status,
          hint: 'Not logged in?',
          source: viewSource,
        };
      }

      const viewData = await viewResp.json();
      if (viewData.code !== 0) {
        return {
          error: viewData.message || 'Failed to get video info',
          hint: viewData.code === -404 ? 'Video not found' : 'Not logged in?',
          source: viewSource,
        };
      }

      const aid = viewData.data?.aid;
      const source =
        'https://api.bilibili.com/x/v2/reply?type=1&oid=' +
        aid +
        '&pn=' +
        pn +
        '&ps=' +
        ps +
        '&sort=' +
        sort;
      const resp = await fetch(source, {credentials: 'include'});
      if (!resp.ok) {
        return {
          error: 'HTTP ' + resp.status,
          hint: 'Not logged in?',
          source,
        };
      }

      const data = await resp.json();
      if (data.code !== 0) {
        return {
          error: data.message || 'API error ' + data.code,
          hint: 'Not logged in?',
          source,
        };
      }

      const formatReply = (reply) => ({
        rpid: reply.rpid_str || '',
        user: reply.member?.uname || '',
        user_mid: reply.mid || 0,
        user_level: reply.member?.level_info?.current_level || 0,
        content: reply.content?.message || '',
        like: reply.like || 0,
        reply_count: reply.rcount || 0,
        time: reply.ctime ? new Date(reply.ctime * 1000).toISOString() : null,
        sub_replies: (reply.replies || []).slice(0, 3).map((subReply) => ({
          user: subReply.member?.uname || '',
          content: subReply.content?.message || '',
          like: subReply.like || 0,
          time: subReply.ctime
            ? new Date(subReply.ctime * 1000).toISOString()
            : null,
        })),
      });

      const comments = (data.data?.replies || []).map(formatReply);
      let top = null;
      if (pn === 1 && data.data?.top_replies?.length) {
        top = data.data.top_replies.map(formatReply);
      }

      return {
        source,
        bvid,
        aid,
        title: viewData.data?.title || '',
        page: pn,
        total: data.data?.page?.count || 0,
        count: comments.length,
        sort: sort === 0 ? 'by_time' : 'by_likes',
        top_comments: top,
        comments,
      };
    "))

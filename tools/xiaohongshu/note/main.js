async (args) => {
  const inputUrl = args.url || '';
  if (!inputUrl) {
    return {
      error: 'Missing argument: url',
    };
  }

  const source = inputUrl;
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      hint: 'Open the note page first, ensure it is publicly accessible, then retry.',
      source,
    };
  }

  const html = await resp.text();
  const match = html.match(/<script[^>]*>window\.__INITIAL_STATE__\s*=\s*(\{[\s\S]*?\})<\/script>/);
  if (!match) {
    return {
      error: 'Initial state not found',
      hint: 'The note page may require login or changed its structure',
      source,
    };
  }

  const state = JSON.parse(match[1]);
  const noteMap = state.note?.noteDetailMap || state.noteDetailMap || {};
  const noteId = Object.keys(noteMap)[0] || '';
  const note = noteMap[noteId]?.note || noteMap[noteId] || {};
  const user = note.user || {};
  const interact = note.interactInfo || {};
  const tagList = note.tagList || note.tags || [];

  return {
    source,
    note_id: note.noteId || noteId,
    title: note.title || '',
    content: note.desc || note.content || '',
    type: note.type || '',
    author: user.nickname || '',
    author_id: user.userId || '',
    author_avatar: user.avatar || '',
    likes: Number(interact.likedCount || interact.likeCount || 0) || 0,
    collects: Number(interact.collectedCount || 0) || 0,
    comments: Number(interact.commentCount || 0) || 0,
    shares: Number(interact.shareCount || 0) || 0,
    tags: tagList.map((tag) =>
      typeof tag === 'string' ? tag : tag.name || tag.tag || ''
    ),
    images: (note.imageList || []).map((image) =>
      image.urlDefault || image.urlPre || image.url || ''
    ),
    video_url:
      note.video?.media?.stream?.h264?.[0]?.masterUrl ||
      note.video?.consumer?.originVideoKey ||
      '',
    publish_time: note.time ? new Date(note.time).toISOString() : null,
    url: note.noteId
      ? 'https://www.xiaohongshu.com/explore/' + note.noteId
      : inputUrl,
  };
}

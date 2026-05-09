async (args) => {
  const topicId = args.id;
  const source = `https://linux.do/t/${topicId}.json`;
  const limit = Math.min(100, Math.max(1, Number(args.posts) || 20));

  try {
    const resp = await fetch(source);
    if (!resp.ok) {
      return {
        error: 'HTTP ' + resp.status,
        hint: 'Open https://linux.do first, ensure the topic exists, then retry.',
        source,
      };
    }

    const data = await resp.json();
    const toText = (html) => {
      if (!html) return '';
      const div = document.createElement('div');
      div.innerHTML = html;
      return (div.textContent || '').replace(/\\s+/g, ' ').trim();
    };

    const posts = (data.post_stream?.posts || [])
      .slice(0, limit)
      .map((post) => ({
        id: post.id,
        post_number: post.post_number,
        username: post.username || '',
        name: post.name || post.display_username || '',
        created_at: post.created_at || '',
        updated_at: post.updated_at || '',
        reply_count: post.reply_count || 0,
        reads: post.reads || 0,
        score: post.score || 0,
        can_edit: !!post.can_edit,
        can_delete: !!post.can_delete,
        url: post.post_url
          ? `https://linux.do${post.post_url}`
          : `https://linux.do/t/${data.slug || 'topic'}/${data.id}/${post.post_number}`,
        cooked: post.cooked || '',
        text: toText(post.cooked || ''),
      }));

    return {
      source,
      topic: {
        id: data.id,
        title: data.title || '',
        slug: data.slug || '',
        fancy_title: data.fancy_title || '',
        url: `https://linux.do/t/${data.slug || 'topic'}/${data.id}`,
        posts_count: data.posts_count || 0,
        reply_count: data.reply_count || 0,
        views: data.views || 0,
        like_count: data.like_count || 0,
        created_at: data.created_at || '',
        last_posted_at: data.last_posted_at || '',
        bumped_at: data.bumped_at || '',
        archetype: data.archetype || '',
        pinned: !!data.pinned,
        pinned_globally: !!data.pinned_globally,
        visible: data.visible !== false,
        category_id: data.category_id || 0,
        tags: data.tags || [],
      },
      post_count: posts.length,
      posts,
    };
  } catch (error) {
    return {
      error: 'Unexpected response',
      hint: 'Open https://linux.do first, ensure the topic exists, then retry.',
      source,
      detail: String(error),
    };
  }
}

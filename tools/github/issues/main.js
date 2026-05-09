async (args) => {
  const repo = args.repo || '';
  if (!repo) {
    return {
      error: 'Missing argument: repo',
    };
  }

  const state = args.state || 'open';
  const source =
    'https://api.github.com/repos/' +
    repo +
    '/issues?state=' +
    encodeURIComponent(state) +
    '&per_page=30';

  const resp = await fetch(source, {
    headers: {Accept: 'application/vnd.github+json'},
    credentials: 'include',
  });
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      source,
    };
  }

  const issues = await resp.json();
  return {
    source,
    repo,
    state,
    count: issues.length,
    issues: issues.map((issue) => ({
      number: issue.number || 0,
      title: issue.title || '',
      state: issue.state || '',
      url: issue.html_url || '',
      author: issue.user?.login || '',
      labels: (issue.labels || []).map((label) => label.name || ''),
      comments: issue.comments || 0,
      created_at: issue.created_at || '',
      is_pr: !!issue.pull_request,
    })),
  };
}

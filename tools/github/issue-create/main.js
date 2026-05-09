async (args) => {
  const repo = args.repo || '';
  const title = args.title || '';
  if (!repo) {
    return {
      error: 'Missing argument: repo',
    };
  }
  if (!title) {
    return {
      error: 'Missing argument: title',
    };
  }

  const source = 'https://api.github.com/repos/' + repo + '/issues';
  const resp = await fetch(source, {
    method: 'POST',
    headers: {
      Accept: 'application/vnd.github+json',
      'Content-Type': 'application/json',
    },
    credentials: 'include',
    body: JSON.stringify({
      title,
      body: args.body || '',
    }),
  });

  if (!resp.ok) {
    const status = resp.status;
    if (status === 401 || status === 403) {
      return {
        error: 'HTTP ' + status,
        hint: 'Not logged in to GitHub',
        source,
      };
    }
    if (status === 404) {
      return {
        error: 'Repo not found: ' + repo,
        source,
      };
    }
    return {
      error: 'HTTP ' + status,
      source,
    };
  }

  const issue = await resp.json();
  return {
    source,
    number: issue.number || 0,
    title: issue.title || '',
    url: issue.html_url || '',
    state: issue.state || '',
  };
}

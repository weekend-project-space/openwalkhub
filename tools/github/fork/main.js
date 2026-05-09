async (args) => {
  const repo = args.repo || '';
  if (!repo) {
    return {
      error: 'Missing argument: repo',
    };
  }

  const source = 'https://api.github.com/repos/' + repo + '/forks';
  const resp = await fetch(source, {
    method: 'POST',
    headers: {
      Accept: 'application/vnd.github+json',
      'Content-Type': 'application/json',
    },
    credentials: 'include',
    body: '{}',
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

  const fork = await resp.json();
  return {
    source,
    full_name: fork.full_name || '',
    url: fork.html_url || '',
    clone_url: fork.clone_url || '',
  };
}

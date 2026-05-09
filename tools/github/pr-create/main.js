async (args) => {
  const repo = args.repo || '';
  const title = args.title || '';
  const head = args.head || '';
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
  if (!head) {
    return {
      error: 'Missing argument: head',
      hint: 'Provide source branch as "user:branch" or "branch"',
    };
  }

  const source = 'https://api.github.com/repos/' + repo + '/pulls';
  const resp = await fetch(source, {
    method: 'POST',
    headers: {
      Accept: 'application/vnd.github+json',
      'Content-Type': 'application/json',
    },
    credentials: 'include',
    body: JSON.stringify({
      title,
      head,
      base: args.base || 'main',
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
    if (status === 422) {
      let data = null;
      try {
        data = await resp.json();
      } catch (error) {
      }
      return {
        error:
          data?.errors?.[0]?.message ||
          data?.message ||
          'Validation failed',
        hint: 'Check that the head branch exists and has commits ahead of base',
        source,
      };
    }
    return {
      error: 'HTTP ' + status,
      source,
    };
  }

  const pr = await resp.json();
  return {
    source,
    number: pr.number || 0,
    title: pr.title || '',
    url: pr.html_url || '',
    state: pr.state || '',
  };
}

async (args) => {
  const source = 'https://api.github.com/user';
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      hint: resp.status === 401 ? 'Not logged into github.com' : 'API error',
      source,
    };
  }

  const data = await resp.json();
  return {
    source,
    login: data.login || '',
    name: data.name || '',
    bio: data.bio || '',
    url: data.html_url || (data.login ? 'https://github.com/' + data.login : ''),
    public_repos: data.public_repos || 0,
    followers: data.followers || 0,
    following: data.following || 0,
    created_at: data.created_at || '',
  };
}

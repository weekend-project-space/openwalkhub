async (args) => {
  const repo = args.repo || '';
  if (!repo) {
    return {
      error: 'Missing argument: repo',
      hint: 'Use owner/repo format',
    };
  }

  const parts = repo.split('/');
  if (parts.length !== 2) {
    return {
      error: 'Invalid repo format',
      hint: 'Use owner/repo format (e.g. epiral/pinix)',
    };
  }

  const source = `https://github.com/${repo}`;
  const resp = await fetch(source, {credentials: 'include'});
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      hint: resp.status === 404 ? 'Repo not found: ' + repo : 'GitHub error',
      source,
    };
  }

  const html = await resp.text();
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const description =
    doc.querySelector('p.f4.my-3')?.textContent?.trim() ||
    doc.querySelector('[itemprop=\"about\"]')?.textContent?.trim() ||
    null;
  const language =
    doc.querySelector('[itemprop=\"programmingLanguage\"]')?.textContent?.trim() ||
    null;
  const metaOG = {};
  doc.querySelectorAll('meta[property^=\"og:\"]').forEach((el) => {
    const prop = el.getAttribute('property')?.replace('og:', '');
    if (prop) {
      metaOG[prop] = el.getAttribute('content');
    }
  });

  const counters = {};
  doc.querySelectorAll(
    'a[href$=\"/stargazers\"] .Counter, a[href$=\"/forks\"] .Counter, a[href$=\"/watchers\"] .Counter'
  ).forEach((el) => {
    const href = el.closest('a')?.getAttribute('href') || '';
    const value = el.getAttribute('title') || el.textContent?.trim() || '0';
    if (href.endsWith('/stargazers')) {
      counters.stars = parseInt(value.replace(/,/g, ''), 10) || 0;
    }
    if (href.endsWith('/forks')) {
      counters.forks = parseInt(value.replace(/,/g, ''), 10) || 0;
    }
  });

  const topics = Array.from(doc.querySelectorAll('a.topic-tag'))
    .map((a) => a.textContent?.trim() || '')
    .filter(Boolean);
  const license =
    doc.querySelector('a[href*=\"LICENSE\"], a[data-analytics-event*=\"LICENSE\"]')
      ?.textContent?.trim() || null;

  return {
    source,
    full_name: repo,
    description: description || metaOG.description || null,
    language,
    url: source,
    stars: counters.stars ?? null,
    forks: counters.forks ?? null,
    topics: topics.length ? topics : null,
    license,
  };
}

async (args) => {
  const source = 'https://bbs.hupu.com/all-gambia';
  const resp = await fetch(source);
  if (!resp.ok) {
    return {
      error: 'HTTP ' + resp.status,
      source,
    };
  }

  const html = await resp.text();
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const items = [...doc.querySelectorAll('.list-item-wrap')]
    .map((wrap, index) => {
      const link = wrap.querySelector('.t-info > a');
      const titleEl = wrap.querySelector('.t-title');
      const lightsEl = wrap.querySelector('.t-lights');
      const repliesEl = wrap.querySelector('.t-replies');
      const labelEl = wrap.querySelector('.t-label a');
      if (!link || !titleEl) return null;

      const href = link.getAttribute('href') || '';
      return {
        rank: index + 1,
        tid: href.replace(/\D/g, ''),
        title: titleEl.textContent?.trim() || '',
        url: href ? 'https://bbs.hupu.com' + href : '',
        lights: parseInt((lightsEl?.textContent || '').replace(/\D/g, ''), 10) || 0,
        replies: parseInt((repliesEl?.textContent || '').replace(/\D/g, ''), 10) || 0,
        isHot: (link.className || '').includes('hot'),
        forum: labelEl?.textContent?.trim() || '',
      };
    })
    .filter(Boolean);

  return {
    source,
    count: items.length,
    items,
  };
}

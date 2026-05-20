async (args) => {
  const source = 'https://www.zhibo8.com/';
  const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

  const normalizeText = (text) => (text || '').replace(/\s+/g, ' ').trim();
  const cleanSide = (side) => normalizeText(
    (side || '')
      .replace(/\([^)]*\)/g, '')
      .replace(/\b\d+\b/g, '')
      .replace(/\s+/g, ' ')
  ).replace(/^[-\s]+|[-\s]+$/g, '');

  const simplifyMatch = (match) => {
    const parts = String(match || '')
      .split(' - ')
      .map(p => p.trim())
      .filter(Boolean);

    const cleaned = [];
    for (const p of parts) {
      if (p.includes('比分') || p.includes('首回合')) continue;
      const side = cleanSide(p);
      if (side) cleaned.push(side);
    }

    if (cleaned.length >= 2) {
      return cleaned[0] + ' - ' + cleaned[cleaned.length - 1];
    }
    return cleanSide(match || '');
  };

  const getCount = () => document.querySelectorAll('[id^="saishi"]').length;

  let lastCount = 0;
  let stableRounds = 0;
  const maxRounds = 20;

  for (let i = 0; i < maxRounds; i++) {
    window.scrollTo(0, document.body.scrollHeight);
    await sleep(1200);

    const count = getCount();
    if (count === lastCount) {
      stableRounds += 1;
    } else {
      stableRounds = 0;
      lastCount = count;
    }

    if (stableRounds >= 2) break;
  }

  window.scrollTo(0, 0);
  await sleep(300);

  const year = new Date().getFullYear();
  const isDateHeader = (text) => /^\d{1,2}月\d{1,2}日\s+星期[一二三四五六日天]$/.test(text);
  let currentDate = '';
  const items = [];

  for (const node of Array.from(document.querySelectorAll('body *'))) {
    const text = normalizeText(node.innerText || '');

    if (isDateHeader(text)) {
      const m = text.match(/^(\d{1,2})月(\d{1,2})日/);
      if (m) {
        currentDate = year + '-' + String(m[1]).padStart(2, '0') + '-' + String(m[2]).padStart(2, '0');
      }
    }

    if (node.id && node.id.startsWith('saishi')) {
      const li = node.closest('li') || node.parentElement;
      const time = normalizeText(li?.querySelector('time')?.innerText || '');
      const teamText = normalizeText(li?.querySelector('span._teams')?.innerText || '');

      let match = teamText
        .replace(/^[-\s]+|[-\s]+$/g, '')
        .replace(/\s*-\s*/g, ' - ');

      if (!match.includes(' - ')) {
        match = '';
      }

      items.push({ date: currentDate, time, match });
    }
  }

  const dedup = [];
  const seen = new Set();
  for (const item of items) {
    const key = [item.date, item.time, item.match].join('||');
    if (seen.has(key)) continue;
    seen.add(key);
    if (!item.match) continue;

    dedup.push({
      date: item.date,
      time: item.time,
      match: simplifyMatch(item.match),
    });
  }

  return {
    source,
    count: dedup.length,
    matches: dedup.map((m, index) => ({
      index: index + 1,
      date: m.date,
      time: m.time,
      match: m.match,
    })),
  };
}

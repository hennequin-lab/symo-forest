(() => {
  'use strict';

  const BASE = "/symo-forest/";
  const deck = document.getElementById('eg-deck');
  if (!deck || !window.fetch || !window.DOMParser || !history.pushState) return;

  const SPINE = 40;      // --eg-spine-w
  const PEEK = 300;      // --eg-peek-w
  const OVERLAP = 24;    // --eg-overlap
  const MIN_FOCUS = 380; // the open note never gets narrower than this
  const WIDE = window.matchMedia('(min-width: 48rem)');

  const panes = () => Array.from(deck.children).filter((n) => n.classList.contains('eg-pane'));
  const focusOf = () => panes().findIndex((p) => p.classList.contains('is-focus'));
  const ids = () => panes().map((p) => p.dataset.noteId).filter(Boolean);
  const pathOf = (url) => {
    try { return new URL(url, location.href).pathname; } catch (_) { return ''; }
  };
  const chrome = {
    title: document.getElementById('eg-current-title'),
    count: document.getElementById('eg-count'),
    nav: document.getElementById('eg-deck-nav'),
  };
  const isLink = (el) => el && el.nodeType === 1 && !!el.closest('a[href]');

  // ─── Geometry ────────────────────────────────────────────────────────────
  function syncChrome(pane, i, n) {
    if (!pane) return;
    const title = pane.dataset.title || 'EG';
    document.title = title;
    if (chrome.title) chrome.title.textContent = title;
    if (chrome.count) chrome.count.textContent = (i + 1) + '/' + n;
    if (chrome.nav) chrome.nav.hidden = n < 2;
  }

  // Bring the open note into view: horizontally when the shelf is wider than
  // the window, vertically when the shelf is unrolled.
  let revealQueued = false;
  function reveal(pane, smooth) {
    if (!pane) return;
    if (!WIDE.matches) {
      // Heights settle synchronously here (the column layout transitions
      // widths, not heights), so no frame is needed to know where to go.
      const top = pane.offsetTop;
      if (Math.abs(deck.scrollTop - top) > 4) {
        deck.scrollTo({ top: top, behavior: smooth ? 'smooth' : 'auto' });
      }
      return;
    }
    if (revealQueued) return;
    revealQueued = true;
    requestAnimationFrame(() => {
      revealQueued = false;
      if (!pane.isConnected) return;
      const d = deck.getBoundingClientRect();
      const p = pane.getBoundingClientRect();
      if (p.left < d.left) deck.scrollLeft += p.left - d.left - 8;
      else if (p.right > d.right) deck.scrollLeft += p.right - d.right + 8;
    });
  }

  function layout(smooth) {
    const all = panes();
    if (!all.length) return;
    let f = focusOf();
    if (f < 0) f = all.length - 1;
    const n = all.length;
    const room = deck.clientWidth;
    const wide = WIDE.matches;
    const peek = wide && f > 0 && room - n * SPINE - PEEK >= MIN_FOCUS;
    let focusW = wide ? room - n * SPINE - (peek ? PEEK : 0) + OVERLAP : room;
    if (wide) focusW = Math.max(MIN_FOCUS, focusW);
    deck.classList.add('eg-stacked');
    deck.style.setProperty('--eg-focus-w', Math.round(focusW) + 'px');
    all.forEach((p, i) => {
      p.classList.toggle('is-focus', i === f);
      p.classList.toggle('is-peek', peek && i === f - 1);
      // The spine of the open note is not a control: keep it out of the tab
      // order and out of reach of the pointer.
      const spine = p.querySelector('.eg-spine');
      if (spine) spine.disabled = i === f;
    });
    syncChrome(all[f], f, n);
    reveal(all[f], smooth);
  }

  function setFocus(i, silent) {
    const all = panes();
    if (i < 0 || i >= all.length) return;
    all.forEach((p, j) => p.classList.toggle('is-focus', j === i));
    layout(true);
    if (!silent) {
      const url = all[i].dataset.url;
      if (url) history.replaceState({ eg: ids() }, '', url);
    }
  }

  function step(delta) {
    const n = panes().length;
    if (n < 2) return;
    const f = focusOf();
    setFocus((f + delta + n) % n);
  }

  // ─── Stack operations ────────────────────────────────────────────────────
  function findOpen(url) {
    const want = pathOf(url);
    return panes().find((p) => pathOf(p.dataset.url) === want) || null;
  }

  async function fetchPane(url) {
    try {
      const res = await fetch(pathOf(url), { credentials: 'same-origin' });
      if (!res.ok) return null;
      const doc = new DOMParser().parseFromString(await res.text(), 'text/html');
      const el = doc.querySelector('.eg-pane');
      return el ? document.importNode(el, true) : null;
    } catch (_) {
      return null;
    }
  }

  let navigating = false;
  async function navigate(url) {
    const target = pathOf(url);
    const modal = document.getElementById('search-modal');
    const already = findOpen(target);
    if (already) {
      if (modal) modal.hidden = true;
      setFocus(panes().indexOf(already));
      return;
    }
    if (navigating) return;
    navigating = true;
    const pane = await fetchPane(target);
    navigating = false;
    if (!pane) {
      location.href = target;
      return;
    }
    if (modal) modal.hidden = true;
    deck.appendChild(pane);
    const f = panes().length - 1;
    panes().forEach((p, j) => p.classList.toggle('is-focus', j === f));
    layout();
    history.pushState({ eg: ids() }, '', target);
  }

  function closePane(pane) {
    const all = panes();
    if (!pane) return;
    if (all.length <= 1) {
      location.href = BASE;
      return;
    }
    const i = all.indexOf(pane);
    if (i < 0) return;
    const wasNewest = i === all.length - 1;
    pane.remove();
    const rest = panes();
    const j = Math.max(0, Math.min(i - 1, rest.length - 1));
    rest.forEach((p, k) => p.classList.toggle('is-focus', k === j));
    layout();
    const entry = history.state && history.state.eg;
    if (wasNewest && Array.isArray(entry) && entry.length > 1) {
      // Undo the push that opened this pane: the previous entry is the note
      // that was in front before it (and `popstate` prunes the DOM).
      history.back();
    } else {
      const url = rest[j] && rest[j].dataset.url;
      history.replaceState({ eg: ids() }, '', url || location.href);
    }
  }

  function popTo(target) {
    const all = panes();
    const have = all.map((p) => p.dataset.noteId);
    if (target.length > have.length) return false;
    for (let i = 0; i < target.length; i += 1) {
      if (target[i] !== have[i]) return false;
    }
    all.slice(target.length).forEach((p) => p.remove());
    setFocus(target.length - 1, true);
    return true;
  }

  // ─── Events ──────────────────────────────────────────────────────────────
  function isNoteLink(link, e) {
    if (e.defaultPrevented || e.button !== 0) return false;
    if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return false;
    if (link.target && link.target !== '_self') return false;
    if (link.hasAttribute('download')) return false;
    const p = pathOf(link.getAttribute('href'));
    return p.startsWith(BASE) && /^notes\/[^/]+\/$/.test(p.slice(BASE.length));
  }

  // A background pane is behind glass: clicking it brings it forward instead
  // of following whatever was under the cursor.
  deck.addEventListener('click', (e) => {
    if (e.defaultPrevented) return;
    const t = e.target;
    if (!t.closest || t.closest('[data-eg-close],[data-eg-step]')) return;
    const pane = t.closest('.eg-pane');
    if (!pane) return;
    const i = panes().indexOf(pane);
    if (i < 0 || i === focusOf()) return;
    if (!WIDE.matches && isLink(t)) return; // unrolled: links keep working
    e.preventDefault();
    setFocus(i);
  });

  document.addEventListener('click', (e) => {
    const t = e.target;
    if (!t.closest) return;
    const stepBtn = t.closest('[data-eg-step]');
    if (stepBtn) {
      e.preventDefault();
      step(Number(stepBtn.getAttribute('data-eg-step')) || 0);
      return;
    }
    const closeBtn = t.closest('[data-eg-close]');
    if (closeBtn) {
      e.preventDefault();
      closePane(closeBtn.closest('.eg-pane') || panes()[focusOf()]);
      return;
    }
    const link = t.closest('a[href]');
    if (link && isNoteLink(link, e)) {
      e.preventDefault();
      navigate(link.getAttribute('href'));
    }
  });

  document.addEventListener('keydown', (e) => {
    if (e.defaultPrevented || e.altKey || e.ctrlKey || e.metaKey) return;
    const t = e.target;
    if (t && (t.isContentEditable || /^(input|textarea|select)$/i.test(t.tagName || ''))) {
      return;
    }
    const modal = document.getElementById('search-modal');
    if (modal && !modal.hidden) return;
    if (e.key === 'j' || e.key === 'ArrowRight') {
      e.preventDefault();
      step(1);
    } else if (e.key === 'k' || e.key === 'ArrowLeft') {
      e.preventDefault();
      step(-1);
    } else if (e.key === 'q') {
      e.preventDefault();
      closePane(panes()[focusOf()]);
    }
  });

  window.addEventListener('popstate', (e) => {
    const st = e.state;
    if (!st || !Array.isArray(st.eg) || !popTo(st.eg)) location.reload();
  });

  let resizeQueued = false;
  const onResize = () => {
    if (resizeQueued) return;
    resizeQueued = true;
    requestAnimationFrame(() => {
      resizeQueued = false;
      layout();
    });
  };
  window.addEventListener('resize', onResize, { passive: true });
  if (WIDE.addEventListener) WIDE.addEventListener('change', onResize);

  // ─── Boot ────────────────────────────────────────────────────────────────
  const all = panes();
  if (!all.length) return;
  let f = focusOf();
  if (f < 0) {
    f = 0;
    all[0].classList.add('is-focus');
  }
  history.replaceState({ eg: ids() }, '', all[f].dataset.url || location.href);
  layout();
})();

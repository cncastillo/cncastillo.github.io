// One shared axis: stagger only overlapping dates, regardless of output type.
export function timelineLayout(items, viewportWidth, gap = 32) {
  const firstYear = Math.min(...items.map(item => Number(item.start.slice(0, 4))));
  const lastYear = Math.max(...items.map(item => Number(item.start.slice(0, 4))));
  const start = Date.UTC(firstYear, 0, 1);
  const end = Date.UTC(lastYear + 1, 0, 1);
  const visibleStart = Date.UTC(Math.max(firstYear, lastYear - 7), 0, 1);
  const scale = (viewportWidth - 48) / (end - visibleStart);
  const scrollLeft = (visibleStart - start) * scale;
  const width = viewportWidth + scrollLeft;
  const x = date => 24 + (Date.parse(date) - start) * scale;
  const positions = new Map();
  const levels = [];
  for (const item of [...items].sort((a, b) => a.start.localeCompare(b.start))) {
    const left = x(item.start);
    let level = levels.findIndex(previous => left - previous >= gap);
    if (level < 0) level = levels.length;
    levels[level] = left;
    const offset = Math.ceil(level / 2) * gap * (level % 2 ? -1 : 1);
    positions.set(item, {x: left, y: offset});
  }
  const offsets = [...positions.values()].map(point => point.y);
  const axisY = 24 - Math.min(...offsets);
  const height = axisY + Math.max(...offsets) + 48;
  positions.forEach(point => { point.y += axisY; });
  const years = Array.from({length: lastYear - firstYear + 1}, (_, i) => ({year: firstYear + i, x: x(`${firstYear + i}-01-01`)}));
  return {positions, years, axisY, height, width, scrollLeft};
}

export function initializeTimeline(root) {
  const chart = root.querySelector('.timeline-chart');
  const scroller = root.querySelector('.timeline-scroll');
  const detail = root.querySelector('.timeline-detail');
  const content = detail.querySelector('.timeline-detail-content');
  const points = [...root.querySelectorAll('.timeline-point')];
  const items = points.map(button => ({button, kind: button.dataset.kind, start: button.dataset.date}));
  if (!items.length) return;
  let active;
  let maxScroll = 0;
  const today = new Date().toISOString().slice(0, 10);
  points.forEach(button => button.classList.toggle('timeline-future', button.dataset.date > today));

  function hide() {
    if (active) active.setAttribute('aria-expanded', 'false');
    active = undefined;
    detail.hidden = true;
  }

  function positionDetail() {
    if (!active) return;
    const bounds = root.getBoundingClientRect();
    const point = active.getBoundingClientRect();
    const center = point.left + point.width / 2;
    detail.style.left = `${Math.max(0, Math.min(center - bounds.left - detail.offsetWidth / 2, bounds.width - detail.offsetWidth))}px`;
    // CSS lifts the tooltip so its bottom stays 36px above the marker center.
    detail.style.top = `${(point.top + point.bottom) / 2 - bounds.top - 36}px`;
  }

  function show(button) {
    if (active !== button) {
      if (active) active.setAttribute('aria-expanded', 'false');
      active = button;
      content.replaceChildren(button.querySelector('template').content.cloneNode(true));
      if (button.dataset.date > today) content.querySelector('.timeline-scheduled').textContent = ' · Scheduled';
      detail.classList.toggle('is-awarded', button.classList.contains('timeline-awarded'));
      detail.scrollTop = 0;
    }
    button.setAttribute('aria-expanded', 'true');
    detail.hidden = false;
    positionDetail();
  }

  function draw() {
    const scrollProgress = maxScroll ? Math.max(0, Math.min(1, scroller.scrollLeft / maxScroll)) : 1;
    const gap = window.matchMedia('(pointer: coarse)').matches ? 44 : 32;
    const layout = timelineLayout(items, scroller.clientWidth, gap);
    chart.style.width = `${layout.width}px`;
    chart.style.height = `${layout.height}px`;
    chart.style.setProperty('--axis-y', `${layout.axisY}px`);
    const years = chart.querySelector('.timeline-years');
    years.replaceChildren(...layout.years.map(({year, x}) => {
      const tick = document.createElement('div');
      tick.className = 'timeline-year';
      tick.style.left = `${x}px`;
      const label = document.createElement('span');
      label.textContent = year;
      tick.append(label);
      return tick;
    }));
    layout.positions.forEach(({x, y}, {button}) => {
      if (y !== layout.axisY) {
        const stem = document.createElement('span');
        stem.className = 'timeline-stem';
        stem.style.left = `${x}px`;
        stem.style.top = `${Math.min(y, layout.axisY)}px`;
        stem.style.height = `${Math.abs(y - layout.axisY)}px`;
        years.append(stem);
      }
      button.style.left = `${x}px`;
      button.style.top = `${y}px`;
    });
    maxScroll = layout.scrollLeft;
    scroller.scrollLeft = scrollProgress * maxScroll;
    root.querySelector('.timeline-history-hint').hidden = maxScroll <= 0;
    positionDetail();
  }

  // Chronological keyboard order, independent of YAML file order.
  items.sort((a, b) => a.start.localeCompare(b.start)).forEach(({button}) => chart.append(button));
  points.forEach(button => {
    button.addEventListener('pointerenter', event => {
      if (event.pointerType !== 'touch') show(button);
    });
    button.addEventListener('pointerleave', () => {
      if (active === button && !button.matches(':focus-visible')) hide();
    });
    button.addEventListener('focus', () => show(button));
    button.addEventListener('blur', () => {
      if (active === button) hide();
    });
    button.addEventListener('click', () => show(button));
  });
  root.addEventListener('keydown', event => {
    if (event.key === 'Escape') hide();
  });
  document.addEventListener('pointerdown', event => { if (active && !active.contains(event.target)) hide(); });
  scroller.addEventListener('scroll', () => {
    if (active?.matches(':focus-visible')) positionDetail();
    else hide();
  });
  root.hidden = false;
  new ResizeObserver(draw).observe(scroller);
  draw();
}

if (typeof document !== 'undefined') {
  const root = document.getElementById('research-timeline');
  if (root) initializeTimeline(root);
}

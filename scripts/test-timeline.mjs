import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {resolve} from 'node:path';
import {fileURLToPath} from 'node:url';

const root = fileURLToPath(new URL('../', import.meta.url));
const source = readFileSync(resolve(root, 'assets/js/research-timeline.js'), 'utf8');
const {timelineLayout} = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
const html = readFileSync(resolve(process.argv[2], 'publications/index.html'), 'utf8');
assert.ok(!html.includes('Conference talk'), 'Use Oral presentation consistently in archive entries and timeline tooltips');
const siteCss = readFileSync(resolve(root, 'assets/css/site.css'), 'utf8');
assert.ok(!html.includes('publications-page') && !siteCss.includes('.publications-page'), 'Timeline must not override the Publications page layout');
assert.match(siteCss, /\.page-header\s*\{\s*max-width:\s*58rem;/, 'Preserve the original shared header width');
assert.match(html, /<header class="page-header research-header">[\s\S]*?<\/header>\s*<nav class="section-nav"/, 'Research menu must directly follow its scoped header');
assert.match(siteCss, /\.research-header\s*\{\s*border-bottom: 0;\s*\}/, 'Remove only the Research header divider, not its text width');
assert.match(siteCss, /\.research-header \+ \.section-nav\s*\{\s*border-top: 1px solid var\(--line\);\s*\}/, 'Research menu must own both full-width rules');
for (const page of ['index.html', 'teaching/index.html', 'teaching/bios-214/index.html', 'cv/index.html']) {
  assert.ok(!readFileSync(resolve(process.argv[2], page), 'utf8').includes('research-header'), `Research divider scope must not affect ${page}`);
}
const buttons = [...html.matchAll(/<a\b[^>]*class="timeline-point[^>]*>[\s\S]*?<\/a>/g)].map(match => match[0]);
const attribute = (html, name) => html.match(new RegExp(` ${name}="([^"]*)"`))?.[1];
const items = buttons.map(button => ({
  start: attribute(button, 'data-date'), kind: attribute(button, 'data-kind'),
  key: attribute(button, 'data-record-key')
}));
const records = JSON.parse(execFileSync('ruby', ['-ryaml', '-rjson', '-e',
  'puts ARGV.flat_map { |path| YAML.safe_load(File.read(path)) }.to_json',
  resolve(root, '_data/publications.yml'), resolve(root, '_data/presentations.yml'), resolve(root, '_data/grants.yml')], {encoding: 'utf8'}));
const dated = records.filter(record => record.date || record.event_start);
const home = readFileSync(resolve(process.argv[2], 'index.html'), 'utf8');
const grants = records.filter(record => record.funder);
const researchOrder = ['awards', 'publications', ...(grants.length ? ['grants'] : []), 'invited', 'abstracts', 'books'];
const researchMenu = html.match(/<nav class="section-nav" aria-label="Page sections">([\s\S]*?)<\/nav>/)[1];
assert.deepEqual([...researchMenu.matchAll(/href="#([^"]+)"/g)].map(match => match[1]), researchOrder, 'Research menu must follow the selected section order');
assert.deepEqual([...html.matchAll(/<section class="archive-section[^"]*" id="([^"]+)"/g)].map(match => match[1]), researchOrder, 'Research sections must match the menu order');
if (grants.length) {
  const funding = home.match(/<section class="funding-showcase" id="funding"[^>]*>([\s\S]*?)<\/section>/)?.[1];
  assert.ok(funding, 'Homepage must show a compact funding section');
  assert.ok(home.indexOf('id="projects"') < home.indexOf('id="awards"') && home.indexOf('id="awards"') < home.indexOf('id="funding"'), 'Place projects first, awards second, and funding last');
  const homeMenu = home.match(/<nav class="section-nav" aria-label="Home page sections">([\s\S]*?)<\/nav>/)[1];
  assert.deepEqual([...homeMenu.matchAll(/href="#([^"]+)"/g)].map(match => match[1]), ['projects', 'awards', 'funding'], 'Homepage menu must match section order');
  assert.ok(homeMenu.includes(`Research funding&nbsp;<sup class="section-count">${grants.length}</sup>`), 'Homepage funding count must follow the data');
  for (const grant of grants) {
    assert.ok(funding.includes(`href="/publications/#record-${grant.record_key}"`), 'Funding summary must link to its full Research entry');
    for (const key of ['funder', 'program', 'year', 'amount', 'role']) {
      if (grant[key]) assert.ok(funding.includes(String(grant[key])), `Homepage funding summary missing ${key}`);
    }
    assert.ok(!funding.includes(grant.title) && !funding.includes('Blog post'), 'Keep full project descriptions and blog links on Research');
  }
}
assert.equal(items.length, dated.length, 'Every record with a date or conference start must appear exactly once');
assert.equal(new Set(items.map(item => item.key)).size, items.length, 'No duplicate timeline entries');
for (const item of items) {
  const record = dated.find(record => record.record_key === item.key);
  assert.ok(record, `Unexpected output: ${item.key}`);
  assert.notEqual(record.kind, 'Abstract', `Presentation format is unspecified for ${item.key}`);
  assert.equal(item.start, record.date || record.event_start);
  assert.ok(html.includes(`id="record-${item.key}"`), `Missing archive target: ${item.key}`);
  const expected = record.funder ? 'grant' : ['peer_reviewed', 'book'].includes(record.category) ? 'paper' : record.category === 'invited' ? 'invited' : /poster/i.test(record.kind) ? 'poster' : 'talk';
  assert.equal(item.kind, expected);
  const button = buttons[items.indexOf(item)];
  assert.equal(attribute(button, 'href'), `#record-${item.key}`, 'Every timeline marker must link to its own archive entry');
  assert.ok(!button.match(/<template>([\s\S]*?)<\/template>/)[1].includes('<a '), 'Tooltip content must not contain a View entry link');
  assert.equal(attribute(button, 'data-end'), undefined, 'Every output must be a single-date marker');
  assert.equal(attribute(button, 'class').includes('timeline-awarded'), Boolean(record.funder || record.recognitions?.length));
  if (record.kind === 'Power pitch') assert.ok(button.includes('Power pitch (talk + poster)'), 'Power pitches must explain the combined format');
  if (record.funder) {
    assert.ok(button.includes('Grant ·'), 'Funding must be identified as a grant');
    for (const key of ['funder', 'program', 'organization', 'amount', 'role']) {
      if (record[key]) assert.ok(button.includes(record[key]), `Grant tooltip missing ${key}`);
    }
  }
}
assert.ok(!html.includes('timeline-abstract'), 'Abstract must not be a timeline presentation format');
assert.ok(html.includes('Awards &amp; funding</span>'), 'Gold legend must cover awards and funding');
for (const [kind, label] of [['paper', 'Papers'], ['poster', 'Posters'], ['talk', 'Talks'], ['invited', 'Invited talks'], ['grant', 'Grants']]) {
  assert.ok(html.includes(`timeline-${kind}" aria-hidden="true"></i> ${label}`), `Missing ${label} legend`);
}
for (const [key, expected] of [
  ['mrisim-ismrm-2022', 'poster'],
  ['diffusion-mrf-055t-ismrm', 'poster'],
  ['rf-design-ismrm-2026', 'poster'],
  ['cardiac-mrf-055t-scmr', 'poster'],
  ['magnus-ismrm-2026', 'talk'],
  ['magnus-workshop-2026', 'talk'],
  ['ismrm-2026-reconstruction', 'invited'],
  ['juliacon-2026-spins', 'talk'],
  ['midas-2025-differentiable-mri', 'invited'],
  ['miitt-2026-differentiable-mri', 'invited'],
  ['mritogether-2025-flow', 'invited']
]) assert.equal(items.find(item => item.key === key).kind, expected, `Wrong presentation format for ${key}`);
assert.ok(html.includes('Invited educational talk ·'), 'Hover details must preserve educational invitation status');
const cmra = buttons[items.findIndex(item => item.key === 'low-field-cmra-ismrm')];
const cmraRecognitions = [...cmra.matchAll(/<p class="timeline-detail-award">([^<]+)<\/p>/g)].map(match => match[1]);
assert.deepEqual(cmraRecognitions, [
  'Summa Cum Laude Merit Award (Top 5%), ISMRM · 2023',
  'MRM fast-track initiative · 2023'
], 'Cum Laude and fast-track must remain separate recognitions');
const scmrMrf = buttons[items.findIndex(item => item.key === 'cardiac-mrf-055t-scmr')];
assert.ok(scmrMrf.includes('Digital poster ·'), 'SCMR MRF must retain its confirmed digital poster format');
assert.equal(attribute(scmrMrf, 'data-date'), '2024-01-24', 'SCMR MRF must use the conference first day');
assert.ok(scmrMrf.includes('Jan 24, 2024'), 'SCMR MRF hover details must display one date');
assert.ok(!scmrMrf.includes('Jan 27') && !/conference range/i.test(scmrMrf), 'No range text should be displayed');
const css = readFileSync(resolve(root, 'assets/css/research-timeline.css'), 'utf8');
const timelineStyles = css.match(/\.research-timeline\s*\{([^}]+)\}/)[1];
assert.ok(timelineStyles.includes('width: 100%') && timelineStyles.includes('max-width: 100%') && timelineStyles.includes('min-width: 0') && timelineStyles.includes('contain: inline-size'), 'Timeline must fill its parent without contributing intrinsic width to the page');
assert.doesNotMatch(css, /\.(?:page-shell|page-header|section-nav|content-page|prose)\b/, 'Timeline styles must not change shared page containers or rules');
assert.match(css, /\.timeline-invited\s*\{\s*transform: rotate\(45deg\);/, 'Invited talks must use a distinct diamond symbol');
assert.match(css, /\.timeline-grant\s*\{\s*clip-path: polygon\(25% 0, 75% 0, 100% 50%, 75% 100%, 25% 100%, 0 50%\)/, 'Grants must use a distinct hexagon symbol');
assert.ok(!html.includes('timeline-close') && !html.includes('timeline-record-link'), 'Tooltip must not contain close or navigation controls');
assert.ok(html.includes('id="timeline-detail" role="tooltip"'), 'Passive details must use tooltip semantics');
assert.ok(css.match(/\.timeline-detail\s*\{([^}]+)\}/)[1].includes('pointer-events: none'), 'Tooltip must not capture pointer hover');
assert.ok(css.match(/\.timeline-detail\s*\{([^}]+)\}/)[1].includes('transform: translateY(-100%)'), 'Tooltip bottom must align with its marker-relative anchor');
assert.ok(!css.includes('.timeline-point:hover'), 'Pointer hover must not highlight a different output from the displayed one');
assert.ok(css.includes('.timeline-point[aria-expanded="true"]'), 'Displayed output must retain its active highlight');
assert.ok(css.includes('.timeline-point:focus-visible'), 'Keyboard focus must remain visible');
assert.match(css, /\.timeline-point\.timeline-awarded\s*\{\s*color: var\(--recognition\);/, 'Recognition markers must retain their gold color');
assert.doesNotMatch(css, /\.timeline-awarded\s+\.timeline-symbol\s*\{/, 'Recognition symbols must not have decorative outlines or shadows');
assert.ok(!css.includes('[data-end]') && !css.includes('--range-width'), 'Remove the range bar and hollow-marker styles');
const scrollStyles = css.match(/\.timeline-scroll\s*\{([^}]+)\}/)[1];
assert.ok(scrollStyles.includes('width: 100%') && scrollStyles.includes('min-width: 0') && scrollStyles.includes('contain: inline-size') && scrollStyles.includes('overflow-x: auto'), 'Wide chart must be constrained to its own scroll container');
assert.ok(!css.includes('min-width: 48rem'), 'Timeline must not impose a fixed minimum width on the page');
for (const viewportWidth of [320, 768, 896, 928, 1152]) {
  for (const gap of [32, 44]) {
    const {positions, height, width, scrollLeft, years} = timelineLayout(items, viewportWidth, gap);
    assert.equal(positions.size, items.length, 'Scrolling must retain all older outputs');
    assert.ok(Math.abs(width - scrollLeft - viewportWidth) < 1e-8, 'Initial view must align to the newest end');
    const visibleYears = years.filter(({x}) => x - scrollLeft >= 24 - 1e-8).map(({year}) => year);
    assert.deepEqual(visibleYears, [2020, 2021, 2022, 2023, 2024, 2025, 2026], 'All current records must fit within the eight-year window');
    assert.equal(scrollLeft, 0, 'Current history must not require horizontal scrolling');
    for (const [item, point] of positions) {
      assert.ok(point.x >= 24 && point.x <= width - 24 && point.y >= gap / 2 && point.y <= height - gap / 2);
      assert.ok(Number.isFinite(point.x) && Number.isFinite(point.y));
      for (const [other, neighbor] of positions) {
        if (item === other || point.y !== neighbor.y) continue;
        assert.ok(Math.abs(point.x - neighbor.x) >= gap, 'Marker targets must not overlap');
      }
    }
  }
}
for (const shortHistory of [
  [{start: '2026-05-12'}],
  [{start: '2019-01-01'}, {start: '2026-12-31'}]
]) {
  const layout = timelineLayout(shortHistory, 320);
  assert.equal(layout.width, 320, 'Eight years or fewer must fit without overflow');
  assert.equal(layout.scrollLeft, 0, 'Short histories must not have an older-history scroll offset');
}
const longHistory = timelineLayout([{start: '2015-01-01'}, {start: '2026-12-31'}], 768);
assert.deepEqual(longHistory.years.filter(({x}) => x - longHistory.scrollLeft >= 24 - 1e-8).map(({year}) => year),
  [2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026], 'Longer histories must open on exactly eight years');
assert.ok(longHistory.scrollLeft > 0, 'Records older than eight years must remain scrollable');
const sameDay = [
  {kind: 'talk', start: '2026-08-12'},
  {kind: 'talk', start: '2026-08-12'},
  {kind: 'poster', start: '2024-01-24'}
];
const positions = timelineLayout(sameDay, 768).positions;
assert.equal(positions.get(sameDay[0]).x, positions.get(sameDay[1]).x, 'Same date must retain same x position');
assert.notEqual(positions.get(sameDay[0]).y, positions.get(sameDay[1]).y, 'Same-day outputs must stack');
assert.deepEqual(Object.keys(positions.get(sameDay[2])).sort(), ['x', 'y'], 'Layout must contain points only');
const differentTypes = [
  {kind: 'paper', start: '2020-04-09'},
  {kind: 'poster', start: '2023-06-06'},
  {kind: 'talk', start: '2026-08-12'}
];
const sharedAxis = timelineLayout(differentTypes, 768);
assert.ok([...sharedAxis.positions.values()].every(point => point.y === sharedAxis.axisY), 'Output types must share one axis, not separate rows');
console.log(`Timeline checks passed: ${items.length} outputs, source dates, categories, awards, passive tooltips, and collision-free layouts.`);

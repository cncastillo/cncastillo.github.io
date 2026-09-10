import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const source = readFileSync(new URL('../assets/js/research-timeline.js', import.meta.url), 'utf8');
const {initializeTimeline} = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);

// Minimal DOM fixture: exercise the production event handlers without a browser dependency.
class Element {
  children = [];
  listeners = {};
  attrs = {};
  selectors = {};
  dataset = {};
  style = {setProperty() {}};
  classList = {toggle() {}, contains() { return false; }};
  clientWidth = 1152;
  scrollLeft = 0;
  offsetWidth = 400;
  offsetHeight = 180;
  addEventListener(type, listener) { (this.listeners[type] ||= []).push(listener); }
  emit(type, properties = {}) { this.listeners[type]?.forEach(listener => listener({target: this, ...properties})); }
  querySelector(selector) { return this.selectors[selector] || this.children.map(child => child.querySelector?.(selector)).find(Boolean); }
  querySelectorAll(selector) { return this.selectors[selector] || []; }
  append(...nodes) { this.children.push(...nodes); }
  replaceChildren(...nodes) { this.children = nodes; }
  contains(node) { return node === this || this.children.some(child => child.contains?.(node)); }
  setAttribute(name, value) { this.attrs[name] = value; }
  getBoundingClientRect() { return this.bounds || {left: 0, top: 0, bottom: 32, width: 1152}; }
  matches(selector) { return selector === ':focus-visible' && this.focusVisible; }
  focus() { document.activeElement = this; this.emit('focus'); }
}

const root = new Element(), chart = new Element(), detail = new Element(), content = new Element();
const scroller = new Element();
const historyHint = new Element();
const markers = ['2015-01-01', '2023-03-06', '2023-03-06', '2023-03-07', '2025-12-01'].map(date => {
  const marker = new Element();
  marker.dataset = {date, kind: 'paper'};
  marker.selectors.template = {content: {cloneNode: () => new Element()}};
  return marker;
});
const marker = markers[1];
markers[4].dataset.kind = 'grant';
marker.bounds = {left: 500, top: 384, bottom: 416, width: 32};
markers[0].bounds = {left: 200, top: 16, bottom: 48, width: 32};
markers[4].bounds = {left: 900, top: 764, bottom: 796, width: 32};
chart.bounds = {left: 100, top: 100, bottom: 300, width: 1152};
scroller.bounds = chart.bounds;
detail.hidden = true;
detail.selectors = {'.timeline-detail-content': content};
detail.append(content);
chart.selectors['.timeline-years'] = new Element();
root.selectors = {'.timeline-chart': chart, '.timeline-scroll': scroller, '.timeline-detail': detail, '.timeline-point': markers, '.timeline-history-hint': historyHint};
root.append(chart, detail, scroller);
globalThis.document = new Element();
document.activeElement = null;
document.createElement = () => new Element();
globalThis.window = {innerHeight: 800, matchMedia: () => ({matches: false})};
let resize, observed;
globalThis.ResizeObserver = class {
  constructor(callback) { resize = callback; }
  observe(target) { observed = target; }
};
initializeTimeline(root);
const maxScroll = () => parseFloat(chart.style.width) - scroller.clientWidth;
assert.equal(observed, scroller, 'Resize observation must follow the viewport, not the expanding chart');
assert.ok(maxScroll() > 0, 'Older years must remain in a wider, scrollable chart');
assert.ok(Math.abs(scroller.scrollLeft - maxScroll()) < 1e-8, 'Timeline must open at the latest years');
assert.equal(historyHint.hidden, false, 'Scrolling hint must be available on desktop as well as mobile');
scroller.scrollLeft = maxScroll() * 0.4;
scroller.clientWidth = 768;
resize();
assert.ok(Math.abs(scroller.scrollLeft - maxScroll() * 0.4) < 1e-8, 'Resizing must preserve the browsed historical position');
scroller.scrollLeft = 0;
scroller.clientWidth = 320;
resize();
assert.equal(scroller.scrollLeft, 0, 'Resizing at the oldest end must not jump to the newest years');
scroller.scrollLeft = maxScroll();
scroller.clientWidth = 1152;
resize();
assert.ok(Math.abs(scroller.scrollLeft - maxScroll()) < 1e-8, 'Resizing at the newest end must keep the latest years visible');
const expanded = () => markers.filter(button => button.attrs['aria-expanded'] === 'true');
const hover = (button, y = 400, pointerType = 'mouse') => button.emit('pointerenter', {
  pointerType, clientX: chart.bounds.left + parseFloat(button.style.left), clientY: y
});

chart.emit('pointerenter', {pointerType: 'mouse', clientX: 200, clientY: 400});
chart.emit('pointermove', {pointerType: 'mouse', clientX: 600, clientY: 400});
assert.equal(detail.hidden, true, 'Hovering empty chart space must not select an output');
hover(marker);
assert.equal(detail.hidden, false, 'Hover must show details');
assert.deepEqual(expanded(), [marker], 'Hover must show only one output, never a nearby group');
assert.equal(content.children.length, 1, 'Only one output template must be cloned');
assert.equal(detail.style.top, '364px', 'Tooltip bottom must be anchored 36px above the marker center');
const cards = content.children;
hover(marker, 384);
assert.equal(content.children, cards, 'Vertical movement must not change or rebuild hover details');
assert.equal(detail.style.top, '364px', 'Tooltip must stay still while the same icon is hovered');
marker.emit('pointerleave');
hover(marker, 416);
assert.equal(detail.style.top, '364px', 'Pointer entry height must not change the marker-relative gap');
hover(markers[0], 30);
assert.equal(detail.style.top, '-4px', 'Tooltip must stay above the marker even near the viewport top');
hover(markers[4], 780);
assert.equal(detail.style.top, '744px', 'Lower markers must retain the same fixed gap');
detail.offsetHeight = 1000;
hover(marker);
assert.equal(detail.style.top, '364px', 'Tooltip height must not change its bottom anchor');
detail.offsetHeight = 180;
root.bounds = {left: 0, top: 100, bottom: 900, width: 1152};
hover(marker);
assert.equal(detail.style.top, '264px', 'Position must be relative to the timeline container');
delete root.bounds;
hover(markers[0]);
hover(marker);
marker.emit('pointerleave');
assert.equal(detail.hidden, true, 'Leaving an icon must close details immediately');

for (const button of markers) {
  hover(button);
  assert.deepEqual(expanded(), [button], 'Direct hover must show exactly that output, including same-day works');
  button.emit('pointerleave');
  assert.equal(detail.hidden, true, 'Every icon must dismiss its tooltip immediately on leave');
}
assert.equal(marker.attrs['aria-expanded'], 'false');

hover(marker);
marker.emit('pointerleave', {relatedTarget: detail});
detail.emit('pointerenter');
assert.equal(detail.hidden, true, 'Moving from the icon onto the tooltip must not keep it open');

hover(marker);
let navigationCanceled = false;
marker.emit('click', {preventDefault() { navigationCanceled = true; }});
assert.equal(navigationCanceled, false, 'Clicks must preserve native fragment-link navigation');
assert.equal(detail.hidden, true, 'Clicking an icon must close its tooltip before navigating to the entry');
marker.emit('pointerleave');
assert.equal(detail.hidden, true, 'Clicking must not pin the tooltip after leaving the icon');
hover(marker);
hover(markers[4]);
assert.deepEqual(expanded(), [markers[4]], 'Hovering another icon must always show that work');
markers[4].emit('pointerleave');

marker.focusVisible = true;
marker.focus();
assert.deepEqual(expanded(), [marker], 'Keyboard focus must still address individual outputs');
scroller.emit('scroll');
assert.equal(detail.hidden, false, 'Scrolling a keyboard-focused older item into view must preserve its details');
marker.emit('pointerleave');
assert.equal(detail.hidden, false, 'Keyboard-focused details must remain available');
root.emit('keydown', {key: 'Escape'});
assert.equal(detail.hidden, true, 'Escape must close details');
assert.equal(document.activeElement, marker, 'Escape must leave keyboard focus on the icon');
marker.focus();
marker.emit('blur');
assert.equal(detail.hidden, true, 'Leaving keyboard focus must close details');
marker.focusVisible = false;
hover(marker);
marker.emit('pointerleave');
assert.equal(detail.hidden, true, 'Old mouse focus must not keep hover details open');
hover(marker, 110, 'touch');
assert.equal(detail.hidden, true, 'Touch scrolling must not open hover details');
marker.emit('click');
assert.equal(detail.hidden, true, 'Tapping a marker must navigate without leaving a tooltip open');
hover(marker);
document.emit('pointerdown', {target: chart});
assert.equal(detail.hidden, true, 'Tapping empty chart space must close touch details');
hover(marker);
scroller.emit('scroll');
assert.equal(detail.hidden, true, 'Horizontal scrolling must dismiss a displaced popup');

console.log('Timeline interactions passed: recent-years viewport, resize and scroll behavior, direct icon hover, tooltip positioning, immediate dismissal, no pinning or popup hover, keyboard, and touch.');

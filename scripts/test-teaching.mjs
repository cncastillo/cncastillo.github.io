import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {resolve} from 'node:path';

const site = process.argv[2];
const html = readFileSync(resolve(site, 'teaching/index.html'), 'utf8');
const css = readFileSync(resolve(site, 'assets/css/site.css'), 'utf8');
assert.ok(html.includes('class="content-page teaching-page"'), 'Teaching must have its own layout scope');
assert.match(css, /\.teaching-page\s*\{\s*max-width: 56rem;/, 'Teaching header and body must share one width constraint');
assert.match(css, /\.prose-wide\s*\{\s*max-width: 56rem;/, 'Teaching container must match the existing body width');
assert.match(css, /\.teaching-page > \.prose\s*\{\s*padding-top: 0;/, 'Teaching menu must sit directly below the header divider');
assert.match(css, /\.mentorship-logo\s*\{[^}]*filter: grayscale\(1\);/, 'Mentorship logos must be displayed in grayscale');
assert.match(html, /<\/header>\s*<div class="prose prose-wide">\s*<nav class="section-nav"/, 'Menu must be the first element below the Teaching header');
const menu = html.match(/<nav class="section-nav"[^>]*>([\s\S]*?)<\/nav>/)[1];
assert.deepEqual([...menu.matchAll(/href="#([^"]+)"/g)].map(match => match[1]), ['courses', 'mentorship']);
for (const id of ['courses', 'mentorship']) assert.ok(html.includes(`id="${id}"`), `Missing menu target: ${id}`);
for (const page of ['publications', 'cv', 'teaching/bios-214']) {
  const other = readFileSync(resolve(site, page, 'index.html'), 'utf8');
  assert.ok(!other.includes('teaching-page'), `Teaching layout must not affect ${page}`);
}
console.log('Teaching layout checks passed: scoped width, aligned header/menu container, no extra menu gap, and valid section links.');

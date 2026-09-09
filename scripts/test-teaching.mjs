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
const logoStyle = css.match(/\.mentorship-logo\s*\{([^}]+)\}/)[1];
assert.match(logoStyle, /background-color: currentColor;/, 'Mentorship logos must inherit the text color');
assert.match(logoStyle, /mask: var\(--mentorship-logo\) center \/ contain no-repeat;/, 'Mentorship logos must use proportionally sized masks');
assert.ok(!logoStyle.includes('filter:'), 'Do not approximate the text color with a grayscale filter');
const logos = [...html.matchAll(/<span class="mentorship-logo" style="--mentorship-logo: url\('([^']+)'\);" aria-hidden="true"><\/span>/g)];
assert.ok(logos.length > 0, 'Mentorship logos must render as decorative masks');
assert.ok(!html.includes('<img class="mentorship-logo"'), 'Mentorship logos must not render as colored images');
for (const [, path] of logos) assert.ok(readFileSync(resolve(site, path.slice(1))).length > 0, `Missing logo mask: ${path}`);
assert.ok(logos.some(([, path]) => path.endsWith('/stanford-mono.svg')), 'Use the Stanford mask with transparent details');
assert.ok(logos.some(([, path]) => path.endsWith('/gsoc-mono.svg')), 'Use the GSoC mask with transparent code glyphs');
const institutionStyle = css.match(/\.course-institution-logo\s*\{([^}]+)\}/)[1];
assert.match(institutionStyle, /background-color: currentColor;/, 'Course institution icons must inherit the text color');
assert.match(institutionStyle, /mask: var\(--institution-logo\) center \/ contain no-repeat;/, 'Course institution icons must use proportionally sized masks');
const courseHtml = readFileSync(resolve(site, 'teaching/bios-214/index.html'), 'utf8');
for (const content of [html, courseHtml]) {
  assert.match(content, /<span class="course-institution-logo" style="--institution-logo: url\('\/assets\/icons\/stanford-som-mono\.svg'\);" aria-hidden="true"><\/span> Stanford School of Medicine/, 'Show the School of Medicine shield, not the university block-S, on the course card and header');
}
assert.ok(readFileSync(resolve(site, 'assets/icons/stanford-som-mono.svg')).length > 0, 'The course shield mask must be included in the build');
assert.match(html, /<\/header>\s*<div class="prose prose-wide">\s*<nav class="section-nav"/, 'Menu must be the first element below the Teaching header');
const menu = html.match(/<nav class="section-nav"[^>]*>([\s\S]*?)<\/nav>/)[1];
assert.deepEqual([...menu.matchAll(/href="#([^"]+)"/g)].map(match => match[1]), ['courses', 'mentorship']);
for (const id of ['courses', 'mentorship']) assert.ok(html.includes(`id="${id}"`), `Missing menu target: ${id}`);
for (const page of ['publications', 'cv', 'teaching/bios-214']) {
  const other = readFileSync(resolve(site, page, 'index.html'), 'utf8');
  assert.ok(!other.includes('teaching-page'), `Teaching layout must not affect ${page}`);
}
console.log('Teaching layout checks passed: scoped width, aligned header/menu container, no extra menu gap, and valid section links.');

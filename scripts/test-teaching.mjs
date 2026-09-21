import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {runInNewContext} from 'node:vm';

const site = process.argv[2];
const html = readFileSync(resolve(site, 'teaching/index.html'), 'utf8');
const css = readFileSync(resolve(site, 'assets/css/site.css'), 'utf8');
assert.ok(html.includes('class="content-page teaching-page"'), 'Teaching must have its own layout scope');
assert.match(css, /\.teaching-page\s*\{\s*max-width: 56rem;/, 'Teaching header and body must share one width constraint');
assert.match(css, /\.prose-wide\s*\{\s*max-width: 56rem;/, 'Teaching container must match the existing body width');
assert.match(css, /\.course-page \.course-content\s*\{\s*max-width: none;/, 'Course content must use the full course-page width without changing other prose');
assert.match(css, /\.teaching-page > \.prose\s*\{\s*padding-top: 0;/, 'Teaching menu must sit directly below the header divider');
const logoStyle = css.match(/\.mentorship-logo\s*\{([^}]+)\}/)[1];
assert.match(logoStyle, /width: 0\.75rem;\s*height: 0\.75rem;/, 'Mentorship logos must use the selected compact size');
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
assert.match(institutionStyle, /width: 1\.25rem;\s*height: 1\.25rem;/, 'Keep course institution icons at their existing size');
assert.match(institutionStyle, /background-color: currentColor;/, 'Course institution icons must inherit the text color');
assert.match(institutionStyle, /mask: var\(--institution-logo\) center \/ contain no-repeat;/, 'Course institution icons must use proportionally sized masks');
const courseHtml = readFileSync(resolve(site, 'teaching/bios-214/index.html'), 'utf8');
const courseIntro = courseHtml.match(/<div class="course-intro-grid">([\s\S]*?)<\/div>/)?.[1];
assert.ok(courseIntro, 'BIOS 214 must group its introductory sections in a grid');
assert.deepEqual([...courseIntro.matchAll(/<section aria-labelledby="([^"]+)">/g)].map(match => match[1]), ['overview', 'learning-goals']);
assert.match(courseIntro, /<h2 id="overview">Overview<\/h2>/, 'Keep the overview anchor');
assert.match(courseIntro, /<h2 id="learning-goals">Learning goals<\/h2>/, 'Keep the learning-goals anchor');
assert.equal((courseIntro.match(/<li>/g) || []).length, 6, 'Keep all six learning goals');
assert.match(css, /\.course-intro-grid \[aria-labelledby="learning-goals"\] ol\s*\{[^}]*font-size: 0\.85rem;/, 'Use a slightly smaller font only for the learning-goals list');
assert.match(courseHtml, /<\/section>\s*<\/div>\s*<h2 id="schedule">/, 'The schedule must remain below both columns');
assert.match(courseHtml, /<div class="course-schedule-scroll" role="region" aria-labelledby="schedule" tabindex="0">\s*<table>/, 'The schedule must have a labelled, keyboard-accessible scroll region');
assert.match(css, /\.course-schedule-scroll\s*\{\s*max-width: 100%;\s*overflow-x: auto;/, 'Keep schedule overflow inside the table region, not the page');
assert.match(css, /\.course-schedule-scroll table\s*\{\s*min-width: 48rem;/, 'Retain readable day columns on phones');
assert.ok(courseHtml.includes('Scroll sideways to see all days.'), 'Explain the mobile schedule scrolling');
assert.match(css, /\.course-session\s*\{\s*padding-inline-end: clamp\(0\.45rem, 0\.8vw, 0\.7rem\);/, 'Tighten label-to-link spacing without moving day columns');
assert.match(css, /\.course-content th:first-child\s*\{\s*width: clamp\(6rem, 8vw, 7rem\);/, 'Keep the week column compact but wide enough for unbroken week labels');
assert.match(css, /\.course-content th:not\(:first-child\),\s*\.course-content td:not\(:first-child\)\s*\{\s*padding-inline: clamp\(0\.75rem, 5vw, 4rem\);/, 'Use the space recovered from the week column for wider gaps between days');
assert.match(css, /@media \(max-width: 48rem\)[\s\S]*?\.course-content td:not\(:first-child\)\s*\{\s*padding-inline: 0\.75rem;/, 'Keep mobile day padding compact');
assert.match(css, /\.course-intro-grid\s*\{\s*display: grid;\s*grid-template-columns: repeat\(2, minmax\(0, 1fr\)\);/, 'Use two equal columns on wider screens');
assert.match(css, /@media \(max-width: 48rem\)[\s\S]*?\.course-intro-grid\s*\{\s*grid-template-columns: 1fr;/, 'Stack the introductory sections on mobile');
assert.match(courseHtml, /<script src="\/assets\/js\/course-start\.js" defer><\/script>/, 'Course pages must open below the site header');
assert.ok(!html.includes('course-start.js'), 'The course landing behavior must not affect the teaching index');
assert.match(css, /\.course-header\s*\{[^}]*scroll-margin-top: 1\.5rem;/, 'Leave a small gap above the course heading');
assert.match(css, /\.course-header h1\s*\{\s*font-size: clamp\(2rem, 4vw, 3\.25rem\);/, 'Long course titles must use a smaller responsive scale');
assert.match(css, /\.page-header h1\s*\{[^}]*font-size: clamp\(2\.7rem, 6vw, 5rem\);/, 'Keep other page titles at their existing size');
const courseStart = readFileSync(resolve(site, 'assets/js/course-start.js'), 'utf8');
for (const {hash = '', scrollY = 0, type = 'navigate', persisted = false, shouldScroll = false} of [
  {shouldScroll: true},
  {type: 'reload', shouldScroll: true},
  {hash: '#schedule'},
  {hash: '#setup'},
  {scrollY: 900, type: 'reload'},
  {type: 'back_forward'},
  {persisted: true}
]) {
  let onShow;
  let scrolled = false;
  runInNewContext(courseStart, {
    window: {scrollY, addEventListener: (name, callback, options) => {
      assert.equal(name, 'pageshow');
      assert.equal(options.once, true);
      onShow = callback;
    }},
    location: {hash},
    performance: {getEntriesByType: () => [{type}]},
    document: {querySelector: selector => {
      assert.equal(selector, '.course-header');
      return {scrollIntoView: options => {
        assert.equal(options.behavior, 'instant', 'Do not animate the initial scroll');
        assert.equal(options.block, 'start');
        scrolled = true;
      }};
    }}
  });
  onShow({persisted});
  assert.equal(scrolled, shouldScroll, `Course landing behavior: ${JSON.stringify({hash, scrollY, type, persisted})}`);
}
const courseNote = courseHtml.match(/<aside class="course-program" role="note" aria-label="Course affiliation">([\s\S]*?)<\/aside>/)?.[1];
assert.ok(courseNote, 'The course must have a separate affiliation footnote');
assert.match(courseNote, /A Stanford School of Medicine mini-course[\s\S]*<a href="https:\/\/oge\.stanford\.edu\/academics\/mini-courses-overview\/">Office of Graduate Education<\/a>/, 'Preserve the linked program description in the footnote');
assert.equal((courseHtml.match(/class="course-program"/g) || []).length, 1, 'Show the program description once');
assert.match(courseHtml, /<\/div>\s*<aside class="course-program"[^>]*>[\s\S]*?<\/aside>\s*<\/article>/, 'Place the footnote after the course content, inside the course article');
assert.equal(courseHtml.match(/<footer class="site-footer">[\s\S]*?<\/footer>/)?.[0], html.match(/<footer class="site-footer">[\s\S]*?<\/footer>/)?.[0], 'Keep the standard site footer unchanged');
for (const content of [html, courseHtml]) {
  assert.match(content, /<span class="course-institution-logo" style="--institution-logo: url\('\/assets\/icons\/stanford-som-mono\.svg'\);" aria-hidden="true"><\/span> Stanford School of Medicine/, 'Show the School of Medicine shield, not the university block-S, on the course card and header');
}
assert.ok(readFileSync(resolve(site, 'assets/icons/stanford-som-mono.svg')).length > 0, 'The course shield mask must be included in the build');
assert.match(html, /<\/header>\s*<div class="prose prose-wide">\s*<nav class="section-nav"/, 'Menu must be the first element below the Teaching header');
const menu = html.match(/<nav class="section-nav"[^>]*>([\s\S]*?)<\/nav>/)[1];
assert.deepEqual([...menu.matchAll(/href="#([^"]+)"/g)].map(match => match[1]), ['courses', 'mentorship']);
const courseCount = [...html.matchAll(/<article class="course-card(?: |")/g)].length;
const menteeCount = [...html.matchAll(/<article class="archive-item mentorship-person"/g)].length;
assert.ok(menu.includes(`Courses&nbsp;<sup class="section-count">${courseCount}</sup>`), 'Course count must match rendered courses');
assert.ok(menu.includes(`Mentees&nbsp;<sup class="section-count">${menteeCount}</sup>`), 'Mentee count must count each person once');
assert.ok(html.includes('<h2 id="mentorship-heading">Mentees</h2>'), 'Section heading must match the Mentees menu label');
assert.match(html, /<h2 id="courses">Courses<\/h2>\s*<div class="course-list">/, 'Courses must have a matching section heading above the cards');
for (const id of ['courses', 'mentorship']) assert.ok(html.includes(`id="${id}"`), `Missing menu target: ${id}`);
for (const page of ['publications', 'cv', 'teaching/bios-214']) {
  const other = readFileSync(resolve(site, page, 'index.html'), 'utf8');
  assert.ok(!other.includes('teaching-page'), `Teaching layout must not affect ${page}`);
}
for (const page of ['index.html', 'publications/index.html', 'cv/index.html']) {
  assert.ok(!readFileSync(resolve(site, page), 'utf8').includes('course-start.js'), `Course landing behavior must not affect ${page}`);
}
console.log('Teaching layout checks passed, including course landing scroll, section links, and history restoration.');

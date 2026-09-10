# Academic website

A small Jekyll site for GitHub Pages. **Edit YAML for records and Markdown for pages.** No TOML converter, database service, or extra build plugin is needed.

## Where to edit

| Content | File |
| --- | --- |
| Name, biography, affiliation, email, portrait, profile links, favicon | `_data/profile.yml` |
| Journal articles, proceedings papers, book chapters | `_data/publications.yml` |
| Abstracts, conference talks, invited talks, seminars | `_data/presentations.yml` |
| Research and open-source mentorships | `_data/mentorship.yml` |
| Grants and research funding | `_data/grants.yml` |
| Selected projects and their overview text | `_highlights/*.md` |
| Courses, notes, schedules, and public materials | `teaching/<course-slug>/*.md` |
| CV education, teaching, and awards | `_cv/cv.tex` |
| Domain, website repository link, base path, language, and timezone | `_config.yml` |

The two record files are the only sources for publication/presentation metadata. The archive, distinctions, project records, counts, and generated CV all read them. Do not copy a title, byline, paper URL, or award into another record just to display it elsewhere.

The experimental research timeline on `/publications/` reads those same records plus `_data/grants.yml`. It opens on up to the latest eight calendar years in the records; scroll left within the timeline to see earlier work. Set `show_timeline: false` in `publications/index.html` to hide it and stop loading its CSS/JavaScript. Papers use publication dates; abstracts and talks use presentation dates, falling back to the conference's first day when only conference dates are known. Grants use funding decision dates and a gold hexagon marker; gold denotes awards and funding. All markers display a single date; undated entries are omitted. Recognition markers refer to the work, not the date the award was received. Hover or focus an icon to preview that individual record; click, tap, or press Enter to scroll to its full entry on the same page. The tooltip has no controls and cannot be pinned or hovered: leaving the icon closes mouse-triggered details immediately. Keyboard details remain until focus leaves the icon, Escape is pressed, or the link is followed.

The LaTeX CV remains a deliberate exception: its header, education, teaching, and awards are edited there. Its publication/presentation/book, mentorship, and grant lists are generated from YAML.

## Update your profile

Edit `_data/profile.yml`. `name` updates the home heading, navigation, footer, browser titles, and CV-preview label. `author_names` lists the exact byline variants to emphasize on the website and in generated CV entries; use full name variants, not individual surname fragments.

`bio` is a list of paragraphs and supports Markdown links and emphasis. Change `photo` and `photo_alt` to use your own portrait. The favicon is a 128×128 PNG.

`description` is the short plain-text summary used for search and link previews. It is separate from the homepage biography. A page's Markdown front matter can set its own `description`.

Profile links need `label` and `url`; `icon` is optional. Remove `blog_url` to hide Blog. The archive's ORCID link uses the profile link labeled `ORCID` and is hidden if that link is removed.

## Add a paper or book chapter

Append one record to `_data/publications.yml`. It may go anywhere in the file; display order follows the year, newest first.

```yaml
- record_key: my-paper-2027
  category: peer_reviewed
  year: 2027
  type: Journal article
  title: "My paper title"
  authors: >-
    First Author, Your Full Name, and Last Author
  venue: Journal name
  paper: https://doi.org/your-doi
```

Required fields are shown above except `paper`, which may be omitted until a real URL is available. Keep the complete author list in source order, without “et al.” Quote titles containing a colon; `>-` lets long bylines wrap over several indented lines.

For a book chapter, use `category: book` and `type: Book chapter` (or `Book chapter · In press`). It appears in its own section, not among peer-reviewed papers.

Optional fields: `code`, `note`, `abstract_key`, `recognitions`, image metadata, and `order`. `order` is an integer tie-breaker within a year; smaller values come first and records without it come last. No renumbering is needed when adding a new year.

For timeline metadata, add the first online publication date and its source. Prefer the publisher's article page, PDF, or deposited Crossref record; use a bibliographic index such as PubMed when the publisher is unavailable:

```yaml
  date: "2026-11-18"
  date_source: https://publisher.example/my-paper
```

Keep `year` as the citation/issue year, even if online publication was earlier. Dates are metadata only and do not change the website or CV display. Use quoted ISO dates (`YYYY-MM-DD`); omit `date` for an in-press work or an unconfirmed day. An optional `date_note` can explain a source discrepancy. Do not use acceptance, indexing, or scheduled release dates as actual publication dates.

## Add a presentation

Append one record to `_data/presentations.yml`:

```yaml
- record_key: my-talk-2027
  category: conference
  year: 2027
  kind: Oral presentation
  title: "My talk title"
  authors: Your Full Name
  event: Conference name 2027
  location: City, Country
  abstract: https://conference.example/my-talk
```

Use `category: abstract` for conference abstracts, `conference` for conference talks, or `invited` for invited talks and seminars. These categories organize the archive. Set `kind` to the presentation format, such as Traditional poster, Digital poster, Oral presentation, Power pitch, or Invited educational talk. The timeline uses circles for papers, squares for posters, triangles for other talks (including power pitches), and diamonds for `category: invited` talks and seminars; its hover details retain the specific format and invitation status. `abstract` remains the link to the written submission, not a timeline format.

`location`, `abstract`, `slides`, `code`, `note`, and `publication_key` are optional. Use complete authors for abstracts and the speakers for talks. Omit unavailable links rather than inserting placeholders.

Presentation dates are **metadata only**; the website and CV still display the year. Add an exact presentation day with its official program URL (or `Speaker confirmation`):

```yaml
  date: "2027-05-12"
  date_source: https://conference.example/program/my-talk
```

If only the conference dates are confirmed, omit `date` and keep the conference dates as metadata. The timeline uses the first day without displaying a range:

```yaml
  event_start: "2027-05-10"
  event_end: "2027-05-14"
  date_source: https://conference.example/program
  date_note: Conference dates only; exact presentation day not yet confirmed.
```

Always quote ISO dates (`YYYY-MM-DD`). Do not substitute a conference start date or an abstract's journal publication date for the presentation day. Optional `date_note`, `hosts` (a list of names), and `format` (`in_person` or `online`) are also metadata only. These fields do not change the display order, which remains newest year first, then `order` within each year.

## Connect related records

Every publication, presentation, and grant needs a unique, stable `record_key` across those YAML files. Titles can change without changing this ID.

To connect a paper and an abstract, add `abstract_key: my-abstract-2027` to the paper and `publication_key: my-paper-2027` to the abstract. This supplies their links everywhere and lets the abstract inherit the paper's code URL. Each URL is stored only on its own record.

If a paper has several abstracts, keep each abstract as its own record with `publication_key`. The paper's optional `abstract_key` chooses one primary Abstract link; a project can list all the related outputs.

## Add a grant

Append to `_data/grants.yml`; the Research page, compact homepage funding section, and CV all read this file. Homepage summaries link to the full Research entries, and the homepage menu count updates automatically:

```yaml
- record_key: my-grant-2027
  year: 2027
  funder: Funding organization
  program: Grant program
  organization: Supported project or institution
  title: Funded project title
  amount: USD 10,000
  role: Your confirmed role
  url: https://example.org/funded-project
```

`amount`, `role`, and `url` are optional. An optional `blog` URL adds a Blog post link on the website and CV. State the currency with the amount and use the total project funding, not a personal award amount. Use the funding decision year in `year`. Add an optional quoted ISO `date` with its `date_source` and, if needed, `date_note`; dated grants appear on the timeline with their exact funding dates in hover details, while the archive and CV display the year. Optional integer `order` breaks ties within a year. Entries appear newest first; `[]` hides the website section and menu item. Grants do not contribute to paper/abstract award counts. Related mentorships may remain under Teaching & Mentorship with their own activity years.

## Add recognition or an image

Put recognition on the exact paper or abstract that received it:

```yaml
  recognitions:
    - year: 2027
      label: Best Abstract Award
```

It then appears on the home page, publications page, and related project overview. Award counts total individual recognitions, not distinct awarded works. Omit `recognitions` or use `[]` when there are none.

For an awarded-work preview, add:

```yaml
  image: /assets/images/my-paper.jpg
  image_alt: Description of the medical result
  image_source: https://journal.example/exact-figure
```

Use images from that exact output. Prefer medical-result images over pulse-sequence diagrams. Preserve source, credit, and license metadata when available. A project's representative image is independent and can represent any of its related outputs.

Optional `cv_badge: badge.png` uses a badge stored in `_cv/assets/` next to that CV entry. The separate awards section in the LaTeX CV is edited manually.

## Add or edit a selected project

Copy `_templates/project.md` to `_highlights/my-project.md` and replace its example fields. The filename determines its overview URL. All files in this folder appear under Selected projects.

Keep the narrative under **Why it matters** and **Contribution**. Put the representative image, summary, start/end years, and optional current institution in the front matter. Use `end_year: Present` for ongoing work. `order` controls the curated homepage order.

Connect outputs by ID:

```yaml
related_outputs:
  - kind: publication
    key: my-paper-2027
  - kind: presentation
    key: my-talk-2027
```

The same output may belong to multiple projects. Adding a paper to the database puts it in the archive and CV automatically; adding its ID here deliberately associates it with a selected project.

The first **publication** in this list supplies the main Paper and Code links at the top. Optional project `links` can supply Documentation. The project record below is independently sorted newest first. Overview counts come from this list.

Do not change IDs or remove records without updating references. Validation reports missing or duplicate IDs before CI builds the site.

## Add a course or teaching material

Copy `_templates/course.md` to `teaching/my-course/index.md` and edit its front matter and Markdown. It appears on the teaching index automatically; no HTML edit is needed.

Use the optional `program` field for a small program/department footnote beneath the course content, separate from the site footer, with Markdown links if useful. The `sections` list controls the course menu. Its anchors must match the page headings (`## Materials` → `#materials`).

Optional `institution_logo` points to a local transparent logo mask, displayed beside `institution` in the text color on the course card and course header.

The optional `instructors` field appears as a byline below the course title and supports Markdown, for example `instructors: "**Your Name** and Co-instructor"`.

Add lecture notes below the course folder as Markdown with `layout: page` and a `title`, then link them from the course page. Link slides, notebooks, and downloads the same way. Keep submissions, grades, and private student material in Canvas or another course system.

For BIOS 214, edit the materials table in `teaching/bios-214/index.md`: one row per week, with Monday/Wednesday/Friday columns. The table uses HTML to merge the Thanksgiving break cells; each teaching cell has `markdown="span"`, so its contents and links remain editable in Markdown. Keep the `course-day-header` and `course-session` spans in place; they handle alignment. Mark room exceptions with `<sup>*</sup>` beside the date and explain them in the classroom note below the table. Replace the whole `<a role="link" aria-disabled="true">Coming soon</a>` placeholder with a Markdown link such as `[Notes](week-1/monday/)` or `[Lab](week-1/friday/)` once those materials exist.

## Add a mentorship

Append to `_data/mentorship.yml`; the Teaching & Mentorship page and generated CV both read this file. Use one entry per person, program, and year, not one entry per unique person:

```yaml
- name: Student Name
  year: 2027
  home_affiliation: Home University, Country
  program: Google Summer of Code (GSoC)
  organization: Julia
  program_logo: /assets/icons/gsoc-mono.svg
  organization_logo: /assets/icons/julia.svg
  project: Public project title
  role: Co-mentor
  links:
    - label: Project
      url: https://example.org/project
    - label: Blog post
      url: https://example.org/post
```

Only `name`, `year`, `program`, and `organization` are required. Omit unpublished project details, unconfirmed roles, and unavailable links. Each optional `links` item needs a `label` and an HTTP(S) `url`; use it for project pages, posts, code, or tutorials. Optional `location` appears in the CV only. The teaching page groups entries by `name`, with each person's programs newest year first. Use the same name spelling across programs. Optional integer `order` controls person order (their first entry) and entries within a year; the CV remains newest year first. Use `[]` to hide mentorship from the teaching page when there are no entries. Do not duplicate entries in `_cv/cv.tex`.

Optional `program_logo` and `organization_logo` point to local assets and appear beside their text labels on the website only. They are rendered as alpha masks in the text color; use transparent backgrounds and cutouts. Omit them for a text-only entry. Logo sources and attribution are recorded in `assets/icons/LOGO-SOURCES.md`.

Optional `home_affiliation` records the mentee's university and its country during that mentorship, not the host organization or their nationality. It appears below their name on the website; identical affiliations across engagements appear only once. Omit it when unconfirmed.

## Check and preview

```sh
bundle install
ruby scripts/check-content.rb
bundle exec jekyll serve
```

Open <http://127.0.0.1:4000/>. YAML and Markdown changes are watched automatically. Restart the server after changing `_config.yml`.

Run the tests before publishing:

```sh
ruby scripts/test-content.rb
ruby scripts/test-cv.rb
bundle exec jekyll build --safe
```

Checks cover required fields, categories, integer years/order, complete bylines, duplicate IDs, broken paper/abstract/project references, image paths, mentorship and grant records, and CV generation. They do not verify scientific claims or whether an external URL is still available.

To check the experimental timeline after building, run `node scripts/test-timeline.mjs _site` (Node.js is only needed for these optional tests, not the site build). It checks record coverage, single-date markers, conference-start fallback, categories, awards, passive tooltip markup, marker spacing, and the eight-year viewport. Run `node scripts/test-timeline-interactions.mjs` to check scrolling and resize behavior, direct icon hover, tooltip positioning, immediate dismissal, keyboard focus, and touch behavior.

## CV and continuous integration

The CV's International conference participation section excludes records with `kind: Invited seminar` or `kind: Invited research-group talk`. Invited conference and educational talks remain included; all records remain on the website and timeline.

The supplied ModernCV layout lives in `_cv/cv.tex`. To rebuild locally, install TeX Live with ModernCV and `latexmk`, then run:

```sh
ruby scripts/test-cv.rb
latexmk -pdf -no-shell-escape -file-line-error -halt-on-error -interaction=nonstopmode -cd -outdir=build -jobname=carlos-castillo-passi-cv _cv/cv.tex
cp _cv/build/carlos-castillo-passi-cv.pdf assets/cv/carlos-castillo-passi-cv.pdf
```

`_cv/build/` is generated and ignored. Source files, scripts, and templates are excluded from the published site. The repository itself is public: never put private details in source files, even in comments.

The checked-in PDF supports local previews; updating a record does not automatically rebuild that local PDF. CI validates content, generates the CV lists from YAML, compiles a fresh PDF, builds Jekyll, and uploads the PDF as a workflow artifact. Only successful runs on `master` deploy; pull requests never deploy or commit generated files.

Before the first deployment, select **Settings → Pages → Build and deployment → Source → GitHub Actions**. The workflow does not change that setting automatically.

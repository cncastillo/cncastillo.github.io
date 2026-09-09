# Academic website

A small Jekyll site for GitHub Pages. **Edit YAML for records and Markdown for pages.** No TOML converter, database service, or extra build plugin is needed.

## Where to edit

| Content | File |
| --- | --- |
| Name, biography, affiliation, email, portrait, profile links, favicon | `_data/profile.yml` |
| Journal articles, proceedings papers, book chapters | `_data/publications.yml` |
| Abstracts, conference talks, invited talks, seminars | `_data/presentations.yml` |
| Selected projects and their overview text | `_highlights/*.md` |
| Courses, notes, schedules, and public materials | `teaching/<course-slug>/*.md` |
| CV education, teaching, grants, awards, and mentoring | `_cv/cv.tex` |
| Domain, website repository link, base path, language, and timezone | `_config.yml` |

The two record files are the only sources for publication/presentation metadata. The archive, distinctions, project records, counts, and generated CV all read them. Do not copy a title, byline, paper URL, or award into another record just to display it elsewhere.

The LaTeX CV remains a deliberate exception: its header and non-publication sections are edited there. Its publication/presentation/book lists and author emphasis are generated from YAML.

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

## Add a presentation

Append one record to `_data/presentations.yml`:

```yaml
- record_key: my-talk-2027
  category: conference
  year: 2027
  kind: Conference talk
  title: "My talk title"
  authors: Your Full Name
  event: Conference name 2027
  location: City, Country
  abstract: https://conference.example/my-talk
```

Use `category: abstract` for conference abstracts, `conference` for conference talks, or `invited` for invited talks and seminars. `kind` is the visible label, such as Oral presentation, Power pitch, or Invited educational talk.

`location`, `abstract`, `slides`, `code`, `note`, and `publication_key` are optional. Use complete authors for abstracts and the speakers for talks. Omit unavailable links rather than inserting placeholders.

## Connect related records

Every record needs a unique, stable `record_key` across both YAML files. Titles can change without changing this ID.

To connect a paper and an abstract, add `abstract_key: my-abstract-2027` to the paper and `publication_key: my-paper-2027` to the abstract. This supplies their links everywhere and lets the abstract inherit the paper's code URL. Each URL is stored only on its own record.

If a paper has several abstracts, keep each abstract as its own record with `publication_key`. The paper's optional `abstract_key` chooses one primary Abstract link; a project can list all the related outputs.

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

Use the optional `program` field for the official program/department description at the end of the course page, with Markdown links if useful. The `sections` list controls the course menu. Its anchors must match the page headings (`## Materials` → `#materials`).

The optional `instructors` field appears as a byline below the course title and supports Markdown, for example `instructors: "**Your Name** and Co-instructor"`.

Add lecture notes below the course folder as Markdown with `layout: page` and a `title`, then link them from the course page. Link slides, notebooks, and downloads the same way. Keep submissions, grades, and private student material in Canvas or another course system.

For BIOS 214, edit the materials table in `teaching/bios-214/index.md`: one row per week, with Monday/Wednesday/Friday columns. The table uses HTML to merge the Thanksgiving break cells; each teaching cell has `markdown="span"`, so its contents and links remain editable in Markdown. Keep the `course-day-header` and `course-session` spans in place; they handle alignment. Mark room exceptions with `<sup>*</sup>` beside the date and explain them in the classroom note below the table. Replace the whole `<a role="link" aria-disabled="true">Coming soon</a>` placeholder with a Markdown link such as `[Notes](week-1/monday/)` or `[Lab](week-1/friday/)` once those materials exist.

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

Checks cover required fields, categories, integer years/order, complete bylines, duplicate IDs, broken paper/abstract/project references, image paths, and CV generation. They do not verify scientific claims or whether an external URL is still available.

## CV and continuous integration

The supplied ModernCV layout lives in `_cv/cv.tex`. To rebuild locally, install TeX Live with ModernCV and `latexmk`, then run:

```sh
ruby scripts/test-cv.rb
latexmk -pdf -no-shell-escape -file-line-error -halt-on-error -interaction=nonstopmode -cd -outdir=build -jobname=carlos-castillo-passi-cv _cv/cv.tex
cp _cv/build/carlos-castillo-passi-cv.pdf assets/cv/carlos-castillo-passi-cv.pdf
```

`_cv/build/` is generated and ignored. Source files, scripts, and templates are excluded from the published site. The repository itself is public: never put private details in source files, even in comments.

The checked-in PDF supports local previews; updating a record does not automatically rebuild that local PDF. CI validates content, generates the CV lists from YAML, compiles a fresh PDF, builds Jekyll, and uploads the PDF as a workflow artifact. Only successful runs on `master` deploy; pull requests never deploy or commit generated files.

Before the first deployment, select **Settings → Pages → Build and deployment → Source → GitHub Actions**. The workflow does not change that setting automatically.

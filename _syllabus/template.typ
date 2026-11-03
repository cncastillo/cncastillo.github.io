#let komablue = rgb("#2a7fb8")
#let komacharcoal = rgb("#4b4b4b")
#let komagray = rgb("#929292")
#let komatint = rgb("#eaf3f9")
#let icon(name) = box(baseline: 20%, image("/assets/icons/" + name + ".svg", width: 10pt, height: 10pt))

#set document(title: "$title$ | Syllabus", author: "$institution$")
#set text(font: "Latin Modern Sans", size: 10.5pt, fill: komacharcoal, hyphenate: false)
#set par(leading: 5pt, spacing: 8pt)
#show table: set par(spacing: 8pt)
#set page(
  paper: "us-letter",
  margin: (top: 0.55in, bottom: 0.65in, x: 0.65in),
  header: context {
    if counter(page).get().first() > 1 {
      text(font: "Latin Modern Roman", size: 9pt, fill: komagray)[
        #grid(columns: (1fr, auto), upper([$code$ · Syllabus]), upper([$term$]))
      ]
    }
  },
  footer: context text(size: 8pt, fill: komagray)[
    #grid(
      columns: (1fr, 1fr, 1fr),
      [Carlos Castillo-Passi, Ph.D.],
      align(center)[Updated $revision-date$],
      align(right, counter(page).display()),
    )
  ],
)
#set heading(numbering: none)
#show heading.where(level: 2): it => block(above: 22pt, below: 14pt, sticky: true)[
  #text(size: 11.5pt, weight: "bold", fill: komablue)[#it.body]
]
#show link: set text(fill: komablue)
#set enum(indent: 15pt, body-indent: 5pt, spacing: 5pt, tight: false)

#let logo-unit = 180pt / 334.8
#grid(
  columns: (1fr, auto),
  align: left + horizon,
  // Offset the SVG's horizontal canvas padding without changing the artwork.
  box(width: 180pt, height: 20pt, move(dx: -19.5 * logo-unit, dy: 6pt,
    image("$institution_wordmark$", width: 180pt))),
  text(font: "Latin Modern Roman", size: 9pt, fill: komagray)[#upper([$term$])],
)
#v(46pt, weak: false)
#text(font: "Latin Modern Roman", size: 9pt, fill: komagray)[SYLLABUS]
#v(4pt)
#text(font: "Latin Modern Roman", size: 22pt)[$title$]
#v(3pt)
#text(font: "Latin Modern Roman", size: 18pt)[$subtitle$]
#v(14pt, weak: false)

$body$

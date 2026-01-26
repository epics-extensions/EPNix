#import "common.typ": *

#let html_baseurl = state("html_baseurl")

// Resolve missing links to the HTML documentation
//
// This transforms a destination like "document:ioc:tutorials:streamdevice"
// to "<url>/ioc/tutorials/streamdevice.html"
#let missing_link(dest, body) = {
  if dest.starts-with("%") {
    let (path, ..rest) = dest
      .trim("%", at: start)
      .replace(":", "/")
      .split("#")
    let path = (path + ".html", ..rest).join("#")
    context link(
      html_baseurl.get() + path,
      body,
    )
  } else {
    text(red, body)
  }
}

// Inspired by cram-snap

#let template(
  metadata: (),
  doc,
) = {
  let title = metadata.at("title")
  let author = metadata.at("author")
  let date = get_date(metadata.at("date", default: none))
  let language = metadata.at("language")
  let copyright = metadata.at("copyright")
  let release = metadata.at("release")

  html_baseurl.update(metadata.at("html_baseurl"))

  let icon = image("../../../../_static/logo.png")
  let column-number = 2
  let fill-color = "F2F2F2"

  set text(lang: language, size: 10pt)

  set page(
    paper: "a4",
    flipped: true,
    margin: 1cm,
    footer: [
      Version #release, #date.display()
      #h(1fr)
      Copyright © #copyright
    ],
  )

  set document(
    title: title,
    author: author,
    date: date,
  )

  // show heading.where(level: 1): it => {{ pagebreak(weak: true); it }}
  show link: underline

  // Content

  let table_stroke(color) = (
    (x, y) => (
      left: none,
      right: none,
      top: none,
      bottom: if y == 0 {
        color
      } else {
        0pt
      },
    )
  )

  let table_fill(color) = (
    (x, y) => {
      if calc.even(y) {
        rgb(color)
      } else {
        none
      }
    }
  )

  set table(
    align: left + horizon,
    columns: (2fr, 3fr),
    fill: table_fill(rgb(fill-color)),
    stroke: none,
  )

  set table.header(repeat: false)

  show heading.where(level: 2): it => {
    block(
      it,
      width: 100%,
      stroke: (bottom: 1pt),
      inset: 3pt,
      outset: 3pt,
    )
  }

  columns(column-number)[
    #align(center)[
      #box(height: 1.8em)[
        #if icon != none {
          set image(height: 100%)
          box(icon, baseline: 20%)
        }
        #text(1.6em, title)
      ]
    ]

    #doc
  ]
}

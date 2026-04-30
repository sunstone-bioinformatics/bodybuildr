# bodybuildr

Build cool infographics in R by building the body row by row.

bodybuildr solves the annoying part of infographic work: layout. Instead
of fighting with absolute positioning, you stack flexible rows with
consistent lanes, gaps, and padding. Each row can be text, a plot, an
image, or a custom grob, and the whole thing exports cleanly to PDF.

The name is the point: you build the body one row at a time.

## Why bodybuildr?

- Compose complex infographics by stacking rows on a canvas.
- Mix text, ggplot2 objects, images, and grobs in the same row.
- Write cell content in plain text, **Markdown**, or **raw HTML**.
- Add native tables with selectable text — text-only or mixed content
  (plots, images, grobs).
- Control spacing with layout styles (lanes, gaps, margins) and box
  styles.
- Export to PDF with predictable sizing using grid units.

## Install

If the package is on CRAN:

``` r

install.packages("bodybuildr")
```

If you are installing from GitHub:

``` r

# install.packages("remotes")
remotes::install_github("sunstone-bioinformatics/bodybuildr")
```

## Quick start

``` r

library(bodybuildr)

# Build a banner
banner <- str_banner_row(
  image_path = "path/to/logo.png",
  title = "Project Title",
  subtitle = "Short, punchy summary"
)

# Add a subtitle band
subtitle <- str_subtitle_row(
  label = "Key Findings",
  layout_style = layout_style(
    type = "subtitle",
    outer_margin = grid::unit(10, "pt"),
    bottom_margin = grid::unit(6, "pt")
  ),
  text_style = text_style(color = "white", size = 14, face = "bold")
)

# Build a 3-column row with per-panel styling
row <- str_n_panel_row(
  items = list(
    blank_box(),
    "Centered middle text",
    blank_box()
  ),
  layout_style = layout_style(
    type = "columns",
    column_gap = grid::unit(8, "pt"),
    outer_margin = grid::unit(6, "pt"),
    bottom_margin = grid::unit(6, "pt")
  )
)

# Assemble the canvas row by row
canvas <- new_canvas()
canvas <- canvas_add_row(canvas, banner,   grid::unit(1.6, "in"))
canvas <- canvas_add_row(canvas, subtitle, grid::unit(0.9, "in"))
canvas <- canvas_add_row(canvas, row,      grid::unit(3.0, "in"))

# Export
export_pdf(canvas, file = "infographic.pdf")
```

## Core building blocks

**Row builders:** -
[`str_banner_row()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/str_banner_row.md)
— logo + title/subtitle banner -
[`str_subtitle_row()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/str_subtitle_row.md)
— full-width subtitle band -
[`str_n_panel_row()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/str_n_panel_row.md)
— 1..n equal-width columns -
[`str_three_panel_row()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/str_three_panel_row.md)
— asymmetric A \| (B over C) layout

**Cell content helpers:** -
[`text_box()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/text_box.md)
— plain text with per-cell style overrides -
[`md_text_box()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/md_text_box.md)
— Markdown text (bold, italic, lists, headings, links) -
[`html_text_box()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/html_text_box.md)
— raw HTML passed to gridtext (`<b>`, `<em>`, `<span style="...">`,
`<br/>`, `<sup>`, `<sub>`) -
[`blank_box()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/blank_box.md)
— intentional empty slot that still participates in layout

**Table helpers:** -
[`table_box()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/table_box.md)
— `data.frame` → native grid table with selectable text; columns fill
available width -
[`rich_table_box()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/rich_table_box.md)
— table where each cell can be text, image, ggplot, grob, or `NULL`

**Styling helpers:** -
[`text_style()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/text_style.md)
and
[`box_style()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/box_style.md)
— typography and box styling - `layout_style(type = ...)` — row spacing,
lanes, and backgrounds -
[`banner_layout_style()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/banner_layout_style.md),
[`column_layout_style()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/column_layout_style.md),
[`subtitle_layout_style()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/subtitle_layout_style.md),
[`three_panel_layout_style()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/three_panel_layout_style.md)
— row-specific aliases

**Canvas helpers:** -
[`new_canvas()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/new_canvas.md)
and
[`canvas_add_row()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/canvas_add_row.md)
— stack rows vertically -
[`export_pdf()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/export_pdf.md)
— write final PDF

## Rich text example

``` r

library(bodybuildr)

# Markdown cell
findings <- md_text_box(
  "**Key findings:**\n\n- Primary endpoint met (p < 0.001)\n- *n* = 1,204 patients\n- 12-month follow-up",
  box_style = box_style(fill = "#F0F9FF", border_color = "#BAE6FD")
)

# HTML cell with colored spans
status <- html_text_box(
  'Result: <span style="color:#16A34A;"><b>Met</b></span><br/>p-value: <b>0.0003</b>',
  box_style = box_style(fill = "#F0FDF4")
)

canvas <- new_canvas()
canvas <- canvas_add_row(canvas, str_n_panel_row(list(findings, status)), grid::unit(2, "in"))
export_pdf(canvas, file = "output.pdf")
```

## Table example

``` r

# Text-only table (selectable text in PDF)
tbl <- table_box(
  data.frame(Metric = c("n", "Mean age"), Value = c("1,204", "52.3")),
  header_fill = "#1E3A8A"
)

# Mixed-content table (text + plots + images per cell)
rtbl <- rich_table_box(
  headers = c("Gene", "Trend", "Status"),
  rows = list(
    list("BRCA1", my_sparkline_plot, "path/to/green_dot.png"),
    list("TP53",  another_plot,      "path/to/red_dot.png")
  ),
  col_widths = c(2, 3, 1),
  row_height = grid::unit(0.5, "in")
)

canvas <- new_canvas()
canvas <- canvas_add_row(canvas, str_n_panel_row(list(tbl, rtbl)), grid::unit(3, "in"))
export_pdf(canvas, file = "output.pdf")
```

## Notes

- Uses grid units ([`grid::unit`](https://rdrr.io/r/grid/unit.html)) for
  sizing; keep units consistent.
- ggplot2 support is optional; install it to render plots in rows.
- [`table_box()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/table_box.md)
  and
  [`rich_table_box()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/rich_table_box.md)
  require `gridExtra`;
  [`md_text_box()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/md_text_box.md)
  requires `commonmark`.

## Cairo and PDF rendering

[`export_pdf()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/export_pdf.md)
uses [`cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html) when
available for full UTF-8 support (bullet points, accented characters,
rich text from
[`md_text_box()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/md_text_box.md)
and
[`html_text_box()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/html_text_box.md)).
Without Cairo it falls back to
[`pdf()`](https://rdrr.io/r/grDevices/pdf.html), which may substitute
some characters.

| Platform | Status | Fix |
|----|----|----|
| Windows | Built into R | Nothing needed |
| Linux | Usually present | `sudo apt install libcairo2-dev` then reinstall R |
| macOS | Requires XQuartz | Install from <https://www.xquartz.org> and restart R |

Verify Cairo is active: `capabilities("cairo")` should return `TRUE`.

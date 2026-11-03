# bodybuildr

Build infographic-style PDF pages in R from blocks that size themselves.

bodybuildr handles the annoying part of report and profile layout: deciding
how tall everything is. Each piece of a page is a *block* that knows its
height at the width it gets. You stack blocks, split them into columns, and
place them between a page header and a footer that stays pinned to the bottom
margin. No absolute coordinates, no hand-tuned row heights, and translated
text that runs longer just makes the block taller.

## Why bodybuildr?

- **Self-sizing layout.** `bb_stack()` and `bb_cols()` pass widths down and
  collect heights up. Plots stretch to match their neighbours.
- **Real pages.** `page_template()` gives margins, a running header, and a
  footer anchored to the bottom with `{page} / {pages}` numbering.
  `export_pdf()` writes a whole document to one PDF.
- **Editorial tables.** `bb_table()` draws rules-only or boxed tables with
  rows that grow with wrapped text, per-column styles and alignment, and any
  block as a cell (status icons, dots, images). Side-by-side tables can share
  row heights.
- **Typography that holds up.** `text_style()` supports weights such as 600
  (through the installed font face), line height and letter case; themes
  define every text role once.
- **Mixed content.** Text (plain, Markdown, HTML), inline `span()`s and
  underlined `link()`s, ggplot2 plots, images, grobs, legends, status marks,
  banners, section headers and patterned placeholders.

## Install

```r
# install.packages("remotes")
remotes::install_github("sunstone-bioinformatics/bodybuildr")
```

## Quick start

```r
library(bodybuildr)

template <- page_template(
  margin_x = 0.5,
  header   = bb_running_header("Immunization Profile", "{country}, 2025"),
  footer   = bb_page_footer("Organisation, 2026", "{country} · {page} / {pages}")
)

indicators <- bb_table(
  list(
    list("Total population",  "45,696,159"),
    list("Surviving infants", "530,193"),
    list("Skilled birth attendance", cell("No data", text_style(color = "faint")))
  ),
  widths = c(2, 1), align = c("left", "right"),
  col_style = list(NULL, text_style(weight = 600))
)

page <- bb_page(
  bb_section_header("General indicators", refs = "[1][2]"),
  bb_cols(indicators, my_ggplot, gap = 0.3),      # the plot matches the table's height
  bb_section_header("Notes"),
  bb_box(bb_text("Values below <80% are flagged.", style = "note"), box_style_panel()),
  template = template,
  header   = bb_banner("Immunization Profile", "Argentina, 2025"),
  gap      = c(0.08, 0.3, 0.08),
  data     = list(country = "Argentina")
)

export_pdf(bb_document(page, page_two), "profile.pdf")
```

## Building blocks

| Kind | Functions |
|---|---|
| Layout | `bb_stack()`, `bb_cols()`, `bb_box()`, `bb_spacer()`, `bb_fixed()`, `bb_full_bleed()` |
| Text | `bb_text()`, `span()`, `link()`, `text_style()` |
| Content | `bb_plot()`, `bb_image()`, `bb_grob()`, `as_block()` |
| Tables | `bb_table()`, `cell()`, `table_style()`, `table_style_grid()` |
| Marks and legends | `bb_status()`, `bb_dot()`, `bb_legend()`, `legend_key()` |
| Page chrome | `bb_banner()`, `bb_section_header()`, `bb_running_header()`, `bb_page_footer()`, `bb_placeholder()` |
| Styles | `box_style()`, `box_style_panel()`, `line_style()`, `gradient_fill()`, `stripe_fill()`, `banner_style()`, `section_header_style()`, `header_line_style()`, `footer_line_style()` |
| Theme | `bb_theme()`, `bb_set_theme()`, `with_theme()` |
| Pages | `page_template()`, `bb_page()`, `bb_document()`, `page_layout()`, `export_pdf()` |
| Measuring and custom blocks | `measure_block()`, `text_width()`, `text_gpar()`, `with_measure_device()`, `new_block()` |

Lengths take `grid::unit()` values or plain numbers in inches. Colours take any
R colour or a theme colour name such as `"muted"` or `"rule_light"`.

## Spacing: three separate bands

1. **Page margins** come from `page_template()`. Full-bleed blocks (banners)
   escape the side margins.
2. **Layout gaps** are the `gap` of `bb_stack()`, `bb_cols()` and `bb_page()`.
3. **Box spacing** is the padding and margin of `bb_box()`.

Each band is set in one place, so changing one never shifts the others.

## Upgrading from 0.4.x

0.5.0 replaces the row-based API. The canvas (`new_canvas()`,
`canvas_add_row()`), the row builders (`str_banner_row()`,
`str_subtitle_row()`, `str_n_panel_row()`, `str_three_panel_row()`), the
layout-style constructors, `text_box()` / `md_text_box()` / `html_text_box()` /
`blank_box()` and `table_box()` / `rich_table_box()` are gone.

| 0.4.x | 0.5.0 |
|---|---|
| `new_canvas()` + `canvas_add_row(height = )` | `bb_page(...)` (heights are measured) |
| `str_n_panel_row(items)` | `bb_cols(...)` with optional `widths` |
| `str_three_panel_row(A, B, C)` | `bb_cols(A, bb_stack(B, C))` |
| `str_banner_row()` | `bb_banner()` |
| `str_subtitle_row()` | `bb_box(bb_text(...), box_style(fill = gradient_fill(...)))` or `bb_section_header()` |
| `text_box()` / `md_text_box()` / `html_text_box()` | `bb_text(markup = )`, wrapped in `bb_box()` for fills and borders |
| `blank_box()` / `NULL` slot | `NULL` in `bb_cols()` |
| `table_box()` / `rich_table_box()` | `bb_table(style = table_style_grid())` |
| `text_style(face = "bold")` | `text_style(weight = 700)` |
| `export_pdf(canvas, margin_*)` | `export_pdf(page_or_document)`; margins live in `page_template()` |

## Notes

- Text renders with gridtext. Plain text is escaped, so `<80%`, `*` and `[1]`
  print literally. Links in plain text are underlined; in Markdown/HTML text
  they are coloured only, because gridtext can't underline. Links are not
  clickable PDF annotations, but each line of a URL is one text run so most
  viewers detect it.
- R graphics can't switch on OpenType features such as tabular figures
  (`tnum`). Pick a font whose default figures are equal width (Source Sans 3
  is) when numbers must line up.

## Cairo and PDF rendering

`export_pdf()` uses `cairo_pdf()` when available, for full UTF-8 output and
installed font weights, and measures text on the same kind of device so
measured heights match the file.

| Platform | Cairo status |
|---|---|
| Windows | Bundled with R |
| Linux | Usually present; install `libcairo2-dev` if missing |
| macOS | Requires [XQuartz](https://www.xquartz.org) |

Check with `capabilities("cairo")`. Without Cairo, bodybuildr falls back to
`pdf()` and prints a message.

# Construct a native grid table for use in layout rows

Converts a \`data.frame\` to a \`gridExtra::tableGrob\` with column
widths set to \`null\` units so the table fills whatever space the row
cell provides. Returns a grob that can be passed directly to layout
functions.

## Usage

``` r
table_box(
  df,
  rows = NULL,
  fill_height = FALSE,
  title = NULL,
  title_fill = NULL,
  title_col = NULL,
  title_height = unit(0.4, "in"),
  title_fontsize = NULL,
  header_fill = "#1E3A8A",
  header_col = "white",
  cell_fill = "white",
  alt_fill = "#F1F5F9",
  border_col = "#CBD5E1",
  fontsize = 9,
  fontfamily = "sans",
  padding = unit(4, "pt")
)
```

## Arguments

- df:

  A \`data.frame\` to render.

- rows:

  Whether to show row names. Default \`NULL\` (hidden).

- fill_height:

  Whether to stretch row heights to fill available space. Default
  \`FALSE\`.

- title:

  Optional character string rendered as a full-width title row above the
  header. Default \`NULL\`.

- title_fill:

  Background color for the title row. Default matches \`header_fill\`.

- title_col:

  Text color for the title row. Default matches \`header_col\`.

- title_height:

  Height of the title row as \`grid::unit\`. Default \`unit(0.4,
  "in")\`.

- title_fontsize:

  Font size for the title row in pt. Default \`fontsize + 2\`.

- header_fill:

  Background color for header row. Default \`"#1E3A8A"\`.

- header_col:

  Text color for header row. Default \`"white"\`.

- cell_fill:

  Background color for data cells. Default \`"white"\`.

- alt_fill:

  Alternating row fill color. Default \`"#F1F5F9"\`. Set \`NA\` to
  disable.

- border_col:

  Border color. Default \`"#CBD5E1"\`.

- fontsize:

  Font size in pt. Default \`9\`.

- fontfamily:

  Font family. Default \`"sans"\`.

- padding:

  Cell padding as \`grid::unit\`. Default \`unit(4, "pt")\`.

## Value

A \`gtable\` grob to use as an item in layout rows.

## Details

Requires the \`gridExtra\` package.

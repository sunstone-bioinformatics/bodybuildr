# Construct a mixed-content table grob

Like \[table_box()\] but each cell can contain text, an image path, a
ggplot, a grob, or \`NULL\`. Returns a \`gtable\` that drops into any
layout row function.

## Usage

``` r
rich_table_box(
  headers,
  rows,
  col_widths = NULL,
  row_height = unit(0.4, "in"),
  header_height = unit(0.35, "in"),
  header_fill = "#1E3A8A",
  header_col = "white",
  cell_fill = "white",
  alt_fill = "#F1F5F9",
  border_col = "#CBD5E1",
  fontsize = 9,
  fontfamily = "sans",
  padding = unit(4, "pt"),
  image_scale = c("fit", "fill")
)
```

## Arguments

- headers:

  Character vector of column header labels.

- rows:

  List of row-lists. Each row must be a list of length
  \`length(headers)\`. Items per cell: character, image path
  (\`png\`/\`jpg\`), \`ggplot\`, grob/gtable/gTree, or \`NULL\` (empty
  cell).

- col_widths:

  Numeric proportional column widths (e.g. \`c(2, 1, 1)\`). \`NULL\` =
  equal-width columns.

- row_height:

  Height of each data row as \`grid::unit\`. Default \`unit(0.4,
  "in")\`.

- header_height:

  Height of header row as \`grid::unit\`. Default \`unit(0.35, "in")\`.

- header_fill:

  Header background color. Default \`"#1E3A8A"\`.

- header_col:

  Header text color. Default \`"white"\`.

- cell_fill:

  Base data cell background. Default \`"white"\`.

- alt_fill:

  Alternating row fill color. Default \`"#F1F5F9"\`. Set \`NA\` to
  disable.

- border_col:

  Cell border color. Default \`"#CBD5E1"\`.

- fontsize:

  Font size in pt for text cells. Default \`9\`.

- fontfamily:

  Font family for text cells. Default \`"sans"\`.

- padding:

  Inner cell padding as \`grid::unit\`. Default \`unit(4, "pt")\`.

- image_scale:

  \`"fit"\` (preserve aspect ratio) or \`"fill"\` for image cells.

## Value

A \`gtable\` grob to use as an item in layout rows.

# Table

A table whose rows are as tall as their content at the width the table
gets. Every cell can hold text (with per-column style and alignment, and
per-cell overrides through \[cell()\]) or any block: \[bb_status()\],
\[bb_dot()\], images, plots with a height, even nested stacks.

## Usage

``` r
bb_table(
  rows,
  header = NULL,
  widths = NULL,
  align = "left",
  col_style = NULL,
  header_style = NULL,
  style = table_style(),
  min_row_heights = 0,
  header_case = c("none", "upper")
)
```

## Arguments

- rows:

  A list of rows (each a list with one entry per column), or a
  \`data.frame\`.

- header:

  Optional header labels; \`NULL\` for no header row. For a data frame,
  defaults to its column names.

- widths:

  Column widths as in \[bb_cols()\]: \`NULL\` (equal), numeric
  proportions, or a unit vector mixing absolute and \`"null"\` widths.

- align:

  Per-column alignment (\`"left"\`, \`"center"\`, \`"right"\`),
  recycled.

- col_style:

  Per-column text style(s): one \[text_style()\] / role name, or a list
  recycled over columns. Layered over \`style\$body_style\`.

- header_style:

  Header text style; overrides \`style\$header_style\`.

- style:

  A \[table_style()\].

- min_row_heights:

  Minimum body row height(s), recycled.

- header_case:

  Letter case for header labels (\`"none"\`, \`"upper"\`).

## Value

A block. Inside \[bb_cols()\] with \`sync_rows = TRUE\`, side-by-side
tables share row heights.

## Examples

``` r
bb_table(list(list("DTPCV3", "94.1%"), list("MCV1", cell("No data", text_style(color = "faint")))),
         header = c("Vaccine", "Coverage"), widths = c(3, 1), align = c("left", "right"))
#> <bb_table>
```

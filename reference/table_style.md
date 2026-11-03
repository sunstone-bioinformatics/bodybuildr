# Table style

\`table_style()\` defaults to a rules-only table: no fills, no vertical
borders, light dividers between rows and a stronger rule under the
header. \`table_style_grid()\` is the boxed look: filled header, borders
around every cell, alternating row fills.

## Usage

``` r
table_style(
  divider = line_style("rule_light", 0.75),
  header_rule = line_style("rule_strong", 0.75),
  last_divider = TRUE,
  pad_x = 0,
  pad_y = 9/96,
  header_pad_y = 7/96,
  col_gap = 12/96,
  valign = c("center", "top", "bottom"),
  header_valign = c("center", "top", "bottom"),
  fill = NA,
  alt_fill = NA,
  header_fill = NA,
  border = NULL,
  header_style = NULL,
  body_style = NULL
)

table_style_grid(...)
```

## Arguments

- divider:

  A \[line_style()\] drawn under each body row, or \`NULL\`.

- header_rule:

  A \[line_style()\] under the header row, or \`NULL\`.

- last_divider:

  Draw the divider under the last row too.

- pad_x, pad_y:

  Cell padding (\`grid::unit\` or inches).

- header_pad_y:

  Vertical padding of header cells.

- col_gap:

  Space kept free at the right of every column but the last.

- valign:

  Vertical alignment of body cells: \`"center"\`, \`"top"\` (for rows of
  long wrapped text) or \`"bottom"\`.

- header_valign:

  Vertical alignment of header cells (\`"bottom"\` lines up wrapped
  header labels on the rule).

- fill, alt_fill:

  Body row fills; \`alt_fill\` on even rows. \`NA\` for none.

- header_fill:

  Header row fill.

- border:

  A \[line_style()\] for the outer border and vertical lines between
  columns, or \`NULL\`.

- header_style, body_style:

  Default text styles (or role names) for header and body cells; roles
  \`table_header\` and \`table_body\`.

- ...:

  For \`table_style_grid()\`, \[table_style()\] arguments that override
  the grid preset.

## Value

A \`bb_table_style\` object.

## Examples

``` r
table_style(divider = line_style("rule_faint"), valign = "top")
#> $divider
#> $color
#> [1] "rule_faint"
#> 
#> $lwd
#> [1] 0.75
#> 
#> $lty
#> [1] "solid"
#> 
#> $alpha
#> NULL
#> 
#> attr(,"class")
#> [1] "bb_line_style"
#> 
#> $header_rule
#> $color
#> [1] "rule_strong"
#> 
#> $lwd
#> [1] 0.75
#> 
#> $lty
#> [1] "solid"
#> 
#> $alpha
#> NULL
#> 
#> attr(,"class")
#> [1] "bb_line_style"
#> 
#> $last_divider
#> [1] TRUE
#> 
#> $pad_x
#> [1] 0
#> 
#> $pad_y
#> [1] 0.09375
#> 
#> $header_pad_y
#> [1] 0.07291667
#> 
#> $col_gap
#> [1] 0.125
#> 
#> $valign
#> [1] "top"
#> 
#> $header_valign
#> [1] "center"
#> 
#> $fill
#> [1] NA
#> 
#> $alt_fill
#> [1] NA
#> 
#> $header_fill
#> [1] NA
#> 
#> $border
#> NULL
#> 
#> $header_style
#> NULL
#> 
#> $body_style
#> NULL
#> 
#> attr(,"class")
#> [1] "bb_table_style"
table_style_grid()
#> $divider
#> $color
#> [1] "rule_strong"
#> 
#> $lwd
#> [1] 0.5
#> 
#> $lty
#> [1] "solid"
#> 
#> $alpha
#> NULL
#> 
#> attr(,"class")
#> [1] "bb_line_style"
#> 
#> $header_rule
#> $color
#> [1] "rule_strong"
#> 
#> $lwd
#> [1] 0.5
#> 
#> $lty
#> [1] "solid"
#> 
#> $alpha
#> NULL
#> 
#> attr(,"class")
#> [1] "bb_line_style"
#> 
#> $last_divider
#> [1] TRUE
#> 
#> $pad_x
#> [1] 0.05555556
#> 
#> $pad_y
#> [1] 0.05555556
#> 
#> $header_pad_y
#> [1] 0.05555556
#> 
#> $col_gap
#> [1] 0
#> 
#> $valign
#> [1] "center"
#> 
#> $header_valign
#> [1] "center"
#> 
#> $fill
#> [1] "white"
#> 
#> $alt_fill
#> [1] "panel"
#> 
#> $header_fill
#> [1] "primary"
#> 
#> $border
#> $color
#> [1] "rule_strong"
#> 
#> $lwd
#> [1] 0.5
#> 
#> $lty
#> [1] "solid"
#> 
#> $alpha
#> NULL
#> 
#> attr(,"class")
#> [1] "bb_line_style"
#> 
#> $header_style
#> <text_style> base: table_header 
#>  weight: 700
#>  color: on_primary
#> 
#> $body_style
#> NULL
#> 
#> attr(,"class")
#> [1] "bb_table_style"
```

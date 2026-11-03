# Define a box style

Fill, border and spacing for \[bb_box()\] (and the label of
\[bb_placeholder()\]). Padding sits inside the border, margin outside
it. Lengths are \`grid::unit\` or inches, with 1, 2 (vertical,
horizontal) or 4 (top, right, bottom, left) values.

## Usage

``` r
box_style(
  fill = NA,
  border = NULL,
  radius = 0,
  padding = 0,
  margin = 0,
  margin_fill = NA
)

box_style_panel(fill = "panel", padding = c(12, 14, 12, 14)/96, ...)
```

## Arguments

- fill:

  Fill: a colour (theme names allowed), \[gradient_fill()\],
  \[stripe_fill()\], or \`NA\`.

- border:

  A \[line_style()\] or a colour for the border; \`NULL\`/\`NA\` for
  none.

- radius:

  Corner radius.

- padding:

  Space between the border and the content.

- margin:

  Space outside the border.

- margin_fill:

  Fill colour of the margin band.

- ...:

  For \`box_style_panel()\`, further \[box_style()\] arguments.

## Value

A \`bb_box_style\` object.

## Details

\`box_style_panel()\` is the flat note panel: theme \`panel\` fill, no
border, square corners, 12/14px padding.

## Examples

``` r
box_style(fill = "panel", padding = unit(c(6, 8), "pt"))
#> $fill
#> [1] "panel"
#> 
#> $border
#> NULL
#> 
#> $radius
#> [1] 0
#> 
#> $padding
#> [1] 0.083022 0.110696 0.083022 0.110696
#> 
#> $margin
#> [1] 0 0 0 0
#> 
#> $margin_fill
#> [1] NA
#> 
#> attr(,"class")
#> [1] "bb_box_style"
```

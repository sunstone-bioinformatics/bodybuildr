# Dots and other small marks

One or more filled marks in a row: stock-out dots, schedule dots and
diamonds. \`color\`, \`shape\` and \`size\` are recycled to the longest,
so \`bb_dot("primary", shape = c("circle", "circle", "diamond"))\` draws
two dots and a diamond. Marks are centred vertically and separated by
\`gap\`.

## Usage

``` r
bb_dot(
  color,
  size = 10/96,
  shape = "circle",
  gap = 3/96,
  align = c("left", "center", "right")
)
```

## Arguments

- color:

  Mark colour(s); theme names allowed. Marks with an \`NA\` colour are
  skipped.

- size:

  Mark size(s) (\`grid::unit\` or inches). Default 10px.

- shape:

  \`"circle"\`, \`"square"\` or \`"diamond"\`, one per mark or recycled.

- gap:

  Space between marks.

- align:

  Horizontal position in its slot. Inside \[bb_table()\] the column
  alignment places it instead.

## Value

A block.

## Examples

``` r
bb_dot("#2F7D55")
#> <bb_dot>
bb_dot("primary", size = c(7, 7, 9) / 96, shape = c("circle", "circle", "diamond"))
#> <bb_dot>
```

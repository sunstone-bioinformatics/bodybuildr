# Place blocks side by side

Splits the available width into columns and places one block in each,
top aligned by default. The row is as tall as its tallest fixed-height
child; flexible children (plots without a height) stretch to that
height.

## Usage

``` r
bb_cols(
  ...,
  widths = NULL,
  gap = 0,
  valign = c("top", "center", "bottom"),
  sync_rows = FALSE,
  .list = NULL
)
```

## Arguments

- ...:

  Blocks or anything \[as_block()\] accepts. \`NULL\` leaves the column
  empty.

- widths:

  Column widths: \`NULL\`, numeric proportions or a unit vector.

- gap:

  Space between columns (\`grid::unit\` or inches).

- valign:

  Vertical alignment of shorter children: \`"top"\`, \`"center"\` or
  \`"bottom"\`.

- sync_rows:

  Line up row heights of table children.

- .list:

  Optional list of further children.

## Value

A block.

## Details

\*\*Widths.\*\* \`NULL\` gives equal columns. Numbers are proportions
(\`c(2, 1)\`). A unit vector mixes absolute and proportional widths:
\`unit(c(3.25, 1), c("in", "null"))\` takes 3.25 in for the first column
and gives the rest to the second.

\*\*Row sync.\*\* With \`sync_rows = TRUE\`, children that are tables
(\[bb_table()\]) get the same row heights, so dividers line up across
columns. Shorter tables are padded with nothing; only existing rows
grow.

## Examples

``` r
bb_cols("Left", "Right", widths = c(2, 1), gap = 0.2)
#> <bb_cols>
```

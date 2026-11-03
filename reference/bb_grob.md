# Grob block

Wraps any grob, gTree or gtable, drawn to fill the space it is given.

## Usage

``` r
bb_grob(g, height = NULL)
```

## Arguments

- g:

  A grob.

- height:

  \`grid::unit\` or inches; \`NULL\` for flexible; \`"auto"\` to measure
  \`grid::grobHeight(g)\` (for grobs with an absolute height). A numeric
  \`"height_in"\` attribute on \`g\` is used when \`height\` is
  \`NULL\`.

## Value

A block.

## Examples

``` r
bb_grob(grid::rectGrob(gp = grid::gpar(fill = "grey90")), height = 0.3)
#> <bb_grob>
```

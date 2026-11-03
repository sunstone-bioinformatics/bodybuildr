# Fix a block's height

Gives a flexible block (a plot, a grob, a placeholder) a fixed height,
or overrides the measured height of any block. Content is drawn
top-aligned in that height.

## Usage

``` r
bb_fixed(x, height)
```

## Arguments

- x:

  A block or anything \[as_block()\] accepts.

- height:

  \`grid::unit\` or inches.

## Value

A block.

## Examples

``` r
bb_fixed(bb_spacer(), 0.5)
#> <bb_fixed>
```

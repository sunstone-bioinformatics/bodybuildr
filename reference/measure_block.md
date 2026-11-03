# Measure a block

Returns the height a block takes at a given width, measured on the same
kind of device \[export_pdf()\] uses.

## Usage

``` r
measure_block(x, width)
```

## Arguments

- x:

  A block (or anything \[as_block()\] accepts).

- width:

  Available width (\`grid::unit\` or inches).

## Value

A \`grid::unit\` in inches. Flexible blocks (for example a plot without
a fixed height) return \`NA\`.

## Examples

``` r
measure_block(bb_text("A short paragraph."), width = 3)
#> [1] 0.125inches
```

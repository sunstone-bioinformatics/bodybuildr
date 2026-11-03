# Plot block

Wraps a ggplot. Without a \`height\` the block is flexible: in
\[bb_cols()\] it takes the height of its tallest sibling, in a page body
it shares the spare height.

## Usage

``` r
bb_plot(p, height = NULL, min_height = 0)
```

## Arguments

- p:

  A ggplot object.

- height:

  \`grid::unit\`, inches, or \`NULL\` for flexible.

- min_height:

  Smallest height a flexible plot may be given (keeps a plot legible
  next to a very short sibling).

## Value

A block.

## Examples

``` r
if (requireNamespace("ggplot2", quietly = TRUE)) {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point()
  bb_plot(p, height = 2)
}
#> <bb_plot>
```

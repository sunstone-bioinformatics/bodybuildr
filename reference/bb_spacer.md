# Empty space

A fixed gap, or with \`height = NULL\` a flexible one that soaks up
spare height in a stack (for example to push the last blocks of a page
down).

## Usage

``` r
bb_spacer(height = NULL)
```

## Arguments

- height:

  \`grid::unit\`, inches, or \`NULL\` for flexible.

## Value

A block.

## Examples

``` r
bb_stack("Top", bb_spacer(0.2), "Below")
#> <bb_stack>
```

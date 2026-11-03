# Define a line style

Used for rules, dividers, borders and legend keys.

## Usage

``` r
line_style(color = "rule_light", lwd = 0.75, lty = "solid", alpha = NULL)
```

## Arguments

- color:

  Line colour: an R colour or a theme colour name. \`NA\` hides the
  line.

- lwd:

  Line width in grid \`lwd\` units (1 = 1/96 inch).

- lty:

  Line type.

- alpha:

  Optional opacity (0-1) applied to \`color\`.

## Value

A \`bb_line_style\` object.

## Examples

``` r
line_style("rule_light", lwd = 0.75)
#> $color
#> [1] "rule_light"
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
```

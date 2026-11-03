# Header and footer line styles

Styles for \[bb_running_header()\] (\`header_line_style()\`) and
\[bb_page_footer()\] (\`footer_line_style()\`).

## Usage

``` r
header_line_style(
  left_style = NULL,
  right_style = NULL,
  rule = line_style("primary", 2),
  space_above = 0,
  rule_gap = 0.1,
  space_below = 0.07
)

footer_line_style(
  left_style = NULL,
  right_style = NULL,
  rule = line_style("rule_strong", 1),
  space_above = 0,
  rule_gap = 0.16,
  space_below = 0.1
)
```

## Arguments

- left_style, right_style:

  Text styles (or role names). Defaults: roles \`running\` /
  \`running_right\` for headers, \`footer\` for footers.

- rule:

  A \[line_style()\] or \`NULL\`.

- space_above, rule_gap, space_below:

  Vertical spacing.

## Value

A \`bb_header_line_style\` object.

## Examples

``` r
header_line_style(rule = line_style("primary", 2))
#> $left_style
#> NULL
#> 
#> $right_style
#> NULL
#> 
#> $left_role
#> [1] "running"
#> 
#> $right_role
#> [1] "running_right"
#> 
#> $rule
#> $color
#> [1] "primary"
#> 
#> $lwd
#> [1] 2
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
#> $space_above
#> [1] 0
#> 
#> $rule_gap
#> [1] 0.1
#> 
#> $space_below
#> [1] 0.07
#> 
#> attr(,"class")
#> [1] "bb_header_line_style"
```

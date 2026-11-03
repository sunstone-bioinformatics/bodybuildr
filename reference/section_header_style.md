# Section header style

Section header style

## Usage

``` r
section_header_style(
  title_style = NULL,
  refs_style = NULL,
  marker_color = "accent",
  marker_width = 4/96,
  marker_height = 16/96,
  marker_gap = 10/96,
  refs_gap = 8/96,
  rule = line_style("primary", 0.75),
  space_above = 0.065,
  rule_gap = 0.0875,
  space_below = 0.08
)
```

## Arguments

- title_style, refs_style:

  Text styles (or role names) for the title and references. Default
  roles \`section\` and \`refs\`.

- marker_color:

  Colour of the marker before the title (theme names allowed); \`NA\`
  for none.

- marker_width, marker_height:

  Marker size.

- marker_gap:

  Space between marker and title.

- refs_gap:

  Space between title and references.

- rule:

  A \[line_style()\] for the rule under the title, or \`NULL\`.

- space_above:

  Space above the title line.

- rule_gap:

  Space between the title line and the rule.

- space_below:

  Space below the rule.

## Value

A \`bb_section_header_style\` object.

## Examples

``` r
section_header_style(marker_color = NA, rule = line_style("primary", 1))
#> $title_style
#> NULL
#> 
#> $refs_style
#> NULL
#> 
#> $marker_color
#> [1] NA
#> 
#> $marker_width
#> [1] 0.04166667
#> 
#> $marker_height
#> [1] 0.1666667
#> 
#> $marker_gap
#> [1] 0.1041667
#> 
#> $refs_gap
#> [1] 0.08333333
#> 
#> $rule
#> $color
#> [1] "primary"
#> 
#> $lwd
#> [1] 1
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
#> [1] 0.065
#> 
#> $rule_gap
#> [1] 0.0875
#> 
#> $space_below
#> [1] 0.08
#> 
#> attr(,"class")
#> [1] "bb_section_header_style"
```

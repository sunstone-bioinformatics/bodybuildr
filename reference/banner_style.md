# Banner style

Banner style

## Usage

``` r
banner_style(
  fill = "primary",
  height = 1.12,
  padding_x = NULL,
  logo_height = 32/96,
  logo_gap = 10/96,
  divider = line_style("white", 1, alpha = 0.3),
  divider_height = 0.6,
  text_gap = 30/96,
  title_style = NULL,
  subtitle_style = NULL,
  title_gap = 0.12,
  accent_color = "accent",
  accent_height = 4/96,
  full_bleed = TRUE
)
```

## Arguments

- fill:

  Band fill (colour, theme name, \[gradient_fill()\] ...).

- height:

  Band height (without the accent strip).

- padding_x:

  Left inset of the logos/text. \`NULL\` uses the page's left margin.

- logo_height:

  Height of the logos.

- logo_gap:

  Space between logos.

- divider:

  A \[line_style()\] for the vertical divider after the logos, or
  \`NULL\`.

- divider_height:

  Divider length.

- text_gap:

  Space on each side of the divider.

- title_style, subtitle_style:

  Text styles (or role names); default roles \`title\` and \`subtitle\`.

- title_gap:

  Space between title and subtitle.

- accent_color, accent_height:

  Strip under the band; \`accent_color = NA\` for none.

- full_bleed:

  Span the full page width.

## Value

A \`bb_banner_style\` object.

## Examples

``` r
banner_style(fill = "primary", logo_height = unit(36, "pt"))
#> $fill
#> [1] "primary"
#> 
#> $height
#> [1] 1.12
#> 
#> $padding_x
#> NULL
#> 
#> $logo_height
#> [1] 0.498132
#> 
#> $logo_gap
#> [1] 0.1041667
#> 
#> $divider
#> $color
#> [1] "white"
#> 
#> $lwd
#> [1] 1
#> 
#> $lty
#> [1] "solid"
#> 
#> $alpha
#> [1] 0.3
#> 
#> attr(,"class")
#> [1] "bb_line_style"
#> 
#> $divider_height
#> [1] 0.6
#> 
#> $text_gap
#> [1] 0.3125
#> 
#> $title_style
#> NULL
#> 
#> $subtitle_style
#> NULL
#> 
#> $title_gap
#> [1] 0.12
#> 
#> $accent_color
#> [1] "accent"
#> 
#> $accent_height
#> [1] 0.04166667
#> 
#> $full_bleed
#> [1] TRUE
#> 
#> attr(,"class")
#> [1] "bb_banner_style"
```

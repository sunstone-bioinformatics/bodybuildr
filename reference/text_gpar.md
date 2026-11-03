# Graphical parameters for a text style

Resolves a text style against the active theme (role defaults, font
weight lookup, theme colours) and returns a \`grid::gpar()\`. Use it to
draw text in theme styles inside a custom \[new_block()\].

## Usage

``` r
text_gpar(style = NULL, role = "body")
```

## Arguments

- style:

  A \[text_style()\], a theme role name, or \`NULL\`.

- role:

  Role used for fields the style leaves unset.

## Value

A \`grid::gpar\` object.

## Examples

``` r
text_gpar(text_style(weight = 600, color = "muted"))
#> bodybuildr: no weight-600 face found for "sans"; using bold.
#> $fontfamily
#> [1] "sans"
#> 
#> $fontsize
#> [1] 9
#> 
#> $col
#> [1] "#5B6472"
#> 
#> $lineheight
#> [1] 1.45
#> 
#> $font
#> bold 
#>    2 
#> 
```

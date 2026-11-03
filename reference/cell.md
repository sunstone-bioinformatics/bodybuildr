# Table cell with its own style

Wraps one table value with overrides for that cell only: a faint "No
data", a bold value, an indented sub-term. Fields left \`NULL\` come
from the column style.

## Usage

``` r
cell(
  x,
  style = NULL,
  indent = 0,
  markup = c("plain", "markdown", "html"),
  align = NULL
)
```

## Arguments

- x:

  Cell text.

- style:

  A \[text_style()\] (layered over the column style) or a role name.

- indent:

  Left indent (\`grid::unit\` or inches).

- markup:

  \`"plain"\`, \`"markdown"\` or \`"html"\`, as in \[bb_text()\].

- align:

  Optional alignment overriding the column's.

## Value

A \`bb_cell\` object.

## Examples

``` r
cell("No data", style = text_style(color = "faint"))
#> $x
#> [1] "No data"
#> 
#> $style
#> <text_style> 
#>  color: faint
#> 
#> $indent
#> [1] 0
#> 
#> $markup
#> [1] "plain"
#> 
#> $align
#> NULL
#> 
#> attr(,"class")
#> [1] "bb_cell"
```

# Width of a string in a text style

Width of a string in a text style

## Usage

``` r
text_width(text, style = NULL)
```

## Arguments

- text:

  Character string (single line).

- style:

  A \[text_style()\], a theme text role name, or \`NULL\` for body text.

## Value

A \`grid::unit\` in inches.

## Examples

``` r
text_width("Coverage", text_style(size = 12, weight = 700))
#> [1] 0.763888888888889inches
```

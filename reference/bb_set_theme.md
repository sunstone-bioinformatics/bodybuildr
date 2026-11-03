# Get or set the active theme

\`bb_set_theme()\` makes a theme the default for every block measured or
drawn afterwards. \`with_theme()\` applies one for the duration of an
expression. A \[page_template()\] with a \`theme\` applies it while its
pages are exported.

## Usage

``` r
bb_set_theme(theme)

bb_get_theme()

with_theme(theme, expr)
```

## Arguments

- theme:

  A \[bb_theme()\]. \`NULL\` restores the default theme.

- expr:

  Code to evaluate with \`theme\` active.

## Value

\`bb_set_theme()\` returns the previous theme invisibly;
\`bb_get_theme()\` the active theme; \`with_theme()\` the value of
\`expr\`.

## Examples

``` r
old <- bb_set_theme(bb_theme(font = "serif"))
bb_get_theme()$font
#> [1] "serif"
bb_set_theme(old)
```

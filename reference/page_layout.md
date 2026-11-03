# Page layout report

Measures a page without exporting it: where the body starts and ends,
how tall the content is, and how much room is left (negative when it
overflows). Useful in tests and when tuning templates.

## Usage

``` r
page_layout(page, page_number = 1, pages = 1)
```

## Arguments

- page:

  A \[bb_page()\].

- page_number, pages:

  Page number and total used for tokens.

## Value

A list with \`body_top\`, \`body_bottom\`, \`available\`, \`used\`,
\`free\` (inches), and \`footer_top\`.

## Examples

``` r
page_layout(bb_page("Hello"))$free
#> [1] 9.875
```

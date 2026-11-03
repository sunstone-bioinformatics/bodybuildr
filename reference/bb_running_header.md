# Running header and page footer

One line with text on the left and on the right, and a rule: under the
text for \`bb_running_header()\`, above it for \`bb_page_footer()\`.
Both replace \`{page}\`, \`{pages}\` and \`{\<name\>}\` (from the page's
\`data\`) when the page is exported, so one template serves every page.

## Usage

``` r
bb_running_header(left, right = NULL, style = header_line_style())

bb_page_footer(left, right = NULL, style = footer_line_style())
```

## Arguments

- left, right:

  Text (either may be \`NULL\`).

- style:

  A \[header_line_style()\].

## Value

A block.

## Examples

``` r
bb_running_header("Immunization Profile", "Argentina, 2025")
#> <bb_running_header>
bb_page_footer("PAHO, 2026", "Argentina · {page} / {pages}")
#> <bb_page_footer>
```

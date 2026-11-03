# Page template

Size, margins, header and footer shared by a set of pages. Header and
footer are blocks or \`function(ctx)\` returning a block, where \`ctx\`
holds \`page\`, \`pages\` and the page's \`data\`. Text in
\[bb_running_header()\] and \[bb_page_footer()\] can use \`{page}\` and
\`{pages}\` directly.

## Usage

``` r
page_template(
  width = 8.5,
  height = 11,
  margin_x = 0.5,
  margin_top = 0.5,
  margin_bottom = 0.5,
  header = NULL,
  footer = NULL,
  header_gap = 0.2,
  footer_gap = 0.2,
  theme = NULL,
  background = NA
)
```

## Arguments

- width, height:

  Page size (\`grid::unit\` or inches). US Letter by default.

- margin_x:

  Side margins: one value, or left and right.

- margin_top, margin_bottom:

  Top and bottom margins.

- header, footer:

  Default header and footer (block, function, or \`NULL\`).

- header_gap, footer_gap:

  Space between header/footer and body.

- theme:

  Optional \[bb_theme()\] applied while these pages are exported.

- background:

  Page background colour, or \`NA\`.

## Value

A \`bb_page_template\` object.

## Details

Layout of a page, top to bottom: - \`margin_top\`, then the header and
\`header_gap\`. A full-bleed header (a \[bb_banner()\]) sits flush with
the top edge instead. - the body, between the side margins (full-bleed
body blocks span the page width). - \`footer_gap\`, the footer, then
\`margin_bottom\`. The footer is anchored to the bottom margin, so it is
in the same place on every page.

## Examples

``` r
tpl <- page_template(margin_x = 0.5,
                     footer = bb_page_footer("My report", "{page} / {pages}"))
```

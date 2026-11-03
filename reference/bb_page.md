# Page

A page body is a vertical stack of blocks placed between the template's
header and footer. Nothing needs a hand-set height: each block measures
itself at the content width. Flexible blocks (plots without a height,
\[bb_spacer()\]) share whatever height is left.

## Usage

``` r
bb_page(
  ...,
  template = NULL,
  header,
  footer,
  gap = 0,
  data = list(),
  label = NULL,
  overflow = c("warn", "error", "ignore"),
  .list = NULL
)
```

## Arguments

- ...:

  Body blocks (or anything \[as_block()\] accepts), top to bottom.
  \`NULL\`s are dropped.

- template:

  A \[page_template()\]. Defaults to \`page_template()\`.

- header, footer:

  Override the template's header/footer for this page (block,
  \`function(ctx)\`, or \`NULL\` for none).

- gap:

  Space between body blocks, recycled.

- data:

  Named values for \`{name}\` tokens and for header/footer functions.

- label:

  Name used in overflow messages.

- overflow:

  \`"warn"\`, \`"error"\` or \`"ignore"\`.

- .list:

  Optional list of further body blocks.

## Value

A \`bb_page\` object.

## Details

If the content is taller than the space between header and footer,
\[export_pdf()\] warns (or errors, with \`overflow = "error"\`) and says
by how much.

## Examples

``` r
pg <- bb_page(bb_section_header("Summary"), "Some text.", gap = 0.1)
```

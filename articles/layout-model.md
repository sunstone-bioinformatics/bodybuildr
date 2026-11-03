# Layout model: blocks, pages and margins

## Blocks

Everything on a bodybuildr page is a **block**. A block answers two
questions:

- *How tall are you at this width?*
  ([`measure_block()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/measure_block.md))
- *Draw yourself in this box.*

Text wraps to the width it gets, so its height follows:

``` r

para <- bb_text(paste(rep("Coverage rose in most provinces.", 8), collapse = " "))
measure_block(para, width = 6)
#> [1] 0.486145703611457inches
measure_block(para, width = 2)
#> [1] 1.3890099626401inches
```

Some blocks have no height of their own. A plot without a `height`, a
[`bb_spacer()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_spacer.md)
without a height and a
[`bb_placeholder()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_placeholder.md)
are **flexible**: they take the height their container gives them.

``` r

measure_block(bb_spacer(), 3)
#> [1] NAinches
```

Anything you pass where a block is expected goes through
[`as_block()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/as_block.md):
strings become
[`bb_text()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_text.md),
ggplots
[`bb_plot()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_plot.md),
image paths
[`bb_image()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_image.md),
grobs
[`bb_grob()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_grob.md).

## Composing

[`bb_stack()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_stack.md)
places blocks top to bottom;
[`bb_cols()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_cols.md)
side by side. Widths are passed down and heights come back up, so
nothing needs a hand-set height.

``` r

row <- bb_cols(
  bb_table(list(list("Total population", "45,696,159"),
                list("Surviving infants", "530,193")),
           widths = c(2, 1), align = c("left", "right")),
  bb_stack(bb_text("Notes", style = "subheading"),
           bb_text("A second column with its own stack.", style = "note"),
           gap = unit(4, "pt")),
  widths = unit(c(4, 1), c("in", "null")),   # 4 in, then the rest
  gap = 0.25
)
measure_block(row, width = 7.5)
#> [1] 0.625inches
```

In a row, flexible children (a plot, a placeholder) stretch to the
tallest fixed sibling. Tables placed side by side can share row heights
with `sync_rows = TRUE`, so their dividers line up.

## Pages

A
[`page_template()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/page_template.md)
holds the page size, margins, header and footer. A
[`bb_page()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_page.md)
stacks its blocks in the space between them. The footer is anchored to
the bottom margin, so it lands in the same place on every page, however
much content sits above it.

``` r

template <- page_template(
  margin_x = 0.5, margin_top = 0.3, margin_bottom = 0.3,
  header = bb_running_header("Annual report", "{country}"),
  footer = bb_page_footer("Organisation", "{page} / {pages}")
)

page <- bb_page(
  bb_section_header("Overview", refs = "[1]"),
  row,
  bb_box(bb_text("Flat grey note panel.", style = "note"), box_style_panel()),
  template = template,
  gap = c(0.08, 0.2),
  data = list(country = "Argentina")
)

page_layout(page)[c("available", "used", "free")]
#> $available
#> [1] 9.26375
#> 
#> $used
#> [1] 1.707813
#> 
#> $free
#> [1] 7.555938
```

[`page_layout()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/page_layout.md)
reports the space without exporting. If content outgrows the body,
[`export_pdf()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/export_pdf.md)
warns with the overflow in inches.

A
[`bb_document()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_document.md)
numbers its pages after dropping `NULL`s, so an optional page shifts
every later “n / N” automatically:

``` r

optional_page <- NULL
doc <- bb_document(page, optional_page, bb_page("Second page", template = template,
                                                data = list(country = "Argentina")))
f <- tempfile(fileext = ".pdf")
export_pdf(doc, f)
```

## Three spacing bands

Spacing is set in three separate places, and none of them affects the
others:

1.  **Page margins**:
    `page_template(margin_x, margin_top, margin_bottom)`. A full-bleed
    block, such as
    [`bb_banner()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_banner.md),
    spans the full page width instead (and sits flush with the top edge
    when it is the header).
2.  **Layout gaps**: `gap` in
    [`bb_stack()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_stack.md),
    [`bb_cols()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_cols.md)
    and
    [`bb_page()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_page.md).
3.  **Box spacing**: `padding` and `margin` of
    [`box_style()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/box_style.md)
    in
    [`bb_box()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_box.md).

## Themes and text styles

A theme defines the palette and the text roles (`body`, `note`,
`section`, `table_header`, …). Components default to a role, and a
[`text_style()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/text_style.md)
only lists what it changes:

``` r

th <- bb_theme(font = "sans", base_size = 9,
               colors = list(primary = "#0C2C5E", accent = "#E5782A"))
bb_set_theme(th)

bb_text("Semibold, muted", style = text_style(weight = 600, color = "muted"))
#> <bb_text>
bb_text("Note role, italic", style = text_style("note", italic = TRUE))
#> <bb_text>
```

Weights other than 400 and 700 resolve to the installed face (for
example “Source Sans 3 Semibold”) when systemfonts finds one, and fall
back to bold or regular otherwise.

# Internal: wrapped text box anchored top-left

Internal helper used by layout row builders to render wrapped text
inside a padded, rounded box. Users should construct text content via
\[text_box()\] or pass character vectors to layout functions; this
helper is not part of the public API.

## Usage

``` r
wrap_text_top_left(
  label,
  inner_vp,
  gp = grid::gpar(col = "#111111", fontsize = 11, fontface = "plain", fontfamily =
    "sans"),
  preserve_newlines = TRUE,
  prefer_gridtext = TRUE,
  box_r = grid::unit(6, "pt"),
  box_border_col = "#CBD5E1",
  box_border_lwd = 1,
  box_fill = NA,
  box_margin = grid::unit(c(6, 6, 6, 6), "pt"),
  text_pad = grid::unit(c(4, 6, 4, 6), "pt")
)
```

## Arguments

- label:

  Character vector to render.

- inner_vp:

  A \`grid::viewport\` defining the available space.

- gp:

  A \`grid::gpar\` for text styling.

- preserve_newlines:

  Whether to keep newline breaks.

- prefer_gridtext:

  Whether to prefer \`gridtext::textbox_grob\`.

- box_r:

  Corner radius as \`grid::unit\`.

- box_border_col, box_border_lwd, box_fill:

  Border styling.

- box_margin:

  Outer margin as \`grid::unit\`.

- text_pad:

  Inner padding as \`grid::unit\`.

## Value

A grob representing the wrapped text box.

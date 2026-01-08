# Define subtitle row layout defaults

Collects geometry and colors for \`str_subtitle_row\`.

## Usage

``` r
subtitle_layout_style(
  row_height = unit(0.9, "in"),
  outer_margin = unit(15, "pt"),
  outer_margin_bg = NA,
  bottom_margin = unit(0, "pt"),
  bottom_margin_bg = NA,
  cell_bg_cols = c("#2f6cab", "#173052"),
  cell_bg_stops = NULL,
  cell_bg_dir = "lr",
  text_hjust = "left"
)
```

## Arguments

- row_height:

  Total row height as \`grid::unit\`.

- outer_margin, outer_margin_bg:

  Left/right margin lanes and fill.

- bottom_margin, bottom_margin_bg:

  Bottom margin lane and fill.

- cell_bg_cols, cell_bg_stops, cell_bg_dir:

  Gradient/solid background for the subtitle cell.

## Value

A list of subtitle layout parameters.

## Details

Margin layers: - \`outer_margin\`/\`bottom_margin\` and their
backgrounds control the row lanes relative to the page/canvas. - Box
margins/padding are controlled separately via \`box_style\` in
\`str_subtitle_row()\`.

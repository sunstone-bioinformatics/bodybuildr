# Define column layout defaults for multi-panel rows

Collects geometry and color defaults for \`str_n_panel_row\`. All unit
arguments must be non-negative.

## Usage

``` r
columnLayoutStyle(
  column_bg = "white",
  column_pad_x = grid::unit(8, "pt"),
  column_pad_y = grid::unit(8, "pt"),
  column_gap = grid::unit(10, "pt"),
  column_gap_bg = NA,
  outer_margin = grid::unit(0, "pt"),
  outer_margin_bg = NA,
  bottom_margin = grid::unit(10, "pt"),
  bottom_margin_bg = NA
)
```

## Arguments

- column_bg:

  Background color(s) for columns (recycled).

- column_pad_x, column_pad_y:

  Inner padding for columns as \`grid::unit\`.

- column_gap:

  Gap between columns as \`grid::unit\`.

- column_gap_bg:

  Background color(s) for gaps.

- outer_margin, outer_margin_bg:

  Left/right margin lanes and their fill.

- bottom_margin, bottom_margin_bg:

  Bottom margin lane and fill.

## Value

A list of column layout parameters.

## Details

Margin layers: - \`outer_margin\`/\`bottom_margin\` and their
backgrounds control the row lanes relative to the page/canvas. - Box
margins/padding are controlled separately via \`box_style\` (or
\`text_box\`) in \`str_n_panel_row()\`.

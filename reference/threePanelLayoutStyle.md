# Define three-panel row layout defaults

Collects geometry and colors for \`str_three_panel_row\`. All unit
arguments must be non-negative. \`right_split\` must be in (0, 1).

## Usage

``` r
threePanelLayoutStyle(
  row_height = grid::unit(5, "in"),
  A_width = grid::unit(3.2, "in"),
  right_split = 0.55,
  hgap = grid::unit(10, "pt"),
  vgap = grid::unit(10, "pt"),
  hgap_bg = NA,
  vgap_bg = NA,
  outer_margin = grid::unit(0, "pt"),
  outer_margin_bg = NA,
  bottom_margin = grid::unit(10, "pt"),
  bottom_margin_bg = NA,
  A_bg = "white",
  B_bg = "white",
  C_bg = "white",
  A_pad_x = grid::unit(8, "pt"),
  A_pad_y = grid::unit(8, "pt"),
  B_pad_x = grid::unit(8, "pt"),
  B_pad_y = grid::unit(8, "pt"),
  C_pad_x = grid::unit(8, "pt"),
  C_pad_y = grid::unit(8, "pt")
)
```

## Arguments

- row_height:

  Total row height as \`grid::unit\` (for reference when adding to
  canvas).

- A_width:

  Width of the left panel as \`grid::unit\`.

- right_split:

  Proportion of the right column allocated to the top panel.

- hgap, vgap:

  Gaps between panels as \`grid::unit\`.

- hgap_bg, vgap_bg:

  Background fills for the horizontal/vertical gaps.

- outer_margin, outer_margin_bg:

  Left/right margin lanes and fill.

- bottom_margin, bottom_margin_bg:

  Bottom margin lane and fill.

- A_bg, B_bg, C_bg:

  Panel backgrounds.

- A_pad_x, A_pad_y, B_pad_x, B_pad_y, C_pad_x, C_pad_y:

  Panel padding.

## Value

A list of three-panel layout parameters.

## Details

Margin layers: - \`outer_margin\`/\`bottom_margin\` and their
backgrounds control the row lanes relative to the page/canvas. - Box
margins/padding are controlled separately via \`box_style\` or
\`text_box()\` inside \`str_three_panel_row()\`.

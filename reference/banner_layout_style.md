# Define banner layout defaults

Collects geometry and color defaults for the banner row.

## Usage

``` r
banner_layout_style(
  banner_height = unit(1.6, "in"),
  logo_panel_width = unit(1.8, "in"),
  logo_pad_x = unit(0.12, "in"),
  logo_pad_y = unit(0.15, "in"),
  banner_bg = "#2f6cab",
  logo_panel_bg = "#173052",
  text_left_pad = unit(12, "pt"),
  text_block_top_pad = unit(10, "pt"),
  title_vshift = unit(0, "pt"),
  subtitle_gap = unit(6, "pt"),
  logo_position = c("left", "right"),
  image_scale = c("fit", "fill")
)
```

## Arguments

- banner_height:

  Overall banner height as \`grid::unit\`.

- logo_panel_width:

  Width of the left logo panel as \`grid::unit\`.

- logo_pad_x, logo_pad_y:

  Inner padding around the logo.

- banner_bg:

  Background color for the right text area.

- logo_panel_bg:

  Background color for the left logo panel.

- text_left_pad, text_block_top_pad:

  Padding for the text block placement.

- title_vshift:

  Vertical shift applied to the entire text block.

- subtitle_gap:

  Gap between title and subtitle.

## Value

A list of layout parameters.

## Details

All unit arguments must be non-negative.

# Box Margins and Lanes

``` r
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 4
)
library(bodybuildr)
library(grid)
```

## Two Layers to Know

- **Lanes (outer margins)** come from layout styles such as
  [`subtitleLayoutStyle()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/subtitleLayoutStyle.md)
  or
  [`columnLayoutStyle()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/columnLayoutStyle.md).
  These set the space between the content band and the page (good for
  gutters, shadows, or background bands).
- **Box margin** comes from
  [`boxStyle()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/boxStyle.md).
  It is the gap immediately around the box itself. Set `margin = 0` for
  a single-layer band, or provide `margin` + `margin_fill` to create a
  second colored band inside the lane.

Keep them separate: use lanes for page rhythm, use box margin for
layered/3D looks.

## Subtitle Examples

``` r
# Lane-only: no box margin, fill matches lanes
lane_only_layout <- subtitleLayoutStyle(
  row_height = unit(1, "in"),
  outer_margin = unit(0, "pt"),
  outer_margin_bg = "#0EA5E9",
  bottom_margin = unit(0, "pt"),
  bottom_margin_bg = "#0284C7",
  cell_bg_cols = c("#0369A1", "#E9990E")
)

lane_only_row <- str_subtitle_row(
  label = "Lane-only band",
  layout_style = lane_only_layout,
  text_style = textStyle(color = "white", size = 14, face = "bold"),
  box_style = boxStyle(
    radius = unit(8, "pt"),
    border_color = lane_only_layout$outer_margin_bg,
    border_lwd = 0.5,
    fill = lane_only_layout$outer_margin_bg,
    margin = unit(0, "pt"),
    padding = unit(c(8, 14, 8, 14), "pt")
  )
)

# Layered: box margin + margin_fill for a second colored band
layered_layout <- subtitleLayoutStyle(
  row_height = unit(0.8, "in"),
  outer_margin = unit(10, "pt"),
  outer_margin_bg = "#F97316",
  bottom_margin = unit(4, "pt"),
  bottom_margin_bg = "#C2410C",
  cell_bg_cols = c("#FB923C", "#EA580C")
)

layered_row <- str_subtitle_row(
  label = "Layered band",
  layout_style = layered_layout,
  text_style = textStyle(color = "black", size = 12, face = "plain"),
  box_style = boxStyle(
    radius = unit(6, "pt"),
    border_color = "#F97316",
    border_lwd = 0.8,
    fill = "#FED7AA",
    margin_fill = "#4F4B47",
    margin = unit(c(4, 8, 6, 8), "pt"),
    padding = unit(c(6, 10, 6, 10), "pt")
  )
)

# Centered text, lane + margin fill
center_layout <- subtitleLayoutStyle(
  row_height = unit(0.8, "in"),
  outer_margin = unit(10, "pt"),
  outer_margin_bg = "#22C55E",
  bottom_margin = unit(4, "pt"),
  bottom_margin_bg = "#16A34A",
  cell_bg_cols = c("#BBF7D0", "#22C55E"),
  text_hjust = "center"
)

center_row <- str_subtitle_row(
  label = "Centered subtitle",
  layout_style = center_layout,
  text_style = textStyle(color = "#064E3B", size = 12, face = "bold"),
  box_style = boxStyle(
    radius = unit(6, "pt"),
    border_color = "#22C55E",
    border_lwd = 1,
    fill = "#DD139D",
    margin_fill = "#22C55E",
    margin = unit(c(4, 8, 4, 8), "pt"),
    padding = unit(c(6, 10, 6, 10), "pt")
  )
)

# Right-aligned text, zero box margin
right_layout <- subtitleLayoutStyle(
  row_height = unit(0.8, "in"),
  outer_margin = unit(8, "pt"),
  outer_margin_bg = "#A855F7",
  bottom_margin = unit(4, "pt"),
  bottom_margin_bg = "#9333EA",
  cell_bg_cols = c("#E9D5FF", "#A855F7"),
  text_hjust = "right"
)

right_row <- str_subtitle_row(
  label = "Right aligned subtitle",
  layout_style = right_layout,
  text_style = textStyle(color = "#4A044E", size = 12, face = "plain"),
  box_style = boxStyle(
    radius = unit(2, "pt"),
    border_color = "#A855F7",
    border_lwd = 1,
    fill = "#2E1AB0",
    margin_fill = NA,
    margin = unit(0, "pt"),
    padding = unit(c(6, 10, 6, 10), "pt")
  )
)
```

## Three-Panel Row Example

``` r
three_style <- threePanelLayoutStyle(
  A_bg = "#F8FAFC",
  B_bg = "#ECFDF5",
  C_bg = "#FFF7ED",
  hgap = unit(8, "pt"),
  vgap = unit(8, "pt"),
  outer_margin = unit(6, "pt"),
  bottom_margin = unit(6, "pt")
)

three_row <- str_three_panel_row(
  A_item = text_box(
    "Left panel text",
    text_style = textStyle(color = "#1F2937", size = 12, face = "bold"),
    box_style = boxStyle(
      radius = unit(6, "pt"),
      border_color = "#0EA5E9",
      border_lwd = 1,
      fill = "#E0F2FE",
      margin = unit(0, "pt"),
      padding = unit(c(6, 10, 6, 10), "pt")
    ),
    bg = "#F8FAFC"
  ),
  B_item = text_box(
    "Top-right text",
    text_style = textStyle(color = "#14532D", size = 11),
    box_style = boxStyle(
      radius = unit(4, "pt"),
      border_color = "#22C55E",
      border_lwd = 1,
      fill = "#DCFCE7",
      margin = unit(0, "pt"),
      padding = unit(c(6, 10, 6, 10), "pt")
    ),
    bg = "#ECFDF5"
  ),
  C_item = text_box(
    "Bottom-right text",
    text_style = textStyle(color = "#7C2D12", size = 11),
    box_style = boxStyle(
      radius = unit(4, "pt"),
      border_color = "#F97316",
      border_lwd = 1,
      fill = "#FFEDD5",
      margin = unit(0, "pt"),
      padding = unit(c(6, 10, 6, 10), "pt")
    ),
    bg = "#FFF7ED"
  ),
  layout_style = three_style
)
```

Combine rows on a canvas and export (set `eval = FALSE` if you do not
want to generate the file during checks):

``` r
canvas <- new_canvas()
canvas <- canvas_add_row(canvas, lane_only_row, lane_only_layout$row_height)
canvas <- canvas_add_row(canvas, layered_row, layered_layout$row_height)
canvas <- canvas_add_row(canvas, center_row, center_layout$row_height)
canvas <- canvas_add_row(canvas, right_row, right_layout$row_height)
canvas <- canvas_add_row(canvas, three_row, three_style$row_height)

# Export
export_pdf(
  canvas,
  file = "vignette-subtitle-margins.pdf",
  width = unit(8.5, "in"),
  height = unit(7.5, "in")
)
```

Use this as a reference to decide when to rely on lane backgrounds
vs. box margins for layered effects. Adjust colors/radii to match your
design system.

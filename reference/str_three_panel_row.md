# Three-panel row layout (A \| B over C)

Places a tall left panel next to two stacked right panels, with padding
and lane options. Use \[text_box()\] for per-panel text styling and
\[blank_box()\] for intentional empty slots; other items can be
ggplot/grob/image paths.

## Usage

``` r
str_three_panel_row(
  A_item = NULL,
  B_item = NULL,
  C_item = NULL,
  layout_style = three_panel_layout_style(),
  text_style = NULL,
  box_style = NULL,
  image_scale = c("fit", "fill"),
  reverse = FALSE,
  debug_boxes = FALSE
)
```

## Arguments

- A_item, B_item, C_item:

  Items to render (ggplot/grob/image path/character/NULL or
  \`text_box()\` / \`blank_box()\`).

- layout_style:

  A list from \[layout_style()\] or \[three_panel_layout_style()\]
  controlling geometry, padding, and backgrounds.

- text_style:

  Default text style (\`text_style()\`), used for character items.

- box_style:

  Default box style (\`box_style()\`), used for character/fallback
  items.

- image_scale:

  How to place images: \`"fit"\` (preserve aspect) or \`"fill"\`.

- reverse:

  Logical; if \`TRUE\`, A is on the right and B/C are on the left.

- debug_boxes:

  Draw debug outlines. Note: Lanes (outer/bottom margins) come from
  \`layout_style\`. The immediate gap around text boxes is controlled by
  \`box_style\$margin\` or \`text_box()\`; set it to zero for a
  single-layer look.

## Value

A \`gtable\` representing the row.

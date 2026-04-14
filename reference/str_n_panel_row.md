# Multi-column row layout (1..n columns)

Accepts ggplot objects, grobs, image paths, or character vectors and
renders them into equal-width columns with configurable padding, gaps,
and lanes.

## Usage

``` r
str_n_panel_row(
  items,
  row_height = unit(2, "in"),
  layout_style = NULL,
  column_style = NULL,
  text_style = NULL,
  box_style = NULL,
  image_scale = c("fit", "fill"),
  full_bleed_left = FALSE,
  full_bleed_right = FALSE,
  debug_boxes = FALSE
)
```

## Arguments

- row_height:

  Optional nominal height (\`grid::unit\`); actual height is set when
  adding to a canvas.

- layout_style:

  A list from \[layout_style()\] or \[column_layout_style()\]
  controlling padding/gaps/margins/backgrounds (non-negative units).

- column_style:

  Deprecated alias for \`layout_style\`.

- text_style:

  Default text style (\`text_style()\`), used for character items.

- box_style:

  Default box style (\`box_style()\`), used for character/fallback
  items.

- image_scale:

  How to place images: \`"fit"\` (preserve aspect) or \`"fill"\`.

- full_bleed_left, full_bleed_right:

  Allow first/last column to extend into outer lanes.

- debug_boxes:

  Draw debug outlines.

## Value

A \`gtable\` representing the row.

## Details

\*\*Inputs\*\* - \`items\`: list of ggplot/grob/image
path/character/NULL. Use \[text_box()\] to give a specific column its
own text/box/background settings, or \[blank_box()\] for an intentional
empty slot. - \`row_height\`: nominal height (\`grid::unit\`); actual
height is set when adding to a canvas.

\*\*Layout + styling\*\* - \`layout_style\`: list from
\[layout_style()\] or \[column_layout_style()\] (padding, gaps, margins,
backgrounds). - \`text_style\`: default text style (\`text_style()\`),
used for character items. - \`box_style\`: default box style
(\`box_style()\`), used for character/fallback items. - \`image_scale\`:
\`"fit"\` (preserve aspect) or \`"fill"\`. - \`full_bleed_left\` /
\`full_bleed_right\`: allow first/last column to extend into outer
lanes. - \`debug_boxes\`: overlay guides.

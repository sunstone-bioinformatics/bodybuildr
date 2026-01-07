# Multi-column row layout (1..n columns)

Accepts ggplot objects, grobs, image paths, or character vectors and
renders them into equal-width columns with configurable padding, gaps,
and lanes.

## Usage

``` r
str_n_panel_row(
  items,
  row_height = grid::unit(2, "in"),
  column_style = columnLayoutStyle(),
  text_style = textStyle(),
  box_style = boxStyle(radius = grid::unit(8, "pt"), border_color = "#D1D5DB", border_lwd
    = 1, fill = NA, margin = grid::unit(c(6, 6, 6, 6), "pt"), padding = grid::unit(c(6,
    8, 6, 8), "pt")),
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

- column_style:

  A list from \[columnLayoutStyle()\] controlling
  padding/gaps/margins/backgrounds (non-negative units).

- text_style:

  Default text style (\`textStyle()\`), used for character items.

- box_style:

  Default box style (\`boxStyle()\`), used for character/fallback items.

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
own text/box/background settings; otherwise the defaults below apply. -
\`row_height\`: nominal height (\`grid::unit\`); actual height is set
when adding to a canvas.

\*\*Layout + styling\*\* - \`column_style\`: list from
\[columnLayoutStyle()\] (padding, gaps, margins, backgrounds). -
\`text_style\`: default text style (\`textStyle()\`), used for character
items. - \`box_style\`: default box style (\`boxStyle()\`), used for
character/fallback items. - \`image_scale\`: \`"fit"\` (preserve aspect)
or \`"fill"\`. - \`full_bleed_left\` / \`full_bleed_right\`: allow
first/last column to extend into outer lanes. - \`debug_boxes\`: overlay
guides.

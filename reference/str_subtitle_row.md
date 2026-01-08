# Subtitle row layout

Renders a full-width subtitle band with optional gradient fill and
lanes.

## Usage

``` r
str_subtitle_row(
  label,
  layout_style = subtitle_layout_style(),
  box_style = NULL,
  text_style = NULL
)
```

## Arguments

- label:

  Subtitle text.

- layout_style:

  A list from \[subtitle_layout_style()\] for lanes/gradient/background.

- box_style:

  Box styling from \[box_style()\] (radius, border, fill, margin,
  padding, margin_fill).

- text_style:

  Text styling from \[text_style()\]. Note: Lanes are controlled by
  \`layout_style\` (outer/bottom margins). The immediate gap around the
  box is controlled by \`box_style\$margin\`/\`margin_fill\`. Leave the
  box margin at zero for a single-layer band, or set it (plus
  \`margin_fill\`) for a double-layer/3D effect.

## Value

A \`gtable\` representing the row.

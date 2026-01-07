# Construct a styled text box item

Creates a text box payload that can be passed into layout functions
(e.g., \`str_n_panel_row\`) with its own text and box styles.

## Usage

``` r
text_box(
  label,
  text_style = textStyle(),
  box_style = boxStyle(),
  bg = NULL,
  pad_x = NULL,
  pad_y = NULL
)
```

## Arguments

- label:

  Character text to render.

- text_style:

  A \`gpar\` from \[textStyle()\].

- box_style:

  A list from \[boxStyle()\].

- bg:

  Optional column background color override.

- pad_x, pad_y:

  Optional column padding overrides as \`grid::unit\` (non-negative).

## Value

An object of class \`"bbdr_text_box"\` to use as an item in layout rows.

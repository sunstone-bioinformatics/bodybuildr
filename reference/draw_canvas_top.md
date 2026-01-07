# Draw a canvas top-aligned

Renders a grob anchored at the top-left of the device with optional page
margins.

## Usage

``` r
draw_canvas_top(
  grob,
  margin_top = grid::unit(0, "in"),
  margin_right = grid::unit(0, "in"),
  margin_bottom = grid::unit(0, "in"),
  margin_left = grid::unit(0, "in"),
  clip = TRUE
)
```

## Arguments

- grob:

  A grob/gtable to draw.

- margin_top, margin_right, margin_bottom, margin_left:

  Page margins as non-negative \`grid::unit\`.

- clip:

  Logical; if \`TRUE\`, content outside the margin-constrained viewport
  is clipped.

## Value

Invisibly draws to the current device.

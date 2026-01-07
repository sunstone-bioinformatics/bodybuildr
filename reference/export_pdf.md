# Export a canvas to PDF (top-anchored)

Opens a PDF device, draws a grob top-aligned, and closes the device.

## Usage

``` r
export_pdf(
  grob,
  file = "infographic_layout.pdf",
  width = grid::unit(8.5, "in"),
  height = grid::unit(11, "in"),
  margin_top = grid::unit(0, "in"),
  margin_right = grid::unit(0, "in"),
  margin_bottom = grid::unit(0, "in"),
  margin_left = grid::unit(0, "in")
)

export_pdf_top(
  grob,
  file = "infographic_layout.pdf",
  width = grid::unit(8.5, "in"),
  height = grid::unit(11, "in"),
  margin_top = grid::unit(0, "in"),
  margin_right = grid::unit(0, "in"),
  margin_bottom = grid::unit(0, "in"),
  margin_left = grid::unit(0, "in")
)
```

## Arguments

- grob:

  A grob/gtable to export.

- file:

  Output PDF path.

- width, height:

  Page dimensions as non-negative \`grid::unit\` (length 1).

- margin_top, margin_right, margin_bottom, margin_left:

  Page margins as non-negative \`grid::unit\` (length 1).

## Value

Invisibly returns the output file path.

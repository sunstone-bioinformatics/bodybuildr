# Export a canvas to PDF (top-anchored)

Opens a PDF device, draws a grob top-aligned, and closes the device.

## Usage

``` r
export_pdf(
  grob,
  file = "infographic_layout.pdf",
  width = unit(8.5, "in"),
  height = unit(11, "in"),
  margin_top = unit(0, "in"),
  margin_right = unit(0, "in"),
  margin_bottom = unit(0, "in"),
  margin_left = unit(0, "in")
)

export_pdf_top(
  grob,
  file = "infographic_layout.pdf",
  width = unit(8.5, "in"),
  height = unit(11, "in"),
  margin_top = unit(0, "in"),
  margin_right = unit(0, "in"),
  margin_bottom = unit(0, "in"),
  margin_left = unit(0, "in")
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

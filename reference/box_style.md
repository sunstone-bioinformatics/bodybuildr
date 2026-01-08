# Define a box style

Provides a reusable set of parameters for rounded boxes (radius, border,
fill, margin, padding).

## Usage

``` r
box_style(
  radius = unit(8, "pt"),
  border_color = "#D1D5DB",
  border_lwd = 1,
  fill = NA,
  margin = unit(c(0, 0, 0, 0), "pt"),
  margin_fill = NA,
  padding = unit(c(0, 0, 0, 0), "pt")
)
```

## Arguments

- radius:

  Corner radius as \`grid::unit\`.

- border_color:

  Border color.

- border_lwd:

  Border line width (non-negative).

- fill:

  Fill color.

- margin:

  Outer margin as \`grid::unit\` (t, r, b, l).

- margin_fill:

  Fill color for the margin band (defaults to NA/transparent).

- padding:

  Inner padding as \`grid::unit\` (t, r, b, l).

## Value

A list with box styling parameters.

## Details

All unit arguments must be non-negative.

Margin layers: - Box margin (\`margin\`, \`margin_fill\`) creates an
inner gap around the box itself. Leave at zero for a single-layer look,
or set \`margin\`/\`margin_fill\` for a double-layer/3D effect. -
Row/column lanes come from layout styles (e.g.,
\[column_layout_style()\], \[subtitle_layout_style()\]); they sit
outside the box entirely.

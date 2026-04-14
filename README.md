# bodybuildr
Build cool infographics in R by building the body row by row.

bodybuildr solves the annoying part of infographic work: layout. Instead of
fighting with absolute positioning, you stack flexible rows with consistent
lanes, gaps, and padding. Each row can be text, a plot, an image, or a custom
grob, and the whole thing exports cleanly to PDF.

The name is the point: you build the body one row at a time.

## Why bodybuildr?
- Compose complex infographics by stacking rows on a canvas.
- Mix text, ggplot2 objects, images, and grobs in the same row.
- Control spacing with layout styles (lanes, gaps, margins) and box styles.
- Export to PDF with predictable sizing using grid units.

## Install
If the package is on CRAN:
```r
install.packages("bodybuildr")
```

If you are installing from GitHub:
```r
# install.packages("remotes")
remotes::install_github("sunstone-bioinformatics/bodybuildr")
```

## Quick start
```r
library(bodybuildr)

# Build a banner
banner <- str_banner_row(
  image_path = "path/to/logo.png",
  title = "Project Title",
  subtitle = "Short, punchy summary"
)

# Add a subtitle band
subtitle <- str_subtitle_row(
  label = "Key Findings",
  layout_style = layout_style(
    type = "subtitle",
    outer_margin = grid::unit(10, "pt"),
    bottom_margin = grid::unit(6, "pt")
  ),
  text_style = text_style(color = "white", size = 14, face = "bold")
)

# Build a 3-column row with per-panel styling
row <- str_n_panel_row(
  items = list(
    "Left panel text",
    "Middle panel text",
    text_box(
      "Right panel text",
      text_style = text_style(color = "#111827", size = 11),
      box_style = box_style(
        fill = "#F9FAFB",
        padding = grid::unit(c(6, 10, 6, 10), "pt")
      )
    )
  ),
  layout_style = layout_style(
    type = "columns",
    column_gap = grid::unit(8, "pt"),
    outer_margin = grid::unit(6, "pt"),
    bottom_margin = grid::unit(6, "pt")
  )
)

# Assemble the canvas row by row
canvas <- new_canvas()
canvas <- canvas_add_row(canvas, banner,   grid::unit(1.6, "in"))
canvas <- canvas_add_row(canvas, subtitle, grid::unit(0.9, "in"))
canvas <- canvas_add_row(canvas, row,      grid::unit(3.0, "in"))

# Export
export_pdf(canvas, file = "infographic.pdf")
```

## Core building blocks
Row builders:
- `str_banner_row()` for a logo + title/subtitle banner
- `str_subtitle_row()` for a full-width subtitle band
- `str_n_panel_row()` for 1..n columns
- `str_three_panel_row()` for A | (B over C) layouts

Styling helpers:
- `text_style()` and `box_style()` to control typography and boxes
- `layout_style(type = ...)` as the main layout constructor for row spacing, lanes,
  and backgrounds
- `banner_layout_style()`, `column_layout_style()`, `subtitle_layout_style()`, and
  `three_panel_layout_style()` as explicit row-specific aliases

Canvas helpers:
- `new_canvas()` and `canvas_add_row()` to stack rows
- `export_pdf()` to write a final PDF

## Notes
- Uses grid units (`grid::unit`) for sizing; keep units consistent.
- ggplot2 support is optional; install it if you want to render plots in rows.

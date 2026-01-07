# Internal: subtitle cell with gradient and rounded corners

Internal: subtitle cell with gradient and rounded corners

## Usage

``` r
.subtitle_cell(
  label,
  cell_bg_cols = c("#2f6cab", "#173052"),
  cell_bg_stops = NULL,
  cell_bg_dir = "lr",
  box_r = grid::unit(10, "pt"),
  box_border_col = NA,
  box_border_lwd = 1,
  text_gp = grid::gpar(col = "white", fontsize = 16, fontfamily = "sans", fontface =
    "bold"),
  text_pad = grid::unit(c(10, 14, 10, 14), "pt"),
  box_margin = grid::unit(c(6, 6, 6, 6), "pt"),
  text_hjust = "left",
  margin_fill = NA
)
```

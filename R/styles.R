# Style helpers ------------------------------------------------------------

#' Define a text style (ggplot2 element_text-like)
#'
#' Convenience helper to create a `grid::gpar` with common text properties.
#'
#' All numeric arguments must be length-1 and non-negative.
#'
#' @param color Text color.
#' @param size Font size (points, non-negative).
#' @param face Font face (e.g., "plain", "bold", "italic").
#' @param family Font family.
#' @return A `grid::gpar` object.
#' @export
#' @importFrom grid gpar
textStyle <- function(color = "#111111",
                      size = 11,
                      face = "plain",
                      family = "sans") {
  if (length(size) != 1 || is.na(size) || size < 0) {
    stop("`size` must be length-1, non-negative.", call. = FALSE)
  }
  grid::gpar(col = color, fontsize = size, fontface = face, fontfamily = family)
}

#' Define a box style
#'
#' Provides a reusable set of parameters for rounded boxes (radius, border, fill, margin, padding).
#'
#' All unit arguments must be non-negative.
#'
#' Margin layers:
#' - Box margin (`margin`, `margin_fill`) creates an inner gap around the box itself. Leave at zero for a single-layer look, or set `margin`/`margin_fill` for a double-layer/3D effect.
#' - Row/column lanes come from layout styles (e.g., [columnLayoutStyle()], [subtitleLayoutStyle()]); they sit outside the box entirely.
#'
#' @param radius Corner radius as `grid::unit`.
#' @param border_color Border color.
#' @param border_lwd Border line width (non-negative).
#' @param fill Fill color.
#' @param margin Outer margin as `grid::unit` (t, r, b, l).
#' @param margin_fill Fill color for the margin band (defaults to NA/transparent).
#' @param padding Inner padding as `grid::unit` (t, r, b, l).
#' @return A list with box styling parameters.
#' @export
#' @importFrom grid unit convertUnit
boxStyle <- function(radius     = grid::unit(8, "pt"),
                     border_color = "#D1D5DB",
                     border_lwd = 1,
                     fill       = NA,
                     margin     = grid::unit(c(0, 0, 0, 0), "pt"),
                     margin_fill= NA,
                     padding    = grid::unit(c(0, 0, 0, 0), "pt")) {
  if (length(border_lwd) != 1 || is.na(border_lwd) || border_lwd < 0) {
    stop("`border_lwd` must be length-1, non-negative.", call. = FALSE)
  }
  normalize_unit_vec <- function(u, name) {
    if (is.numeric(u)) u <- grid::unit(u, "pt")
    if (!inherits(u, "unit")) stop("`", name, "` must be a grid::unit or numeric.", call. = FALSE)
    vals <- as.numeric(grid::convertUnit(u, "pt", valueOnly = TRUE))
    if (any(is.na(vals))) stop("`", name, "` cannot contain NA.", call. = FALSE)
    if (any(vals < 0)) stop("`", name, "` must be non-negative.", call. = FALSE)
    u
  }
  radius  <- normalize_unit_vec(radius, "radius")
  margin  <- normalize_unit_vec(margin, "margin")
  padding <- normalize_unit_vec(padding, "padding")

  list(
    radius = radius,
    border_color = border_color,
    border_lwd = border_lwd,
    fill = fill,
    margin_fill = margin_fill,
    margin = margin,
    padding = padding
  )
}

#' Define banner layout defaults
#'
#' Collects geometry and color defaults for the banner row.
#'
#' All unit arguments must be non-negative.
#'
#' @param banner_height Overall banner height as `grid::unit`.
#' @param logo_panel_width Width of the left logo panel as `grid::unit`.
#' @param logo_pad_x,logo_pad_y Inner padding around the logo.
#' @param banner_bg Background color for the right text area.
#' @param logo_panel_bg Background color for the left logo panel.
#' @param text_left_pad,text_block_top_pad Padding for the text block placement.
#' @param title_vshift Vertical shift applied to the entire text block.
#' @param subtitle_gap Gap between title and subtitle.
#' @return A list of layout parameters.
#' @export
#' @importFrom grid unit
bannerLayoutStyle <- function(
    banner_height      = grid::unit(1.6, "in"),
    logo_panel_width   = grid::unit(1.8, "in"),
    logo_pad_x         = grid::unit(0.12, "in"),
    logo_pad_y         = grid::unit(0.15, "in"),
    banner_bg          = "#2f6cab",
    logo_panel_bg      = "#173052",
    text_left_pad      = grid::unit(12, "pt"),
    text_block_top_pad = grid::unit(10, "pt"),
    title_vshift       = grid::unit(0, "pt"),
    subtitle_gap       = grid::unit(6, "pt")
) {
  banner_height      <- .as_unit_nonneg(banner_height, "banner_height")
  logo_panel_width   <- .as_unit_nonneg(logo_panel_width, "logo_panel_width")
  logo_pad_x         <- .as_unit_nonneg(logo_pad_x, "logo_pad_x")
  logo_pad_y         <- .as_unit_nonneg(logo_pad_y, "logo_pad_y")
  text_left_pad      <- .as_unit_nonneg(text_left_pad, "text_left_pad")
  text_block_top_pad <- .as_unit_nonneg(text_block_top_pad, "text_block_top_pad")
  title_vshift       <- .as_unit_nonneg(title_vshift, "title_vshift")
  subtitle_gap       <- .as_unit_nonneg(subtitle_gap, "subtitle_gap")

  list(
    banner_height      = banner_height,
    logo_panel_width   = logo_panel_width,
    logo_pad_x         = logo_pad_x,
    logo_pad_y         = logo_pad_y,
    banner_bg          = banner_bg,
    logo_panel_bg      = logo_panel_bg,
    text_left_pad      = text_left_pad,
    text_block_top_pad = text_block_top_pad,
    title_vshift       = title_vshift,
    subtitle_gap       = subtitle_gap
  )
}

#' Define column layout defaults for multi-panel rows
#'
#' Collects geometry and color defaults for `str_n_panel_row`.
#' All unit arguments must be non-negative.
#'
#' @param column_bg Background color(s) for columns (recycled).
#' @param column_pad_x,column_pad_y Inner padding for columns as `grid::unit`.
#' @param column_gap Gap between columns as `grid::unit`.
#' @param column_gap_bg Background color(s) for gaps.
#' @param outer_margin,outer_margin_bg Left/right margin lanes and their fill.
#' @param bottom_margin,bottom_margin_bg Bottom margin lane and fill.
#' @return A list of column layout parameters.
#' @export
#' @importFrom grid unit
columnLayoutStyle <- function(
    column_bg        = "white",
    column_pad_x     = grid::unit(8,  "pt"),
    column_pad_y     = grid::unit(8,  "pt"),
    column_gap       = grid::unit(10, "pt"),
    column_gap_bg    = NA,
    outer_margin     = grid::unit(0, "pt"),
    outer_margin_bg  = NA,
    bottom_margin    = grid::unit(10, "pt"),
    bottom_margin_bg = NA
) {
  column_pad_x    <- .as_unit_nonneg(column_pad_x, "column_pad_x")
  column_pad_y    <- .as_unit_nonneg(column_pad_y, "column_pad_y")
  column_gap      <- .as_unit_nonneg(column_gap, "column_gap")
  outer_margin    <- .as_unit_nonneg(outer_margin, "outer_margin")
  bottom_margin   <- .as_unit_nonneg(bottom_margin, "bottom_margin")
  list(
    column_bg        = column_bg,
    column_pad_x     = column_pad_x,
    column_pad_y     = column_pad_y,
    column_gap       = column_gap,
    column_gap_bg    = column_gap_bg,
    outer_margin     = outer_margin,
    outer_margin_bg  = outer_margin_bg,
    bottom_margin    = bottom_margin,
    bottom_margin_bg = bottom_margin_bg
  )
}

#' Define subtitle row layout defaults
#'
#' Collects geometry and colors for `str_subtitle_row`.
#'
#' Margin layers:
#' - `outer_margin`/`bottom_margin` and their backgrounds control the row lanes relative to the page/canvas.
#' - Box margins/padding are controlled separately via `box_style` in `str_subtitle_row()`.
#'
#' @param row_height Total row height as `grid::unit`.
#' @param outer_margin,outer_margin_bg Left/right margin lanes and fill.
#' @param bottom_margin,bottom_margin_bg Bottom margin lane and fill.
#' @param cell_bg_cols,cell_bg_stops,cell_bg_dir Gradient/solid background for the subtitle cell.
#' @return A list of subtitle layout parameters.
#' @export
#' @importFrom grid unit
subtitleLayoutStyle <- function(
    row_height       = grid::unit(0.9, "in"),
    outer_margin     = grid::unit(15, "pt"),
    outer_margin_bg  = NA,
    bottom_margin    = grid::unit(0, "pt"),
    bottom_margin_bg = NA,
    cell_bg_cols     = c("#2f6cab", "#173052"),
    cell_bg_stops    = NULL,
    cell_bg_dir      = "lr",
    text_hjust       = "left"
) {
  row_height    <- .as_unit_nonneg(row_height, "row_height")
  outer_margin  <- .as_unit_nonneg(outer_margin, "outer_margin")
  bottom_margin <- .as_unit_nonneg(bottom_margin, "bottom_margin")
  if (!text_hjust %in% c("left","center","right")) stop("`text_hjust` must be one of: left, center, right.", call. = FALSE)
  list(
    row_height       = row_height,
    outer_margin     = outer_margin,
    outer_margin_bg  = outer_margin_bg,
    bottom_margin    = bottom_margin,
    bottom_margin_bg = bottom_margin_bg,
    cell_bg_cols     = cell_bg_cols,
    cell_bg_stops    = cell_bg_stops,
    cell_bg_dir      = cell_bg_dir,
    text_hjust       = text_hjust
  )
}

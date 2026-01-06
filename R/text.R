# Text and gradient helpers ------------------------------------------------
# Scaffolding only; implementations will be filled in.

#' Wrapped text box anchored top-left
#'
#' Renders wrapped text within a padded, rounded box inside a given viewport.
#'
#' @param label Character vector to render.
#' @param inner_vp A `grid::viewport` defining the available space.
#' @param gp A `grid::gpar` for text styling.
#' @param preserve_newlines Whether to keep newline breaks.
#' @param prefer_gridtext Whether to prefer `gridtext::textbox_grob`.
#' @param box_r Corner radius as `grid::unit`.
#' @param box_border_col,box_border_lwd,box_fill Border styling.
#' @param box_margin Outer margin as `grid::unit`.
#' @param text_pad Inner padding as `grid::unit`.
#' @return A grob representing the wrapped text box.
#' @export
wrap_text_top_left <- function(
    label,
    inner_vp,
    gp = gpar(col = "#111111", fontsize = 11, fontface = "plain", fontfamily = "sans"),
    preserve_newlines = TRUE,
    prefer_gridtext   = TRUE,
    box_r             = unit(6, "pt"),
    box_border_col    = "#CBD5E1",
    box_border_lwd    = 1,
    box_fill          = NA,
    box_margin        = unit(c(6, 6, 6, 6), "pt"),
    text_pad          = unit(c(4, 6, 4, 6), "pt")
) {
  stop("TODO: implement wrap_text_top_left")
}

#' Internal: subtitle cell with gradient and rounded corners
#'
#' @keywords internal
.subtitle_cell <- function(
    label,
    cell_bg_cols    = c("#2f6cab", "#173052"),
    cell_bg_stops   = NULL,
    cell_bg_dir     = "lr",
    box_r           = unit(10, "pt"),
    box_border_col  = NA,
    box_border_lwd  = 1,
    text_gp         = gpar(col = "white", fontsize = 16, fontfamily = "Noto Sans", fontface = "bold"),
    text_pad        = unit(c(10, 14, 10, 14), "pt"),
    box_margin      = unit(c(6, 6, 6, 6), "pt")
) {
  stop("TODO: implement .subtitle_cell")
}

#' Internal: gradient fill helper
#'
#' @keywords internal
.gradient_fill <- function(cols, stops = NULL, dir = "lr") {
  stop("TODO: implement .gradient_fill")
}

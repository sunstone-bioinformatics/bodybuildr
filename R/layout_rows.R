# Layout row builders ------------------------------------------------------
# Scaffolding only; implementations will be filled in.

#' Multi-column row layout (1..n columns)
#'
#' Accepts ggplot objects, grobs, image paths, or character vectors and renders them
#' into equal-width columns with configurable padding, gaps, and lanes.
#'
#' @param items A list of items (ggplot/grob/image path/character/NULL).
#' @param ... Additional parameters for sizing, spacing, and styling.
#' @return A `gtable` representing the row.
#' @export
str_n_panel_row <- function(items, ...) {
  stop("TODO: implement str_n_panel_row")
}

#' Three-panel row layout (A | B over C)
#'
#' Places a tall left panel next to two stacked right panels, with padding and lane options.
#'
#' @param A_item,B_item,C_item Items to render (ggplot/grob/image path/character/NULL).
#' @param ... Additional parameters for sizing, spacing, and styling.
#' @return A `gtable` representing the row.
#' @export
str_three_panel_row <- function(A_item = NULL, B_item = NULL, C_item = NULL, ...) {
  stop("TODO: implement str_three_panel_row")
}

#' Subtitle row layout
#'
#' Renders a full-width subtitle band with optional gradient fill and lanes.
#'
#' @param label Subtitle text.
#' @param ... Additional parameters for sizing and styling.
#' @return A `gtable` representing the row.
#' @export
str_subtitle_row <- function(label, ...) {
  stop("TODO: implement str_subtitle_row")
}

#' Two-column banner with logo and text
#'
#' Builds a banner with a fixed-width image lane on the left and title/subtitle text on the right.
#'
#' @param image_path Path to a PNG/JPEG logo.
#' @param title,subtitle Text content.
#' @param ... Additional parameters for sizing and styling.
#' @return A `gtable` representing the banner.
#' @export
str_banner_row <- function(image_path, title = "Project Title", subtitle = "Concise one-liner", ...) {
  stop("TODO: implement banner_grob")
}

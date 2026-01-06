# Canvas helpers and exports ----------------------------------------------
# Scaffolding only; implementations will be filled in.

#' Create a new canvas gtable
#'
#' Initializes an empty vertical stack to which rows can be appended.
#'
#' @return A `gtable` object representing an empty canvas.
#' @export
new_canvas <- function() {
  stop("TODO: implement new_canvas")
}

#' Append a row to a canvas
#'
#' Adds a grob as a new row at the bottom of an existing canvas.
#'
#' @param canvas A `gtable` produced by `new_canvas()`.
#' @param grob A grob/gtable to insert as the next row.
#' @param height A `grid::unit` giving the row height.
#' @return The updated `gtable` with the new row added.
#' @export
canvas_add_row <- function(canvas, grob, height) {
  stop("TODO: implement canvas_add_row")
}

#' Draw a canvas top-aligned
#'
#' Renders a grob anchored at the top-left of the device with optional page margins.
#'
#' @param grob A grob/gtable to draw.
#' @param margin_top,margin_right,margin_bottom,margin_left Page margins as `grid::unit`.
#' @return Invisibly draws to the current device.
#' @export
draw_canvas_top <- function(grob,
                            margin_top    = unit(0, "in"),
                            margin_right  = unit(0, "in"),
                            margin_bottom = unit(0, "in"),
                            margin_left   = unit(0, "in")) {
  stop("TODO: implement draw_canvas_top")
}

#' Export a canvas to PDF (top-anchored)
#'
#' Opens a PDF device, draws a grob top-aligned, and closes the device.
#'
#' @param grob A grob/gtable to export.
#' @param file Output PDF path.
#' @param width_in,height_in PDF dimensions in inches.
#' @param margin_top_in,margin_right_in,margin_bottom_in,margin_left_in Margins in inches.
#' @return Invisibly returns the output file path.
#' @export
export_pdf_top <- function(grob, file = "infographic_layout.pdf",
                           width_in = 8.5, height_in = 11,
                           margin_top_in = 0, margin_right_in = 0,
                           margin_bottom_in = 0, margin_left_in = 0) {
  stop("TODO: implement export_pdf_top")
}

#' Convert `grid::unit` to inches
#'
#' Robust conversion helper for unit objects.
#'
#' @param u A `grid::unit` object.
#' @return Numeric length in inches.
#' @export
to_in <- function(u) {
  stop("TODO: implement to_in")
}

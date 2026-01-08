# Canvas helpers and exports ----------------------------------------------

#' Create a new canvas gtable
#'
#' Initializes an empty vertical stack to which rows can be appended.
#'
#' @return A `gtable` object representing an empty canvas.
#' @export
#' @importFrom grid unit
#' @importFrom gtable gtable
new_canvas <- function() {
  gtable(
    widths  = unit(1, "null"),
    heights = unit(0, "pt")
  )
}

#' Internal: coerce to non-negative unit
#'
#' @param x A `grid::unit` or numeric inches.
#' @param name Name used in error messages.
#' @return A length-1 `unit` object.
#' @keywords internal
#' @importFrom grid unit convertUnit
.as_unit_nonneg <- function(x, name) {
  if (inherits(x, "unit")) {
    u <- x
  } else if (is.numeric(x)) {
    u <- unit(x, "in")
  } else {
    stop("`", name, "` must be a unit or numeric (inches).", call. = FALSE)
  }
  vals <- as.numeric(convertUnit(u, "in", valueOnly = TRUE))
  if (length(vals) != 1) stop("`", name, "` must be length 1.", call. = FALSE)
  if (any(is.na(vals))) stop("`", name, "` cannot be NA.", call. = FALSE)
  if (any(vals < 0)) stop("`", name, "` must be non-negative.", call. = FALSE)
  u
}

#' Append a row to a canvas
#'
#' Adds a grob as a new row at the bottom of an existing canvas.
#'
#' @param canvas A `gtable` produced by `new_canvas()`.
#' @param grob A grob/gtable to insert as the next row.
#' @param height A non-negative `grid::unit` giving the row height.
#' @return The updated `gtable` with the new row added.
#' @export
#' @importFrom gtable gtable_add_rows gtable_add_grob
canvas_add_row <- function(canvas, grob, height) {
  height <- .as_unit_nonneg(height, "height")
  canvas <- gtable_add_rows(canvas, heights = height, pos = nrow(canvas))
  canvas <- gtable_add_grob(canvas, grob, t = nrow(canvas), l = 1, z = 1, clip = "off")
  canvas
}

#' Internal: draw a canvas top-aligned
#'
#' Renders a grob anchored at the top-left of the device with optional page margins.
#'
#' @param grob A grob/gtable to draw.
#' @param margin_top,margin_right,margin_bottom,margin_left Page margins as non-negative `grid::unit`.
#' @param clip Logical; if `TRUE`, content outside the margin-constrained viewport is clipped.
#' @return Invisibly draws to the current device.
#' @keywords internal
#' @importFrom grid grobHeight pushViewport viewport popViewport grid.draw unit
.draw_canvas_top <- function(grob,
                             margin_top    = unit(0, "in"),
                             margin_right  = unit(0, "in"),
                             margin_bottom = unit(0, "in"),
                             margin_left   = unit(0, "in"),
                             clip          = TRUE) {
  margin_top    <- .as_unit_nonneg(margin_top, "margin_top")
  margin_right  <- .as_unit_nonneg(margin_right, "margin_right")
  margin_bottom <- .as_unit_nonneg(margin_bottom, "margin_bottom")
  margin_left   <- .as_unit_nonneg(margin_left, "margin_left")

  content_h <- grobHeight(grob)
  pushViewport(viewport(
    x = margin_left,
    y = unit(1, "npc") - margin_top,
    width  = unit(1, "npc") - margin_left - margin_right,
    height = content_h,
    just = c("left", "top"),
    clip = if (isTRUE(clip)) "on" else "off"
  ))
  on.exit(popViewport(), add = TRUE)
  grid.draw(grob)
  invisible(grob)
}

#' Export a canvas to PDF (top-anchored)
#'
#' Opens a PDF device, draws a grob top-aligned, and closes the device.
#'
#' @param grob A grob/gtable to export.
#' @param file Output PDF path.
#' @param width,height Page dimensions as non-negative `grid::unit` (length 1).
#' @param margin_top,margin_right,margin_bottom,margin_left Page margins as non-negative `grid::unit`
#'   (length 1).
#' @return Invisibly returns the output file path.
#' @export
#' @importFrom grid unit grid.newpage
#' @importFrom grDevices pdf dev.off
export_pdf <- function(grob, file = "infographic_layout.pdf",
                       width = unit(8.5, "in"),
                       height = unit(11, "in"),
                       margin_top = unit(0, "in"),
                       margin_right = unit(0, "in"),
                       margin_bottom = unit(0, "in"),
                       margin_left = unit(0, "in")) {
  width  <- .as_unit_nonneg(width, "width")
  height <- .as_unit_nonneg(height, "height")
  mt <- .as_unit_nonneg(margin_top, "margin_top")
  mr <- .as_unit_nonneg(margin_right, "margin_right")
  mb <- .as_unit_nonneg(margin_bottom, "margin_bottom")
  ml <- .as_unit_nonneg(margin_left, "margin_left")

  width_in  <- .to_in(width)
  height_in <- .to_in(height)

  pdf(file, width = width_in, height = height_in, useDingbats = FALSE)
  on.exit(dev.off(), add = TRUE)
  grid.newpage()
  .draw_canvas_top(
    grob,
    margin_top    = mt,
    margin_right  = mr,
    margin_bottom = mb,
    margin_left   = ml
  )
  invisible(file)
}

#' @rdname export_pdf
#' @export
export_pdf_top <- export_pdf

#' Internal: convert `grid::unit` to inches
#'
#' Robust conversion helper for unit objects.
#'
#' @param u A `grid::unit` object.
#' @return Numeric length in inches.
#' @keywords internal
#' @importFrom grid convertUnit
.to_in <- function(u) {
  if (!inherits(u, "unit")) stop(".to_in() expects a unit object.")
  as.numeric(convertUnit(u, "in", valueOnly = TRUE))
}

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
    gp = grid::gpar(col = "#111111", fontsize = 11, fontface = "plain", fontfamily = "sans"),
    preserve_newlines = TRUE,
    prefer_gridtext   = TRUE,
    box_r             = grid::unit(6, "pt"),
    box_border_col    = "#CBD5E1",
    box_border_lwd    = 1,
    box_fill          = NA,
    box_margin        = grid::unit(c(6, 6, 6, 6), "pt"),
    text_pad          = grid::unit(c(4, 6, 4, 6), "pt")
) {
  if (is.null(label)) label <- ""
  if (length(label) > 1) label <- paste(label, collapse = "\n")

  # normalize margin/padding into (t,r,b,l)
  norm_trbl <- function(u) {
    if (!inherits(u, "unit")) stop("Expect grid::unit for margins/padding")
    if (length(u) == 1) rep(u, 4)
    else if (length(u) == 2) grid::unit(c(u[1], u[2], u[1], u[2]), attr(u, "unit"))
    else if (length(u) == 4) u
    else stop("Use length 1, 2, or 4 for margin/padding")
  }
  box_margin <- norm_trbl(box_margin)
  text_pad   <- norm_trbl(text_pad)

  # Build an inner viewport that accounts for the OUTER margin
  box_vp <- grid::viewport(
    x = grid::unit(0, "npc") + box_margin[4],
    y = grid::unit(1, "npc") - box_margin[1],
    width  = grid::unit(1, "npc") - (box_margin[2] + box_margin[4]),
    height = grid::unit(1, "npc") - (box_margin[1] + box_margin[3]),
    just = c("left","top"),
    clip = "on"
  )

  # Preferred path: gridtext
  if (prefer_gridtext && requireNamespace("gridtext", quietly = TRUE)) {
    txt <- if (preserve_newlines) label else gsub("\n+", " ", label)

    tb <- gridtext::textbox_grob(
      txt,
      x = grid::unit(0, "npc"), y = grid::unit(1, "npc"),
      hjust = 0, vjust = 1,
      width = grid::unit(1, "npc"),
      box_gp = grid::gpar(col = box_border_col, fill = box_fill, lwd = box_border_lwd),
      r = box_r,
      padding = text_pad,
      margin  = grid::unit(c(0, 0, 0, 0), "pt"),
      gp = gp
    )
    return(grid::grobTree(tb, vp = grid::vpStack(inner_vp, box_vp)))
  }

  # Fallback: approximate char-based wrap
  grid::pushViewport(inner_vp)
  grid::pushViewport(box_vp)
  on.exit({
    grid::popViewport(2)
  }, add = TRUE)

  inner_w <- grid::convertWidth(grid::unit(1, "npc") - (text_pad[2] + text_pad[4]), "inch", valueOnly = TRUE)
  sample_str <- paste(rep("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", 3), collapse = "")
  avg_char_in <- grid::convertWidth(grid::stringWidth(sample_str), "inch", valueOnly = TRUE) / nchar(sample_str)
  if (!is.finite(avg_char_in) || avg_char_in <= 0) avg_char_in <- 0.1
  wrap_chars <- max(1L, floor(inner_w / avg_char_in))

  wrap_lines <- function(text, width_chars) {
    if (preserve_newlines) {
      paras <- strsplit(text, "\n", fixed = TRUE)[[1]]
      unlist(lapply(paras, function(p) if (nchar(p) == 0) "" else strwrap(p, width = width_chars)))
    } else {
      strwrap(text, width = width_chars)
    }
  }
  lines <- wrap_lines(label, wrap_chars)
  wrapped_text <- paste(lines, collapse = "\n")

  # OUTER rounded border
  rr <- grid::roundrectGrob(
    x = grid::unit(0.5, "npc"), y = grid::unit(0.5, "npc"),
    width = grid::unit(1, "npc"), height = grid::unit(1, "npc"),
    r = box_r,
    gp = grid::gpar(col = box_border_col, fill = box_fill, lwd = box_border_lwd)
  )
  # Text placed with INNER padding
  txt_g <- grid::textGrob(
    wrapped_text,
    x = grid::unit(0, "npc") + text_pad[4],
    y = grid::unit(1, "npc") - text_pad[1],
    just = c("left","top"),
    gp = gp
  )
  grid::grobTree(rr, txt_g, vp = inner_vp)
}

#' Internal: subtitle cell with gradient and rounded corners
#'
#' @keywords internal
.subtitle_cell <- function(
    label,
    cell_bg_cols    = c("#2f6cab", "#173052"),
    cell_bg_stops   = NULL,
    cell_bg_dir     = "lr",
    box_r           = grid::unit(10, "pt"),
    box_border_col  = NA,
    box_border_lwd  = 1,
    text_gp         = grid::gpar(col = "white", fontsize = 16, fontfamily = "Noto Sans", fontface = "bold"),
    text_pad        = grid::unit(c(10, 14, 10, 14), "pt"),
    box_margin      = grid::unit(c(6, 6, 6, 6), "pt")
) {
  if (is.null(label)) label <- ""
  if (length(label) > 1) label <- paste(label, collapse = "\n")

  top_m    <- box_margin[1]; right_m <- box_margin[2]
  bot_m    <- box_margin[3]; left_m  <- box_margin[4]

  x <- grid::unit(0, "npc") + left_m
  y <- grid::unit(1, "npc") - top_m
  w <- grid::unit(1, "npc") - (left_m + right_m)
  h <- grid::unit(1, "npc") - (top_m  + bot_m)

  fill <- .gradient_fill(cell_bg_cols, cell_bg_stops, cell_bg_dir)

  bg_roundrect <- grid::roundrectGrob(
    x = x, y = y, width = w, height = h,
    just = c("left","top"),
    r = box_r,
    gp = grid::gpar(fill = fill, col = box_border_col, lwd = box_border_lwd)
  )

  txt <- gridtext::textbox_grob(
    label,
    x = x, y = y,
    width  = w,
    height = h,
    hjust = 0, vjust = 1,
    gp = text_gp,
    padding = text_pad,
    margin  = grid::unit(c(0,0,0,0), "pt"),
    r = grid::unit(0, "pt"),
    box_gp = grid::gpar(col = NA, fill = NA)
  )

  grid::grobTree(bg_roundrect, txt)
}

#' Internal: gradient fill helper
#'
#' @keywords internal
.gradient_fill <- function(cols, stops = NULL, dir = "lr") {
  has_grad <- "linearGradient" %in% getNamespaceExports("grid")
  if (!has_grad || length(cols) < 2) return(cols[1])
  if (is.null(stops)) stops <- seq(0, 1, length.out = length(cols))
  xy <- switch(
    dir,
    lr   = list(x1=0, y1=0.5, x2=1, y2=0.5),
    rl   = list(x1=1, y1=0.5, x2=0, y2=0.5),
    tb   = list(x1=0.5, y1=1,   x2=0.5, y2=0),
    bt   = list(x1=0.5, y1=0,   x2=0.5, y2=1),
    tlbr = list(x1=0, y1=1,     x2=1,   y2=0),
    bltr = list(x1=0, y1=0,     x2=1,   y2=1),
    trbl = list(x1=1, y1=1,     x2=0,   y2=0),
    brtl = list(x1=1, y1=0,     x2=0,   y2=1),
    list(x1=0, y1=0.5, x2=1, y2=0.5)
  )
  grid::linearGradient(
    colours = cols, stops = stops,
    x1 = grid::unit(xy$x1, "npc"), y1 = grid::unit(xy$y1, "npc"),
    x2 = grid::unit(xy$x2, "npc"), y2 = grid::unit(xy$y2, "npc")
  )
}

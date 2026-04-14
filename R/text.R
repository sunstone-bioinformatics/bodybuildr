# Text and gradient helpers ------------------------------------------------
# Scaffolding only; implementations will be filled in.

#' Construct a styled text box item
#'
#' Creates a text box payload that can be passed into layout functions (e.g., `str_n_panel_row`)
#' with its own text and box styles.
#'
#' @param label Character text to render.
#' @param text_style A `gpar` from [text_style()].
#' @param box_style A list from [box_style()].
#' @param bg Optional column background color override.
#' @param pad_x,pad_y Optional column padding overrides as `grid::unit` (non-negative).
#' @return An object of class `"bbdr_text_box"` to use as an item in layout rows.
#' @export
text_box <- function(
    label,
    text_style = NULL,
    box_style  = NULL,
    bg         = NULL,
    pad_x      = NULL,
    pad_y      = NULL
) {
  if (is.null(label)) label <- ""
  if (is.null(text_style)) {
    text_style <- get("text_style", envir = parent.env(environment()))()
  }
  if (is.null(box_style)) {
    box_style <- get("box_style", envir = parent.env(environment()))()
  }
  if (!inherits(text_style, "gpar")) stop("`text_style` must be a gpar (use text_style()).", call. = FALSE)
  if (!is.list(box_style)) stop("`box_style` must be a list (use box_style()).", call. = FALSE)
  if (!is.null(pad_x)) pad_x <- .as_unit_nonneg(pad_x, "pad_x")
  if (!is.null(pad_y)) pad_y <- .as_unit_nonneg(pad_y, "pad_y")
  structure(
    list(
      label = label,
      text_style = text_style,
      box_style = box_style,
      bg = bg,
      pad_x = pad_x,
      pad_y = pad_y
    ),
    class = "bbdr_text_box"
  )
}

#' Construct an intentional empty layout box
#'
#' Creates a blank layout payload that can be passed into row layout functions when
#' you want an explicit empty slot in the composition.
#'
#' Unlike `NULL`, which means missing content, `blank_box()` means a deliberate
#' empty layout element that still participates in row geometry.
#'
#' @return An object of class `"bbdr_blank_box"` to use as an item in layout rows.
#' @export
blank_box <- function() {
  structure(list(), class = "bbdr_blank_box")
}

#' Internal: wrapped text box anchored top-left
#'
#' Internal helper used by layout row builders to render wrapped text inside a padded, rounded box.
#' Users should construct text content via [text_box()] or pass character vectors to layout functions;
#' this helper is not part of the public API.
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
#' @keywords internal
#' @importFrom grid gpar unit viewport grobTree vpStack pushViewport popViewport convertWidth stringWidth roundrectGrob textGrob rectGrob
#' @importFrom gridtext textbox_grob
.wrap_text_top_left <- function(
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
  if (is.null(label)) label <- ""
  if (length(label) > 1) label <- paste(label, collapse = "\n")

  # normalize margin/padding into (t,r,b,l)
  norm_trbl <- function(u) {
    if (!inherits(u, "unit")) stop("Expect unit for margins/padding")
    if (length(u) == 1) rep(u, 4)
    else if (length(u) == 2) unit(c(u[1], u[2], u[1], u[2]), attr(u, "unit"))
    else if (length(u) == 4) u
    else stop("Use length 1, 2, or 4 for margin/padding")
  }
  box_margin <- norm_trbl(box_margin)
  text_pad   <- norm_trbl(text_pad)

  # Build an inner viewport that accounts for the OUTER margin
  box_vp <- viewport(
    x = unit(0, "npc") + box_margin[4],
    y = unit(1, "npc") - box_margin[1],
    width  = unit(1, "npc") - (box_margin[2] + box_margin[4]),
    height = unit(1, "npc") - (box_margin[1] + box_margin[3]),
    just = c("left","top"),
    clip = "on"
  )

  # Preferred path: gridtext
  if (prefer_gridtext && requireNamespace("gridtext", quietly = TRUE)) {
    txt <- if (preserve_newlines) label else gsub("\n+", " ", label)

    tb <- textbox_grob(
      txt,
      x = unit(0, "npc"), y = unit(1, "npc"),
      hjust = 0, vjust = 1,
      width = unit(1, "npc"),
      box_gp = gpar(col = box_border_col, fill = box_fill, lwd = box_border_lwd),
      r = box_r,
      padding = text_pad,
      margin  = unit(c(0, 0, 0, 0), "pt"),
      gp = gp
    )
    return(grobTree(tb, vp = vpStack(inner_vp, box_vp)))
  }

  # Fallback: approximate char-based wrap
  pushViewport(inner_vp)
  pushViewport(box_vp)
  on.exit({
    popViewport(2)
  }, add = TRUE)

  inner_w <- convertWidth(unit(1, "npc") - (text_pad[2] + text_pad[4]), "inch", valueOnly = TRUE)
  sample_str <- paste(rep("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", 3), collapse = "")
  avg_char_in <- convertWidth(stringWidth(sample_str), "inch", valueOnly = TRUE) / nchar(sample_str)
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
  rr <- roundrectGrob(
    x = unit(0.5, "npc"), y = unit(0.5, "npc"),
    width = unit(1, "npc"), height = unit(1, "npc"),
    r = box_r,
    gp = gpar(col = box_border_col, fill = box_fill, lwd = box_border_lwd)
  )
  # Text placed with INNER padding
  txt_g <- textGrob(
    wrapped_text,
    x = unit(0, "npc") + text_pad[4],
    y = unit(1, "npc") - text_pad[1],
    just = c("left","top"),
    gp = gp
  )
  grobTree(rr, txt_g, vp = inner_vp)
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
    text_gp         = gpar(col = "white", fontsize = 16, fontfamily = "sans", fontface = "bold"),
    text_pad        = unit(c(10, 14, 10, 14), "pt"),
    box_margin      = unit(c(6, 6, 6, 6), "pt"),
    text_hjust      = "left",
    margin_fill     = NA
) {
  if (is.null(label)) label <- ""
  if (length(label) > 1) label <- paste(label, collapse = "\n")

  top_m    <- box_margin[1]; right_m <- box_margin[2]
  bot_m    <- box_margin[3]; left_m  <- box_margin[4]

  x <- unit(0, "npc") + left_m
  y <- unit(1, "npc") - top_m
  w <- unit(1, "npc") - (left_m + right_m)
  h <- unit(1, "npc") - (top_m  + bot_m)

  fill <- .gradient_fill(cell_bg_cols, cell_bg_stops, cell_bg_dir)

  border_col <- box_border_col
  border_lwd <- box_border_lwd
  if (is.null(border_col) || is.na(border_col)) {
    border_col <- fill
    border_lwd <- 0
  }

  bg_roundrect <- roundrectGrob(
    x = x, y = y, width = w, height = h,
    just = c("left","top"),
    r = box_r,
    gp = gpar(fill = fill, col = border_col, lwd = border_lwd)
  )

  hjust_val <- switch(text_hjust, left = 0, center = 0.5, right = 1, 0)
  content_vp <- viewport(
    x = x, y = y,
    width = w, height = h,
    just = c("left","top"),
    clip = "on"
  )

  margin_bg <- NULL
  if (!is.null(margin_fill) && !is.na(margin_fill)) {
    margin_bg <- rectGrob(
      x = unit(0.5, "npc"), y = unit(0.5, "npc"),
      width = unit(1, "npc"), height = unit(1, "npc"),
      just = c("center","center"),
      gp = gpar(fill = margin_fill, col = NA)
    )
  }

  txt <- textbox_grob(
    label,
    x = unit(hjust_val, "npc"),
    y = unit(1, "npc"),
    width  = unit(1, "npc"),
    height = unit(1, "npc"),
    hjust = hjust_val, vjust = 1,
    halign = hjust_val,
    gp = text_gp,
    padding = text_pad,
    margin  = unit(c(0,0,0,0), "pt"),
    r = unit(0, "pt"),
    box_gp = gpar(col = NA, fill = NA),
    vp = content_vp
  )

  grobTree(margin_bg, bg_roundrect, txt)
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
  linear_grad <- getFromNamespace("linearGradient", "grid")
  linear_grad(
    colours = cols, stops = stops,
    x1 = unit(xy$x1, "npc"), y1 = unit(xy$y1, "npc"),
    x2 = unit(xy$x2, "npc"), y2 = unit(xy$y2, "npc")
  )
}

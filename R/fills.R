# Fills ----------------------------------------------------------------------------

#' Gradient and stripe fills
#'
#' Fills for [box_style()] and [bb_placeholder()].
#'
#' `gradient_fill()` uses grid's linear gradients (R >= 4.1 on a device that
#' supports them, such as `cairo_pdf()`); elsewhere it falls back to the
#' first colour.
#'
#' `stripe_fill()` draws diagonal bands as clipped polygons, so it works on
#' every device. The first colour is the ground, the second the stripes.
#'
#' @param colors Colours (theme names allowed). Two or more for gradients;
#'   exactly two for stripes.
#' @param stops Optional gradient stops in `[0, 1]`.
#' @param dir Gradient direction: `"lr"`, `"rl"`, `"tb"`, `"bt"`, `"tlbr"`,
#'   `"bltr"`, `"trbl"` or `"brtl"`.
#' @param angle Stripe angle in degrees from horizontal (0 < angle < 180).
#' @param width Stripe width (`grid::unit` or inches). Gaps have the same
#'   width.
#' @return A `bb_fill` object.
#' @examples
#' gradient_fill(c("#2f6cab", "#173052"))
#' stripe_fill(c("panel", "panel_alt"), angle = 45, width = unit(8, "pt"))
#' @export
gradient_fill <- function(colors, stops = NULL, dir = "lr") {
  if (length(colors) < 2) stop("`colors` needs at least two colours.", call. = FALSE)
  dir <- match.arg(dir, c("lr", "rl", "tb", "bt", "tlbr", "bltr", "trbl", "brtl"))
  if (!is.null(stops) && length(stops) != length(colors)) {
    stop("`stops` must match `colors` in length.", call. = FALSE)
  }
  structure(list(type = "gradient", colors = colors, stops = stops, dir = dir), class = "bb_fill")
}

#' @rdname gradient_fill
#' @export
stripe_fill <- function(colors = c("panel", "panel_alt"), angle = 45, width = 8 / 96) {
  if (length(colors) != 2) stop("`colors` must have exactly two colours.", call. = FALSE)
  if (!is.numeric(angle) || length(angle) != 1 || angle <= 0 || angle >= 180) {
    stop("`angle` must be between 0 and 180 (exclusive).", call. = FALSE)
  }
  w <- .in(width, "width")
  if (w <= 0) stop("`width` must be positive.", call. = FALSE)
  structure(list(type = "stripes", colors = colors, angle = angle, width = w), class = "bb_fill")
}

#' @noRd
.check_fill <- function(fill) {
  if (inherits(fill, "bb_fill")) return(invisible(TRUE))
  if (length(fill) == 1 && (is.na(fill) || is.character(fill))) return(invisible(TRUE))
  stop("`fill` must be a colour, NA, gradient_fill() or stripe_fill().", call. = FALSE)
}

#' @noRd
.gradient <- function(f) {
  cols <- .col(f$colors)
  if (!"linearGradient" %in% getNamespaceExports("grid")) return(cols[1])
  stops <- f$stops %||% seq(0, 1, length.out = length(cols))
  xy <- switch(f$dir,
    lr = c(0, .5, 1, .5), rl = c(1, .5, 0, .5), tb = c(.5, 1, .5, 0), bt = c(.5, 0, .5, 1),
    tlbr = c(0, 1, 1, 0), bltr = c(0, 0, 1, 1), trbl = c(1, 1, 0, 0), brtl = c(1, 0, 0, 1))
  lg <- getExportedValue("grid", "linearGradient")
  lg(colours = cols, stops = stops,
     x1 = unit(xy[1], "npc"), y1 = unit(xy[2], "npc"),
     x2 = unit(xy[3], "npc"), y2 = unit(xy[4], "npc"))
}

#' Internal: stripe polygons covering a w x h inch viewport
#' @noRd
.stripes_grob <- function(w, h, f) {
  theta <- f$angle * pi / 180
  band <- f$width / sin(theta)          # horizontal width of one band
  run <- if (abs(f$angle - 90) < 1e-9) 0 else h / tan(theta)  # x shift from bottom to top
  lo <- min(0, -run) - band
  hi <- max(w, w - run) + band
  offs <- seq(lo, hi, by = 2 * band)
  if (!length(offs)) return(nullGrob())
  xs <- as.vector(rbind(offs, offs + band, offs + band + run, offs + run))
  ys <- rep(c(0, 0, h, h), length(offs))
  polygonGrob(x = unit(xs, "in"), y = unit(ys, "in"), id = rep(seq_along(offs), each = 4),
              gp = gpar(fill = .col(f$colors[2]), col = NA))
}

#' Internal: filled (and optionally bordered) shape filling a w x h viewport
#' @noRd
.shape_grob <- function(fill, w, h, radius = 0, border = NULL) {
  shape <- function(gp) {
    if (radius > 0) roundrectGrob(r = unit(radius, "in"), gp = gp) else rectGrob(gp = gp)
  }
  kids <- gList()
  if (inherits(fill, "bb_fill") && fill$type == "stripes") {
    kids <- gList(shape(gpar(fill = .col(fill$colors[1]), col = NA)),
                  gTree(children = gList(.stripes_grob(w, h, fill)),
                        vp = viewport(clip = "on")))
  } else if (inherits(fill, "bb_fill")) {
    kids <- gList(shape(gpar(fill = .gradient(fill), col = NA)))
  } else if (!is.na(fill)) {
    kids <- gList(shape(gpar(fill = .col(fill), col = NA)))
  }
  if (.has_line(border)) {
    gp <- .line_gp(border)
    gp$fill <- NA
    kids <- gList(kids, shape(gp))
  }
  gTree(children = kids)
}

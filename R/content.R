# Plots, grobs and images ------------------------------------------------------------

#' Plot block
#'
#' Wraps a ggplot. Without a `height` the block is flexible: in [bb_cols()] it
#' takes the height of its tallest sibling, in a page body it shares the
#' spare height.
#'
#' @param p A ggplot object.
#' @param height `grid::unit`, inches, or `NULL` for flexible.
#' @param min_height Smallest height a flexible plot may be given (keeps a
#'   plot legible next to a very short sibling).
#' @return A block.
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point()
#'   bb_plot(p, height = 2)
#' }
#' @export
bb_plot <- function(p, height = NULL, min_height = 0) {
  if (!inherits(p, "ggplot")) stop("`p` must be a ggplot object.", call. = FALSE)
  h <- .in(height, "height", allow_null = TRUE)
  mh <- .in(min_height, "min_height")
  # Built when drawn: ggplotGrob() measures text, which needs the right device.
  new_block("plot",
            measure = function(width) if (is.null(h)) NA_real_ else h,
            min_height = function(width) mh,
            render = function(width, height) with_measure_device(ggplot2::ggplotGrob(p)))
}

#' Grob block
#'
#' Wraps any grob, gTree or gtable, drawn to fill the space it is given.
#'
#' @param g A grob.
#' @param height `grid::unit` or inches; `NULL` for flexible; `"auto"` to
#'   measure `grid::grobHeight(g)` (for grobs with an absolute height). A
#'   numeric `"height_in"` attribute on `g` is used when `height` is `NULL`.
#' @return A block.
#' @examples
#' bb_grob(grid::rectGrob(gp = grid::gpar(fill = "grey90")), height = 0.3)
#' @export
bb_grob <- function(g, height = NULL) {
  if (!inherits(g, "grob")) stop("`g` must be a grob.", call. = FALSE)
  if (is.null(height) && is.numeric(attr(g, "height_in"))) height <- attr(g, "height_in")
  auto <- identical(height, "auto")
  h <- if (auto) NULL else .in(height, "height", allow_null = TRUE)
  new_block("grob",
            measure = function(width) {
              if (auto) return(.grob_h_in(g))
              if (is.null(h)) NA_real_ else h
            },
            render = function(width, height) g)
}

#' @noRd
.read_image <- function(src) {
  if (is.character(src)) {
    if (length(src) != 1 || !file.exists(src)) stop("Image file not found: ", src, call. = FALSE)
    ext <- tolower(tools::file_ext(src))
    return(switch(ext,
      png = png::readPNG(src),
      jpg = , jpeg = jpeg::readJPEG(src),
      stop("Unsupported image type: .", ext, " (use png or jpg).", call. = FALSE)))
  }
  if (inherits(src, c("raster", "nativeRaster")) || (is.array(src) && is.numeric(src))) return(src)
  stop("`src` must be a png/jpg path, a numeric array or a raster.", call. = FALSE)
}

#' @noRd
.img_aspect <- function(img) {
  d <- dim(img)
  if (length(d) < 2 || d[1] <= 0) return(1)
  d[2] / d[1]
}

#' Image block
#'
#' A PNG/JPEG file, numeric array or raster. Without a `height`, the block is
#' as tall as the image at the given width (its natural aspect ratio).
#'
#' @param src Path to a `.png`/`.jpg` file, a numeric array, or a raster.
#' @param height `grid::unit`, inches, or `NULL` for the natural height.
#' @param fit `"contain"` keeps the aspect ratio inside the slot; `"fill"`
#'   stretches to the slot.
#' @param align Horizontal position when the image is narrower than its slot:
#'   `"left"`, `"center"` or `"right"`.
#' @return A block.
#' @examples
#' img <- array(c(0.2, 0.4, 0.8), dim = c(1, 1, 3))
#' bb_image(img, height = 0.5)
#' @export
bb_image <- function(src, height = NULL, fit = c("contain", "fill"),
                     align = c("center", "left", "right")) {
  fit <- match.arg(fit); align <- match.arg(align)
  img <- .read_image(src)
  aspect <- .img_aspect(img)
  h <- .in(height, "height", allow_null = TRUE)
  box <- function(width, height) {
    if (fit == "fill") return(c(width, height))
    if (width / max(height, 1e-9) > aspect) c(height * aspect, height) else c(width, width / aspect)
  }
  new_block("image",
            measure = function(width) if (is.null(h)) width / aspect else h,
            natural_width = function(width) box(width, if (is.null(h)) width / aspect else h)[1],
            render = function(width, height) {
              b <- box(width, height)
              x <- switch(align, left = 0, right = width - b[1], (width - b[1]) / 2)
              rasterGrob(img, x = unit(x, "in"), y = unit(1, "npc") - unit((height - b[2]) / 2, "in"),
                         width = unit(b[1], "in"), height = unit(b[2], "in"),
                         just = c("left", "top"), interpolate = TRUE)
            })
}

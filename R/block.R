# Blocks -------------------------------------------------------------------------
# A block is the unit of layout. It answers two questions:
#   measure(width)         -> height in inches, or NA when it is flexible
#   render(width, height)  -> a grob drawn from the top-left of a viewport of
#                             exactly that size
# Containers pass widths down and collect heights up, so components never
# need to be told their width by hand.

#' Build a custom block
#'
#' Low-level constructor for blocks. Most users combine the built-in blocks;
#' use this to wrap a custom drawing that should take part in layout.
#'
#' @param type Short type name; the block gets class `bb_<type>`.
#' @param measure `function(width)` returning the height in inches at that
#'   width, or `NA` when the block is flexible (it takes whatever height its
#'   container gives it).
#' @param render `function(width, height)` returning a grob that draws inside
#'   a viewport of `width` x `height` inches, anchored top-left.
#' @param min_height Optional `function(width)` giving the smallest height a
#'   flexible block can take. Defaults to 0.
#' @param natural_width Optional `function(width)` giving the width the
#'   content actually uses (for marks and icons that are narrower than their
#'   slot). Containers use it for horizontal alignment.
#' @param full_bleed When `TRUE` and the block is a direct child of a page,
#'   it spans the full page width, ignoring the side margins.
#' @param ... Extra fields stored on the block.
#' @return A block of class `c("bb_<type>", "bb_block")`.
#' @examples
#' bar <- new_block(
#'   "bar",
#'   measure = function(width) 0.1,
#'   render = function(width, height) grid::rectGrob(gp = grid::gpar(fill = "grey"))
#' )
#' measure_block(bar, 2)
#' @export
new_block <- function(type, measure, render, min_height = NULL, natural_width = NULL,
                      full_bleed = FALSE, ...) {
  if (!is.function(measure) || !is.function(render)) {
    stop("`measure` and `render` must be functions.", call. = FALSE)
  }
  cache <- new.env(parent = emptyenv())
  memo_measure <- function(width) {
    key <- paste(.theme_id(), format(round(width, 6), nsmall = 6))
    hit <- cache[[key]]
    if (!is.null(hit)) return(hit)
    h <- measure(width)
    if (length(h) != 1) stop("A block's measure() must return one number.", call. = FALSE)
    cache[[key]] <- h
    h
  }
  structure(
    c(list(measure = memo_measure, render = render, min_height = min_height,
           natural_width = natural_width, full_bleed = isTRUE(full_bleed)),
      list(...)),
    class = c(paste0("bb_", type), "bb_block")
  )
}

#' @export
print.bb_block <- function(x, ...) {
  cat("<", class(x)[1], ">", if (isTRUE(x$full_bleed)) " (full bleed)", "\n", sep = "")
  invisible(x)
}

#' Turn content into a block
#'
#' Every container calls `as_block()` on its children, so any of these can be
#' passed wherever a block is expected:
#'
#' | Input | Block |
#' |---|---|
#' | a block | unchanged |
#' | character, number, factor | [bb_text()] |
#' | path to a `.png` / `.jpg` file | [bb_image()] |
#' | numeric array, `raster`, `nativeRaster` | [bb_image()] |
#' | ggplot | [bb_plot()] (flexible height) |
#' | grob, gTree, gtable | [bb_grob()] (flexible height) |
#' | `NULL` | `NULL` (dropped by stacks, an empty slot in columns) |
#'
#' @param x Content.
#' @return A block, or `NULL`.
#' @examples
#' as_block("Some text")
#' @export
as_block <- function(x) {
  if (is.null(x)) return(NULL)
  if (inherits(x, "bb_block")) return(x)
  if (inherits(x, "bb_cell")) return(.cell_block(x, NULL, "left"))
  if (inherits(x, "ggplot")) return(bb_plot(x))
  if (inherits(x, "grob")) return(bb_grob(x))
  if (inherits(x, c("raster", "nativeRaster")) || (is.array(x) && is.numeric(x))) return(bb_image(x))
  if (is.character(x) && length(x) == 1 && !is.na(x) &&
      grepl("\\.(png|jpe?g)$", x, ignore.case = TRUE) && file.exists(x)) {
    return(bb_image(x))
  }
  if (is.character(x) || is.numeric(x) || is.factor(x) || is.logical(x)) {
    return(bb_text(as.character(x)))
  }
  stop("Can't turn an object of class <", paste(class(x), collapse = "/"),
       "> into a block.", call. = FALSE)
}

#' Internal: measure / min height / natural width / render
#' @noRd
.measure <- function(b, width) b$measure(max(width, 0))

#' @noRd
.min_height <- function(b, width) if (is.null(b$min_height)) 0 else b$min_height(max(width, 0))

#' @noRd
.natural_width <- function(b, width) {
  if (is.null(b$natural_width)) width else min(width, b$natural_width(width))
}

#' @noRd
.is_flex <- function(h) length(h) == 1 && is.na(h)

#' @noRd
.render <- function(b, width, height) {
  g <- b$render(max(width, 0), max(height, 0))
  if (is.null(g)) nullGrob() else g
}

#' Internal: place a grob in a viewport given top-left inches in the parent
#' @noRd
.place <- function(g, x, y, w, h, clip = "off") {
  vp <- viewport(x = unit(x, "in"), y = unit(1, "npc") - unit(y, "in"),
                 width = unit(max(w, 0), "in"), height = unit(max(h, 0), "in"),
                 just = c("left", "top"), clip = clip)
  kids <- gList(g)
  if (isTRUE(.bb_env$debug)) {
    kids <- gList(kids, rectGrob(gp = gpar(fill = NA, col = "#D9480F", lty = 2, lwd = 0.5)))
  }
  gTree(children = kids, vp = vp)
}

#' Internal: place a child block at (x, y) with size (w, h)
#' @noRd
.place_block <- function(b, x, y, w, h, clip = "off") .place(.render(b, w, h), x, y, w, h, clip)

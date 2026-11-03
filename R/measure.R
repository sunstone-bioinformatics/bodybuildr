# Measurement --------------------------------------------------------------------
# Text extents depend on the device's font metrics. Blocks are measured on a
# hidden PDF device of the same kind export_pdf() writes with, so sizes
# measured while building a page match the exported file. During export the
# export device itself is used.

.bb_env <- new.env(parent = emptyenv())
.bb_env$depth <- 0L

#' Internal: open the PDF device export_pdf() uses (cairo_pdf, else pdf)
#' @return `TRUE` when Cairo was used.
#' @noRd
.open_pdf_device <- function(file, width, height, quiet = FALSE) {
  use_cairo <- isTRUE(capabilities("cairo"))
  if (use_cairo) {
    cairo_failed <- FALSE
    withCallingHandlers(
      grDevices::cairo_pdf(file, width = width, height = height, onefile = TRUE),
      warning = function(w) {
        if (grepl("cairo", conditionMessage(w), ignore.case = TRUE)) {
          cairo_failed <<- TRUE
          invokeRestart("muffleWarning")
        }
      }
    )
    if (cairo_failed) {
      try(grDevices::dev.off(), silent = TRUE)
      use_cairo <- FALSE
      if (!quiet) {
        hint <- if (Sys.info()[["sysname"]] == "Darwin") {
          " On macOS, install XQuartz (https://www.xquartz.org) and restart R."
        } else if (.Platform$OS.type == "unix") {
          " On Linux, install the Cairo library (e.g. `sudo apt install libcairo2-dev`) and reinstall R."
        } else {
          " Cairo should be bundled with R on Windows; try reinstalling R."
        }
        message("Cairo PDF device unavailable; falling back to pdf() -- non-ASCII characters ",
                "(e.g. bullet points) may not render correctly.", hint)
      }
    }
  }
  if (!use_cairo) {
    grDevices::pdf(file, width = width, height = height, useDingbats = FALSE, onefile = TRUE)
  }
  use_cairo
}

#' Evaluate code on bodybuildr's measuring device
#'
#' Text and grob sizes depend on the active graphics device. bodybuildr
#' measures on a hidden PDF device of the same kind [export_pdf()] writes with,
#' so measurements match the exported file and no `Rplots.pdf` is created. The
#' caller's active device is restored afterwards. During [export_pdf()] the
#' export device itself is used.
#'
#' @param expr Code that converts units or measures grobs.
#' @return The value of `expr`.
#' @examples
#' with_measure_device(
#'   grid::convertWidth(grid::stringWidth("Hello"), "in", valueOnly = TRUE)
#' )
#' @export
with_measure_device <- function(expr) {
  if (isTRUE(.bb_env$exporting)) return(force(expr))
  prev <- grDevices::dev.cur()
  outer <- .bb_env$depth == 0L
  dev <- .bb_env$dev
  if (is.null(dev) || !(dev %in% grDevices::dev.list())) {
    .open_pdf_device(tempfile("bodybuildr-measure-", fileext = ".pdf"), 8.5, 11, quiet = TRUE)
    .bb_env$dev <- grDevices::dev.cur()
  } else if (prev != dev) {
    grDevices::dev.set(dev)
  }
  .bb_env$depth <- .bb_env$depth + 1L
  on.exit({
    .bb_env$depth <- .bb_env$depth - 1L
    if (outer) {
      if (prev == 1L) {
        # Nothing was open before: close the measuring device so later
        # plotting doesn't land on a hidden file.
        if (.bb_env$dev %in% grDevices::dev.list()) grDevices::dev.off(.bb_env$dev)
        .bb_env$dev <- NULL
      } else if (prev %in% grDevices::dev.list()) {
        grDevices::dev.set(prev)
      }
    }
  }, add = TRUE)
  force(expr)
}

#' Measure a block
#'
#' Returns the height a block takes at a given width, measured on the same
#' kind of device [export_pdf()] uses.
#'
#' @param x A block (or anything [as_block()] accepts).
#' @param width Available width (`grid::unit` or inches).
#' @return A `grid::unit` in inches. Flexible blocks (for example a plot
#'   without a fixed height) return `NA`.
#' @examples
#' measure_block(bb_text("A short paragraph."), width = 3)
#' @export
measure_block <- function(x, width) {
  b <- as_block(x)
  if (is.null(b)) return(unit(0, "in"))
  w <- .in(width, "width")
  unit(with_measure_device(.measure(b, w)), "in")
}

#' Width of a string in a text style
#'
#' @param text Character string (single line).
#' @param style A [text_style()], a theme text role name, or `NULL` for body
#'   text.
#' @return A `grid::unit` in inches.
#' @examples
#' text_width("Coverage", text_style(size = 12, weight = 700))
#' @export
text_width <- function(text, style = NULL) {
  gp <- .as_gpar(.resolve_text_style(style, "body"))
  unit(.text_w_in(as.character(text), gp), "in")
}

#' Graphical parameters for a text style
#'
#' Resolves a text style against the active theme (role defaults, font
#' weight lookup, theme colours) and returns a `grid::gpar()`. Use it to draw
#' text in theme styles inside a custom [new_block()].
#'
#' @param style A [text_style()], a theme role name, or `NULL`.
#' @param role Role used for fields the style leaves unset.
#' @return A `grid::gpar` object.
#' @examples
#' text_gpar(text_style(weight = 600, color = "muted"))
#' @export
text_gpar <- function(style = NULL, role = "body") .as_gpar(.resolve_text_style(style, role))

#' @noRd
.text_w_in <- function(label, gp) {
  with_measure_device(vapply(label, function(l) {
    convertWidth(grobWidth(textGrob(l, gp = gp)), "in", valueOnly = TRUE)
  }, numeric(1), USE.NAMES = FALSE))
}

#' @noRd
.grob_h_in <- function(g) with_measure_device(convertHeight(grobHeight(g), "in", valueOnly = TRUE))

#' @noRd
.grob_w_in <- function(g) with_measure_device(convertWidth(grobWidth(g), "in", valueOnly = TRUE))

#' Internal: height of one line of text in inches (font size x line height)
#' @noRd
.line_h_in <- function(rs) rs$size * rs$lineheight / 72

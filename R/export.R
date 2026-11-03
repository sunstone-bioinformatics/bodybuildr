# Export ---------------------------------------------------------------------------------

#' @noRd
.as_pages <- function(x) {
  if (inherits(x, "bb_document")) return(x$pages)
  if (inherits(x, "bb_page")) return(list(x))
  if (inherits(x, "bb_block")) return(list(bb_page(x)))
  if (is.list(x) && !inherits(x, "grob")) return(bb_document(.list = x)$pages)
  stop("`x` must be a bb_page(), bb_document(), list of pages, or a block.", call. = FALSE)
}

#' Export pages to PDF
#'
#' Writes one page, a [bb_document()], or a list of pages to a single PDF
#' file. Each page is drawn from its top-left corner; headers and footers get
#' their `\{page\}` / `\{pages\}` numbers here.
#'
#' `export_pdf()` uses `cairo_pdf()` when Cairo is available, for full UTF-8
#' support and installed font weights. Otherwise it falls back to `pdf()` with
#' a message.
#'
#' **Cairo availability by platform:**
#' - **Windows:** bundled with R.
#' - **Linux:** usually present; install `libcairo2-dev` if missing.
#' - **macOS:** requires XQuartz (<https://www.xquartz.org>). After installing,
#'   restart R and check `capabilities("cairo")`.
#'
#' All pages must share one page size.
#'
#' @param x A [bb_page()], a [bb_document()], a list of pages (`NULL`s are
#'   dropped), or a single block (exported on a default page).
#' @param file Output path.
#' @param debug Outline every block's box, for layout work.
#' @return The output path, invisibly.
#' @examples
#' f <- tempfile(fileext = ".pdf")
#' export_pdf(bb_page(bb_section_header("Hello"), "World"), f)
#' @export
export_pdf <- function(x, file = "bodybuildr.pdf", debug = FALSE) {
  pages <- .as_pages(x)
  if (!length(pages)) stop("Nothing to export: no pages.", call. = FALSE)
  sizes <- vapply(pages, function(p) paste(p$template$width, p$template$height), character(1))
  if (length(unique(sizes)) > 1) stop("All pages must share one page size.", call. = FALSE)
  W <- pages[[1]]$template$width; H <- pages[[1]]$template$height

  dir <- dirname(file)
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  prev <- grDevices::dev.cur()
  .open_pdf_device(file, W, H)
  dev <- grDevices::dev.cur()
  old <- list(exporting = .bb_env$exporting, debug = .bb_env$debug)
  .bb_env$exporting <- TRUE
  .bb_env$debug <- isTRUE(debug)
  on.exit({
    .bb_env$exporting <- old$exporting
    .bb_env$debug <- old$debug
    if (dev %in% grDevices::dev.list()) grDevices::dev.off(dev)
    if (prev != 1L && prev %in% grDevices::dev.list()) grDevices::dev.set(prev)
  }, add = TRUE)

  n <- length(pages)
  for (i in seq_len(n)) {
    p <- pages[[i]]
    grid.newpage()
    with_theme(p$template$theme, {
      g <- .page_grob(p, list(page = i, pages = n, data = p$data))
      grid.draw(g)
    })
  }
  invisible(file)
}

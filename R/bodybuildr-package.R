#' bodybuildr: infographic pages built from blocks
#'
#' bodybuildr lays out PDF pages as trees of *blocks*. A block knows how tall
#' it is at a given width and how to draw itself from the top-left corner of
#' the space it is given. Blocks compose vertically with [bb_stack()] and
#' horizontally with [bb_cols()], and a [bb_page()] places them between a
#' header and a footer pinned to the bottom margin. [export_pdf()] writes one
#' or many pages to a single PDF.
#'
#' Spacing comes in three separate bands, never mixed:
#' 1. **Page margins** from [page_template()]. Blocks marked `full_bleed`
#'    escape the side margins.
#' 2. **Layout gaps**: the `gap` of [bb_stack()] and [bb_cols()].
#' 3. **Box spacing**: padding and margin of [bb_box()] / [box_style()].
#'
#' Geometry accepts `grid::unit` objects or plain numbers, which are read as
#' inches. Colours accept any R colour or the name of a theme colour
#' (see [bb_theme()]).
#'
#' @keywords internal
#' @import grid
"_PACKAGE"

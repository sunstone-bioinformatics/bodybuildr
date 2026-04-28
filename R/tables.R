# Table grobs -----------------------------------------------------------------

#' Construct a native grid table for use in layout rows
#'
#' Converts a `data.frame` to a `gridExtra::tableGrob` with column widths set
#' to `null` units so the table fills whatever space the row cell provides.
#' Returns a grob that can be passed directly to layout functions.
#'
#' Requires the `gridExtra` package.
#'
#' @param df A `data.frame` to render.
#' @param rows Whether to show row names. Default `NULL` (hidden).
#' @param fill_height Whether to stretch row heights to fill available space. Default `FALSE`.
#' @param header_fill Background color for header row. Default `"#1E3A8A"`.
#' @param header_col Text color for header row. Default `"white"`.
#' @param cell_fill Background color for data cells. Default `"white"`.
#' @param alt_fill Alternating row fill color. Default `"#F1F5F9"`. Set `NA` to disable.
#' @param border_col Border color. Default `"#CBD5E1"`.
#' @param fontsize Font size in pt. Default `9`.
#' @param fontfamily Font family. Default `"sans"`.
#' @param padding Cell padding as `grid::unit`. Default `unit(4, "pt")`.
#' @return A `gtable` grob to use as an item in layout rows.
#' @export
#' @importFrom grid unit unit.c gpar
table_box <- function(
    df,
    rows        = NULL,
    fill_height = FALSE,
    header_fill = "#1E3A8A",
    header_col  = "white",
    cell_fill   = "white",
    alt_fill    = "#F1F5F9",
    border_col  = "#CBD5E1",
    fontsize    = 9,
    fontfamily  = "sans",
    padding     = unit(4, "pt")
) {
  if (!requireNamespace("gridExtra", quietly = TRUE)) {
    stop("Package 'gridExtra' needed for table_box(). Install with install.packages('gridExtra').", call. = FALSE)
  }
  if (!is.data.frame(df)) stop("`df` must be a data.frame.", call. = FALSE)

  pad <- if (inherits(padding, "unit")) padding else unit(padding, "pt")

  n_rows <- nrow(df)

  core_fills <- if (!is.na(alt_fill)) {
    rep_len(c(cell_fill, alt_fill), n_rows)
  } else {
    rep(cell_fill, n_rows)
  }

  theme <- gridExtra::ttheme_minimal(
    core = list(
      bg_params = list(fill = core_fills, col = border_col, lwd = 0.5),
      fg_params = list(col = "#1E293B", fontsize = fontsize, fontfamily = fontfamily),
      padding   = unit.c(pad, pad)
    ),
    colhead = list(
      bg_params = list(fill = header_fill, col = border_col, lwd = 0.5),
      fg_params = list(col = header_col, fontsize = fontsize, fontface = "bold", fontfamily = fontfamily),
      padding   = unit.c(pad, pad)
    ),
    rowhead = list(
      bg_params = list(fill = cell_fill, col = border_col, lwd = 0.5),
      fg_params = list(col = "#1E293B", fontsize = fontsize, fontface = "italic", fontfamily = fontfamily),
      padding   = unit.c(pad, pad)
    )
  )

  tg <- gridExtra::tableGrob(df, rows = rows, theme = theme)

  tg$widths <- unit(rep(1, length(tg$widths)), "null")

  if (fill_height) {
    tg$heights <- unit(rep(1, length(tg$heights)), "null")
  }

  tg
}

# Rich table grob -------------------------------------------------------------

#' Construct a mixed-content table grob
#'
#' Like [table_box()] but each cell can contain text, an image path, a ggplot,
#' a grob, or `NULL`. Returns a `gtable` that drops into any layout row function.
#'
#' @param headers Character vector of column header labels.
#' @param rows List of row-lists. Each row must be a list of length
#'   `length(headers)`. Items per cell: character, image path (`png`/`jpg`),
#'   `ggplot`, grob/gtable/gTree, or `NULL` (empty cell).
#' @param col_widths Numeric proportional column widths (e.g. `c(2, 1, 1)`).
#'   `NULL` = equal-width columns.
#' @param row_height Height of each data row as `grid::unit`. Default `unit(0.4, "in")`.
#' @param header_height Height of header row as `grid::unit`. Default `unit(0.35, "in")`.
#' @param header_fill Header background color. Default `"#1E3A8A"`.
#' @param header_col Header text color. Default `"white"`.
#' @param cell_fill Base data cell background. Default `"white"`.
#' @param alt_fill Alternating row fill color. Default `"#F1F5F9"`. Set `NA` to disable.
#' @param border_col Cell border color. Default `"#CBD5E1"`.
#' @param fontsize Font size in pt for text cells. Default `9`.
#' @param fontfamily Font family for text cells. Default `"sans"`.
#' @param padding Inner cell padding as `grid::unit`. Default `unit(4, "pt")`.
#' @param image_scale `"fit"` (preserve aspect ratio) or `"fill"` for image cells.
#' @return A `gtable` grob to use as an item in layout rows.
#' @export
#' @importFrom grid unit unit.c gpar grobTree gTree gList rectGrob textGrob
#'   viewport nullGrob
#' @importFrom gtable gtable gtable_add_grob
rich_table_box <- function(
    headers,
    rows,
    col_widths    = NULL,
    row_height    = unit(0.4, "in"),
    header_height = unit(0.35, "in"),
    header_fill   = "#1E3A8A",
    header_col    = "white",
    cell_fill     = "white",
    alt_fill      = "#F1F5F9",
    border_col    = "#CBD5E1",
    fontsize      = 9,
    fontfamily    = "sans",
    padding       = unit(4, "pt"),
    image_scale   = c("fit", "fill")
) {
  image_scale <- match.arg(image_scale)

  if (!is.character(headers) || length(headers) == 0) {
    stop("`headers` must be a non-empty character vector.", call. = FALSE)
  }
  if (!is.list(rows)) stop("`rows` must be a list of lists.", call. = FALSE)

  nc <- length(headers)
  nr <- length(rows)

  for (i in seq_along(rows)) {
    if (!is.list(rows[[i]])) stop(sprintf("Row %d must be a list.", i), call. = FALSE)
    if (length(rows[[i]]) != nc) {
      stop(sprintf("Row %d has %d items; expected %d (length of `headers`).", i, length(rows[[i]]), nc), call. = FALSE)
    }
  }

  pad <- if (inherits(padding, "unit")) padding else unit(padding, "pt")
  row_height    <- .as_unit_nonneg(row_height, "row_height")
  header_height <- .as_unit_nonneg(header_height, "header_height")

  # column widths: equal null or proportional null
  widths <- if (is.null(col_widths)) {
    unit(rep(1, nc), "null")
  } else {
    if (length(col_widths) != nc) {
      stop("`col_widths` must have same length as `headers`.", call. = FALSE)
    }
    if (any(col_widths <= 0)) stop("All `col_widths` must be positive.", call. = FALSE)
    unit(col_widths, "null")
  }

  # row heights: header + data rows
  row_h_list <- vector("list", nr)
  for (i in seq_len(nr)) row_h_list[[i]] <- row_height
  heights <- do.call(unit.c, c(list(header_height), row_h_list))

  gt <- gtable(widths = widths, heights = heights)

  # build one cell grob
  .rich_cell <- function(item, bg_fill, text_gp) {
    bg <- rectGrob(gp = gpar(fill = bg_fill, col = border_col, lwd = 0.5))

    inner_vp <- viewport(
      x = pad, y = unit(0.5, "npc"),
      just   = c("left", "center"),
      width  = unit(1, "npc") - 2 * pad,
      height = unit(1, "npc") - 2 * pad,
      clip   = "on"
    )

    if (is.null(item)) return(grobTree(bg))

    # ggplot
    if (inherits(item, "ggplot")) {
      if (!requireNamespace("ggplot2", quietly = TRUE)) {
        stop("ggplot2 required for ggplot cells.", call. = FALSE)
      }
      return(grobTree(bg, gTree(children = gList(ggplot2::ggplotGrob(item)), vp = inner_vp)))
    }

    # grob / gTree / gtable
    if (inherits(item, c("grob", "gTree", "gtable"))) {
      return(grobTree(bg, gTree(children = gList(item), vp = inner_vp)))
    }

    # image file
    if (is.character(item) && length(item) == 1 && file.exists(item)) {
      ext <- tolower(tools::file_ext(item))
      img <- if (ext == "png") {
        png::readPNG(item)
      } else if (ext %in% c("jpg", "jpeg")) {
        jpeg::readJPEG(item)
      } else NULL
      if (!is.null(img)) {
        img_g <- .bbdr_raster_grob(img, scale = image_scale)
        return(grobTree(bg, gTree(children = gList(img_g), vp = inner_vp)))
      }
    }

    # character (or coerce to string)
    lbl <- if (is.character(item)) item else paste0(item)
    txt <- textGrob(
      lbl,
      x = unit(0, "npc"), y = unit(0.5, "npc"),
      just = c("left", "center"),
      gp   = text_gp,
      vp   = inner_vp
    )
    grobTree(bg, txt)
  }

  # header row
  hdr_gp <- gpar(col = header_col, fontsize = fontsize, fontface = "bold", fontfamily = fontfamily)
  for (j in seq_len(nc)) {
    cell <- .rich_cell(headers[j], bg_fill = header_fill, text_gp = hdr_gp)
    gt   <- gtable_add_grob(gt, cell, t = 1, l = j, z = 1, clip = "on")
  }

  # data rows
  for (i in seq_len(nr)) {
    row_fill <- if (!is.na(alt_fill) && i %% 2 == 0) alt_fill else cell_fill
    cell_gp  <- gpar(col = "#1E293B", fontsize = fontsize, fontface = "plain", fontfamily = fontfamily)
    for (j in seq_len(nc)) {
      cell <- .rich_cell(rows[[i]][[j]], bg_fill = row_fill, text_gp = cell_gp)
      gt   <- gtable_add_grob(gt, cell, t = i + 1, l = j, z = 1, clip = "on")
    }
  }

  gt
}

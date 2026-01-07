# Layout row builders ------------------------------------------------------
# Scaffolding only; implementations will be filled in.

#' Multi-column row layout (1..n columns)
#'
#' Accepts ggplot objects, grobs, image paths, or character vectors and renders them
#' into equal-width columns with configurable padding, gaps, and lanes.
#'
#' **Inputs**
#' - `items`: list of ggplot/grob/image path/character/NULL. Use [text_box()] to give a specific column its own text/box/background settings; otherwise the defaults below apply.
#' - `row_height`: nominal height (`grid::unit`); actual height is set when adding to a canvas.
#'
#' **Layout + styling**
#' - `column_style`: list from [columnLayoutStyle()] (padding, gaps, margins, backgrounds).
#' - `text_style`: default text style (`textStyle()`), used for character items.
#' - `box_style`: default box style (`boxStyle()`), used for character/fallback items.
#' - `image_scale`: `"fit"` (preserve aspect) or `"fill"`.
#' - `full_bleed_left` / `full_bleed_right`: allow first/last column to extend into outer lanes.
#' - `debug_boxes`: overlay guides.
#'
#' @param row_height Optional nominal height (`grid::unit`); actual height is set when adding to a canvas.
#' @param column_style A list from [columnLayoutStyle()] controlling padding/gaps/margins/backgrounds (non-negative units).
#' @param text_style Default text style (`textStyle()`), used for character items.
#' @param box_style Default box style (`boxStyle()`), used for character/fallback items.
#' @param image_scale How to place images: `"fit"` (preserve aspect) or `"fill"`.
#' @param full_bleed_left,full_bleed_right Allow first/last column to extend into outer lanes.
#' @param debug_boxes Draw debug outlines.
#' @return A `gtable` representing the row.
#' @export
#' @importFrom grid unit rectGrob gpar viewport rasterGrob gTree gList nullGrob textGrob grobHeight unit.c
#' @importFrom gtable gtable gtable_add_grob
#' @importFrom tools file_ext
#' @importFrom png readPNG
#' @importFrom jpeg readJPEG
str_n_panel_row <- function(
    items,
    row_height        = grid::unit(2.0, "in"),
    column_style      = columnLayoutStyle(),
    text_style        = textStyle(),
    box_style         = boxStyle(
      radius      = grid::unit(8, "pt"),
      border_color= "#D1D5DB",
      border_lwd  = 1,
      fill        = NA,
      margin      = grid::unit(c(6, 6, 6, 6), "pt"),
      padding     = grid::unit(c(6, 8, 6, 8), "pt")
    ),
    image_scale       = c("fit", "fill"),
    full_bleed_left   = FALSE,
    full_bleed_right  = FALSE,
    debug_boxes       = FALSE
) {
  image_scale <- match.arg(image_scale)
  if (!is.list(items)) items <- as.list(items)
  n <- length(items); if (n < 1) stop("`items` must have length >= 1")

  # merge column style overrides
  if (is.list(column_style)) {
    defaults <- columnLayoutStyle()
    defaults[names(column_style)] <- column_style
    column_style <- defaults
  } else {
    column_style <- columnLayoutStyle()
  }

  # normalize lengths
  column_bg <- column_style$column_bg
  if (length(column_bg) == 1) column_bg <- rep(column_bg, n) else column_bg <- rep_len(column_bg, n)
  column_gap_bg <- column_style$column_gap_bg
  if (is.null(column_gap_bg)) column_gap_bg <- NA
  if (n > 1) {
    if (length(column_gap_bg) == 1) column_gap_bg <- rep(column_gap_bg, n - 1)
    else column_gap_bg <- rep_len(column_gap_bg, n - 1)
  } else {
    column_gap_bg <- logical(0)
  }

  # validate units non-negative
  column_pad_x   <- .as_unit_nonneg(column_style$column_pad_x, "column_pad_x")
  column_pad_y   <- .as_unit_nonneg(column_style$column_pad_y, "column_pad_y")
  column_gap     <- .as_unit_nonneg(column_style$column_gap, "column_gap")
  outer_margin   <- .as_unit_nonneg(column_style$outer_margin, "outer_margin")
  bottom_margin  <- .as_unit_nonneg(column_style$bottom_margin, "bottom_margin")
  row_height     <- .as_unit_nonneg(row_height, "row_height")

  # helper to merge per-column overrides
  merge_styles <- function(idx, item) {
    override <- if (inherits(item, "bbdr_text_box")) item else NULL
    list(
      bg         = if (!is.null(override$bg)) override$bg else column_bg[idx],
      pad_x      = if (!is.null(override$pad_x)) override$pad_x else column_pad_x,
      pad_y      = if (!is.null(override$pad_y)) override$pad_y else column_pad_y,
      text_style = if (!is.null(override$text_style) && inherits(override$text_style, "gpar")) override$text_style else text_style,
      box_style  = if (!is.null(override$box_style) && is.list(override$box_style)) override$box_style else box_style,
      label      = if (!is.null(override$label)) override$label else NULL
    )
  }

  # cell builder
  .cell_from_item <- function(obj, style, dbg = FALSE) {
    bg <- grid::rectGrob(gp = grid::gpar(fill = style$bg, col = style$bg))
    inner_vp <- grid::viewport(
      x = style$pad_x, y = grid::unit(0.5, "npc"),
      just = c("left","center"),
      width  = grid::unit(1, "npc") - 2*style$pad_x,
      height = grid::unit(1, "npc") - 2*style$pad_y,
      clip   = "on"
    )
    blue_box <- if (isTRUE(dbg)) {
      grid::rectGrob(vp = inner_vp, gp = grid::gpar(fill = NA, col = "#1E3A8A", lty = 2, lwd = 1))
    } else grid::nullGrob()

    # ggplot
    if (inherits(obj, "ggplot")) {
      if (!requireNamespace("ggplot2", quietly = TRUE)) stop("A ggplot object was supplied, but 'ggplot2' is not available.")
      content <- ggplot2::ggplotGrob(obj)
      plot_vp <- grid::viewport(
        x = 0, y = 0.5, just = c("left","center"),
        width = grid::unit(1, "npc"), height = grid::unit(1, "npc"), clip = "on"
      )
      return(grid::grobTree(bg, blue_box, grid::gTree(children = grid::gList(content), vp = grid::vpStack(inner_vp, plot_vp))))
    }
    # grob/gTree/gtable
    if (inherits(obj, c("grob", "gTree", "gtable"))) {
      return(grid::grobTree(bg, blue_box, grid::gTree(children = grid::gList(obj), vp = inner_vp)))
    }
    # image file
    is_file <- is.character(obj) && length(obj) == 1 && file.exists(obj)
    if (is_file) {
      ext <- tolower(tools::file_ext(obj))
      img <- if (ext == "png") png::readPNG(obj) else if (ext %in% c("jpg","jpeg")) jpeg::readJPEG(obj) else NULL
      if (is.null(img)) {
        box <- wrap_text_top_left(
          paste0("Unsupported image: ", basename(obj)), inner_vp,
          gp = style$text_style,
          box_r = style$box_style$radius,
          box_border_col = style$box_style$border_color,
          box_border_lwd = style$box_style$border_lwd,
          box_fill = style$box_style$fill,
          box_margin = style$box_style$margin,
          text_pad = style$box_style$padding
        )
        return(grid::grobTree(bg, blue_box, box))
      }
      if (image_scale == "fit") {
        hpx <- dim(img)[1]; wpx <- dim(img)[2]; aspect <- wpx / hpx
        if (aspect >= 1) { w_unit <- grid::unit(1, "npc"); h_unit <- grid::unit(1/aspect, "npc")
        } else            { w_unit <- grid::unit(aspect, "npc"); h_unit <- grid::unit(1, "npc") }
        img_g <- grid::rasterGrob(img, x = 0.5, y = 0.5, just = c("center","center"),
                            width = w_unit, height = h_unit, interpolate = TRUE)
      } else {
        img_g <- grid::rasterGrob(img, x = 0.5, y = 0.5, just = c("center","center"),
                            width = grid::unit(1, "npc"), height = grid::unit(1, "npc"),
                            interpolate = TRUE)
      }
      return(grid::grobTree(bg, blue_box, grid::gTree(children = grid::gList(img_g), vp = inner_vp)))
    }
    # text_box wrapper
    if (inherits(obj, "bbdr_text_box")) {
      lbl <- obj$label
      style$text_style <- obj$text_style
      style$box_style  <- obj$box_style
      if (!is.null(obj$bg))    style$bg <- obj$bg
      if (!is.null(obj$pad_x)) style$pad_x <- obj$pad_x
      if (!is.null(obj$pad_y)) style$pad_y <- obj$pad_y
      box <- wrap_text_top_left(
        lbl, inner_vp, gp = style$text_style,
        box_r = style$box_style$radius,
        box_border_col = style$box_style$border_color,
        box_border_lwd = style$box_style$border_lwd,
        box_fill = style$box_style$fill,
        box_margin = style$box_style$margin,
        text_pad = style$box_style$padding
      )
      return(grid::grobTree(bg, blue_box, box))
    }
    # character -> rounded TEXT BOX
    if (is.character(obj)) {
      box <- wrap_text_top_left(
        obj, inner_vp, gp = style$text_style,
        box_r = style$box_style$radius,
        box_border_col = style$box_style$border_color,
        box_border_lwd = style$box_style$border_lwd,
        box_fill = style$box_style$fill,
        box_margin = style$box_style$margin,
        text_pad = style$box_style$padding
      )
      return(grid::grobTree(bg, blue_box, box))
    }
    # NULL
    if (is.null(obj)) return(grid::grobTree(bg, blue_box))
    # fallback: stringify
    box <- wrap_text_top_left(
      paste0(obj), inner_vp, gp = style$text_style,
      box_r = style$box_style$radius,
      box_border_col = style$box_style$border_color,
      box_border_lwd = style$box_style$border_lwd,
      box_fill = style$box_style$fill,
      box_margin = style$box_style$margin,
      text_pad = style$box_style$padding
    )
    grid::grobTree(bg, blue_box, box)
  }

  # widths pattern: [L_MARGIN, col1, gap, col2, ..., colN, R_MARGIN]
  w_parts <- list(outer_margin)
  for (i in seq_len(n)) {
    w_parts <- append(w_parts, list(grid::unit(1, "null")))
    if (i < n) w_parts <- append(w_parts, list(column_gap))
  }
  w_parts <- append(w_parts, list(outer_margin))
  widths <- do.call(grid::unit.c, w_parts)

  # heights: [CONTENT, BOTTOM_MARGIN]
  gt <- gtable::gtable(widths = widths, heights = grid::unit.c(grid::unit(1, "null"), bottom_margin))

  # outer lanes background
  if (!is.null(column_style$outer_margin_bg) && !is.na(column_style$outer_margin_bg)) {
    gt <- gtable::gtable_add_grob(gt, grid::rectGrob(gp = grid::gpar(fill = column_style$outer_margin_bg, col = column_style$outer_margin_bg)),
                          t = 1, l = 1, b = 2, r = 1, z = 0, clip = "on")
    gt <- gtable::gtable_add_grob(gt, grid::rectGrob(gp = grid::gpar(fill = column_style$outer_margin_bg, col = column_style$outer_margin_bg)),
                          t = 1, l = (2*n + 1), b = 2, r = (2*n + 1), z = 0, clip = "on")
  }
  # gap backgrounds (content row only)
  if (n > 1) for (i in seq_len(n - 1)) {
    gap_col <- 2*i + 1
    gap_fill <- column_gap_bg[i]
    if (!is.null(gap_fill) && !is.na(gap_fill)) {
      gt <- gtable::gtable_add_grob(gt, grid::rectGrob(gp = grid::gpar(fill = gap_fill, col = gap_fill)),
                            t = 1, l = gap_col, b = 1, r = gap_col, z = 0, clip = "on")
    }
  }
  # bottom margin bg across interior only
  if (!is.null(column_style$bottom_margin_bg) && !is.na(column_style$bottom_margin_bg) && (2*n) >= 2) {
    gt <- gtable::gtable_add_grob(gt, grid::rectGrob(gp = grid::gpar(fill = column_style$bottom_margin_bg, col = column_style$bottom_margin_bg)),
                          t = 2, l = 2, b = 2, r = (2*n), z = 0, clip = "on")
  }

  # content cells (optionally span into outer lanes)
  for (i in seq_len(n)) {
    l_idx <- 2*i
    r_idx <- 2*i
    if (i == 1 && isTRUE(full_bleed_left))  l_idx <- 1
    if (i == n && isTRUE(full_bleed_right)) r_idx <- 2*n + 1
    st <- merge_styles(i, items[[i]])
    cell <- .cell_from_item(items[[i]], st, dbg = debug_boxes)
    gt <- gtable::gtable_add_grob(gt, cell, t = 1, l = l_idx, r = r_idx, z = 1, clip = "on")
  }

  # RED debug box: outlines the interior band (content across all columns)
  if (isTRUE(debug_boxes)) {
    gt <- gtable::gtable_add_grob(
      gt,
      grid::rectGrob(gp = grid::gpar(fill = NA, col = "#B91C1C", lty = 2, lwd = 1)),
      t = 1, l = 2, b = 1, r = 2*n, z = 99, clip = "off"
    )
  }
  gt
}

#' Three-panel row layout (A | B over C)
#'
#' Places a tall left panel next to two stacked right panels, with padding and lane options.
#' Use [text_box()] for per-panel text styling; other items can be ggplot/grob/image paths.
#'
#' @param A_item,B_item,C_item Items to render (ggplot/grob/image path/character/NULL or `text_box()`).
#' @param layout_style A list from [threePanelLayoutStyle()] controlling geometry, padding, and backgrounds.
#' @param text_style Default text style (`textStyle()`), used for character items.
#' @param box_style Default box style (`boxStyle()`), used for character/fallback items.
#' @param image_scale How to place images: `"fit"` (preserve aspect) or `"fill"`.
#' @param reverse Logical; if `TRUE`, A is on the right and B/C are on the left.
#' @param debug_boxes Draw debug outlines.
#' Note: Lanes (outer/bottom margins) come from `layout_style`. The immediate gap around text boxes is controlled by `box_style$margin` or `text_box()`; set it to zero for a single-layer look.
#' @return A `gtable` representing the row.
#' @export
#' @importFrom grid unit rectGrob gpar viewport rasterGrob gTree gList nullGrob textGrob grobHeight unit.c
#' @importFrom gtable gtable gtable_add_grob
#' @importFrom tools file_ext
#' @importFrom png readPNG
#' @importFrom jpeg readJPEG
str_three_panel_row <- function(
    A_item = NULL,
    B_item = NULL,
    C_item = NULL,
    layout_style = threePanelLayoutStyle(),
    text_style = textStyle(),
    box_style = boxStyle(
      radius      = grid::unit(8, "pt"),
      border_color= "#D1D5DB",
      border_lwd  = 1,
      fill        = NA,
      margin      = grid::unit(c(6, 6, 6, 6), "pt"),
      padding     = grid::unit(c(10, 10, 10, 10), "pt")
    ),
    image_scale = c("fit", "fill"),
    reverse = FALSE,
    debug_boxes = FALSE
) {
  image_scale <- match.arg(image_scale)
  if (!is.logical(reverse) || length(reverse) != 1 || is.na(reverse)) {
    stop("`reverse` must be a single TRUE/FALSE value.", call. = FALSE)
  }

  # merge layout style overrides
  if (is.list(layout_style)) {
    defaults <- threePanelLayoutStyle()
    defaults[names(layout_style)] <- layout_style
    layout_style <- defaults
  } else {
    layout_style <- threePanelLayoutStyle()
  }
  layout_style <- do.call(threePanelLayoutStyle, layout_style)

  A_width      <- layout_style$A_width
  right_split  <- layout_style$right_split
  hgap         <- layout_style$hgap
  vgap         <- layout_style$vgap
  outer_margin <- layout_style$outer_margin
  bottom_margin<- layout_style$bottom_margin

  # panel style builder
  panel_style <- function(panel, item) {
    bg <- layout_style[[paste0(panel, "_bg")]]
    pad_x <- layout_style[[paste0(panel, "_pad_x")]]
    pad_y <- layout_style[[paste0(panel, "_pad_y")]]
    if (inherits(item, "bbdr_text_box")) {
      if (!is.null(item$bg)) bg <- item$bg
      if (!is.null(item$pad_x)) pad_x <- item$pad_x
      if (!is.null(item$pad_y)) pad_y <- item$pad_y
    }
    list(
      bg = bg,
      pad_x = pad_x,
      pad_y = pad_y,
      text_style = if (inherits(item, "bbdr_text_box")) item$text_style else text_style,
      box_style  = if (inherits(item, "bbdr_text_box")) item$box_style else box_style,
      label = if (inherits(item, "bbdr_text_box")) item$label else NULL
    )
  }

  .panel_from_item <- function(obj, style, dbg = FALSE) {
    bg <- grid::rectGrob(gp = grid::gpar(fill = style$bg, col = style$bg))
    inner_vp <- grid::viewport(
      x = 0.5, y = 0.5, just = c("center","center"),
      width  = grid::unit(1, "npc") - 2*style$pad_x,
      height = grid::unit(1, "npc") - 2*style$pad_y,
      clip   = "on"
    )
    blue_box <- if (isTRUE(dbg)) {
      grid::rectGrob(vp = inner_vp, gp = grid::gpar(fill = NA, col = "#1E3A8A", lty = 2, lwd = 1))
    } else grid::nullGrob()

    if (inherits(obj, "ggplot")) {
      if (!requireNamespace("ggplot2", quietly = TRUE)) stop("A ggplot object was supplied, but 'ggplot2' is not available.")
      gtbl <- ggplot2::ggplotGrob(obj)
      return(grid::grobTree(bg, blue_box, grid::gTree(children = grid::gList(gtbl), vp = inner_vp)))
    }
    if (inherits(obj, c("grob", "gTree", "gtable"))) {
      return(grid::grobTree(bg, blue_box, grid::gTree(children = grid::gList(obj), vp = inner_vp)))
    }
    is_file <- is.character(obj) && length(obj) == 1 && file.exists(obj)
    if (is_file) {
      ext <- tolower(tools::file_ext(obj))
      img <- if (ext == "png") png::readPNG(obj) else if (ext %in% c("jpg","jpeg")) jpeg::readJPEG(obj) else NULL
      if (is.null(img)) {
        txt <- wrap_text_top_left(
          paste0("Unsupported image: ", basename(obj)), inner_vp, gp = style$text_style,
          box_r = style$box_style$radius, box_border_col = style$box_style$border_color,
          box_border_lwd = style$box_style$border_lwd, box_fill = style$box_style$fill,
          box_margin = style$box_style$margin, text_pad = style$box_style$padding
        )
        return(grid::grobTree(bg, blue_box, txt))
      }
      if (image_scale == "fit") {
        hpx <- dim(img)[1]; wpx <- dim(img)[2]; aspect <- wpx / hpx
        if (aspect >= 1) { w_unit <- grid::unit(1, "npc"); h_unit <- grid::unit(1/aspect, "npc")
        } else            { w_unit <- grid::unit(aspect, "npc"); h_unit <- grid::unit(1, "npc") }
        img_g <- grid::rasterGrob(img, x = 0.5, y = 0.5, just = c("center","center"),
                            width = w_unit, height = h_unit, interpolate = TRUE)
      } else {
        img_g <- grid::rasterGrob(img, x = 0.5, y = 0.5, just = c("center","center"),
                            width = grid::unit(1, "npc"), height = grid::unit(1, "npc"),
                            interpolate = TRUE)
      }
      return(grid::grobTree(bg, blue_box, grid::gTree(children = grid::gList(img_g), vp = inner_vp)))
    }
    if (inherits(obj, "bbdr_text_box")) {
      txt <- wrap_text_top_left(
        obj$label, inner_vp, gp = style$text_style,
        box_r = style$box_style$radius, box_border_col = style$box_style$border_color,
        box_border_lwd = style$box_style$border_lwd, box_fill = style$box_style$fill,
        box_margin = style$box_style$margin, text_pad = style$box_style$padding
      )
      return(grid::grobTree(bg, blue_box, txt))
    }
    if (is.character(obj)) {
      txt <- wrap_text_top_left(
        obj, inner_vp, gp = style$text_style,
        box_r = style$box_style$radius, box_border_col = style$box_style$border_color,
        box_border_lwd = style$box_style$border_lwd, box_fill = style$box_style$fill,
        box_margin = style$box_style$margin, text_pad = style$box_style$padding
      )
      return(grid::grobTree(bg, blue_box, txt))
    }
    if (is.null(obj)) return(grid::grobTree(bg, blue_box))
    txt <- wrap_text_top_left(
      paste0(obj), inner_vp, gp = style$text_style,
      box_r = style$box_style$radius, box_border_col = style$box_style$border_color,
      box_border_lwd = style$box_style$border_lwd, box_fill = style$box_style$fill,
      box_margin = style$box_style$margin, text_pad = style$box_style$padding
    )
    grid::grobTree(bg, blue_box, txt)
  }

  if (isTRUE(reverse)) {
    widths <- grid::unit.c(outer_margin, grid::unit(1, "null"), hgap, A_width, outer_margin)
    A_col <- 4
    right_col <- 2
  } else {
    widths <- grid::unit.c(outer_margin, A_width, hgap, grid::unit(1, "null"), outer_margin)
    A_col <- 2
    right_col <- 4
  }
  heights <- grid::unit.c(grid::unit(right_split, "null"), vgap, grid::unit(1 - right_split, "null"), bottom_margin)
  gt <- gtable::gtable(widths = widths, heights = heights)

  # outer lanes background across all rows
  if (!is.null(layout_style$outer_margin_bg) && !is.na(layout_style$outer_margin_bg)) {
    gt <- gtable::gtable_add_grob(gt, grid::rectGrob(gp = grid::gpar(fill = layout_style$outer_margin_bg, col = layout_style$outer_margin_bg)),
                          t = 1, l = 1, b = 4, r = 1, z = 0, clip = "on")
    gt <- gtable::gtable_add_grob(gt, grid::rectGrob(gp = grid::gpar(fill = layout_style$outer_margin_bg, col = layout_style$outer_margin_bg)),
                          t = 1, l = 5, b = 4, r = 5, z = 0, clip = "on")
  }
  # inner gap backgrounds
  if (!is.null(layout_style$hgap_bg) && !is.na(layout_style$hgap_bg)) {
    gt <- gtable::gtable_add_grob(gt, grid::rectGrob(gp = grid::gpar(fill = layout_style$hgap_bg, col = layout_style$hgap_bg)),
                          t = 1, l = 3, b = 3, r = 3, z = 0, clip = "on")
  }
  if (!is.null(layout_style$vgap_bg) && !is.na(layout_style$vgap_bg)) {
    gt <- gtable::gtable_add_grob(gt, grid::rectGrob(gp = grid::gpar(fill = layout_style$vgap_bg, col = layout_style$vgap_bg)),
                          t = 2, l = right_col, b = 2, r = right_col, z = 0, clip = "on")
  }
  # bottom margin background across interior (cols 2..4)
  if (!is.null(layout_style$bottom_margin_bg) && !is.na(layout_style$bottom_margin_bg)) {
    gt <- gtable::gtable_add_grob(gt, grid::rectGrob(gp = grid::gpar(fill = layout_style$bottom_margin_bg, col = layout_style$bottom_margin_bg)),
                          t = 4, l = 2, b = 4, r = 4, z = 0, clip = "on")
  }

  A_panel <- .panel_from_item(A_item, panel_style("A", A_item), dbg = debug_boxes)
  B_panel <- .panel_from_item(B_item, panel_style("B", B_item), dbg = debug_boxes)
  C_panel <- .panel_from_item(C_item, panel_style("C", C_item), dbg = debug_boxes)

  gt <- gtable::gtable_add_grob(gt, A_panel, t = 1, l = A_col, b = 3, r = A_col, z = 1, clip = "on")
  gt <- gtable::gtable_add_grob(gt, B_panel, t = 1, l = right_col, z = 1, clip = "on")
  gt <- gtable::gtable_add_grob(gt, C_panel, t = 3, l = right_col, z = 1, clip = "on")
  gt
}

#' Subtitle row layout
#'
#' Renders a full-width subtitle band with optional gradient fill and lanes.
#'
#' @param label Subtitle text.
#' @param layout_style A list from [subtitleLayoutStyle()] for lanes/gradient/background.
#' @param box_style Box styling from [boxStyle()] (radius, border, fill, margin, padding, margin_fill).
#' @param text_style Text styling from [textStyle()].
#' Note: Lanes are controlled by `layout_style` (outer/bottom margins). The immediate gap around the box is controlled by `box_style$margin`/`margin_fill`. Leave the box margin at zero for a single-layer band, or set it (plus `margin_fill`) for a double-layer/3D effect.
#' @return A `gtable` representing the row.
#' @export
str_subtitle_row <- function(
    label,
    layout_style = subtitleLayoutStyle(),
    box_style    = boxStyle(
      radius       = grid::unit(10, "pt"),
      border_color = NA,
      border_lwd   = 1,
      fill         = NA,
      margin       = grid::unit(c(6, 10, 10, 6), "pt"),
      padding      = grid::unit(c(10, 16, 10, 16), "pt")
    ),
    text_style  = textStyle(color = "white", size = 16, face = "bold", family = "sans")
) {
  # merge user overrides for layout_style
  if (is.list(layout_style)) {
    defaults <- subtitleLayoutStyle()
    defaults[names(layout_style)] <- layout_style
    layout_style <- defaults
  } else {
    layout_style <- subtitleLayoutStyle()
  }

  # validate units
  row_h         <- .as_unit_nonneg(layout_style$row_height, "row_height")
  outer_margin  <- .as_unit_nonneg(layout_style$outer_margin, "outer_margin")
  bottom_margin <- .as_unit_nonneg(layout_style$bottom_margin, "bottom_margin")
  box_r         <- .as_unit_nonneg(box_style$radius, "box_r")
  # text_pad/box_margin can be length 4; validate components are non-negative
  check_vec_unit <- function(u, name) {
    if (!inherits(u, "unit")) stop("`", name, "` must be a grid::unit.", call. = FALSE)
    vals <- as.numeric(grid::convertUnit(u, "pt", valueOnly = TRUE))
    if (any(is.na(vals))) stop("`", name, "` cannot contain NA.", call. = FALSE)
    if (any(vals < 0)) stop("`", name, "` must be non-negative.", call. = FALSE)
    u
  }
  text_pad   <- check_vec_unit(box_style$padding, "text_pad")
  box_margin <- check_vec_unit(box_style$margin, "box_margin")

  widths  <- grid::unit.c(outer_margin, grid::unit(1, "null"), outer_margin)
  heights <- grid::unit.c(grid::unit(1, "null"), bottom_margin)
  gt <- gtable::gtable(widths = widths, heights = heights)

  # paint side lanes
  if (!is.null(layout_style$outer_margin_bg) && !is.na(layout_style$outer_margin_bg)) {
    gt <- gtable::gtable_add_grob(gt, grid::rectGrob(gp = grid::gpar(fill = layout_style$outer_margin_bg, col = layout_style$outer_margin_bg)),
                          t = 1, l = 1, b = 2, r = 1, z = 0, clip = "on")
    gt <- gtable::gtable_add_grob(gt, grid::rectGrob(gp = grid::gpar(fill = layout_style$outer_margin_bg, col = layout_style$outer_margin_bg)),
                          t = 1, l = 3, b = 2, r = 3, z = 0, clip = "on")
  }
  # paint bottom lane
  if (!is.null(layout_style$bottom_margin_bg) && !is.na(layout_style$bottom_margin_bg) && as.numeric(grid::convertHeight(bottom_margin, "pt")) > 0) {
    gt <- gtable::gtable_add_grob(gt, grid::rectGrob(gp = grid::gpar(fill = layout_style$bottom_margin_bg, col = layout_style$bottom_margin_bg)),
                          t = 2, l = 2, b = 2, r = 2, z = 0, clip = "on")
  }

  # content cell
  content <- .subtitle_cell(
    label         = label,
    cell_bg_cols  = layout_style$cell_bg_cols,
    cell_bg_stops = layout_style$cell_bg_stops,
    cell_bg_dir   = layout_style$cell_bg_dir,
    text_hjust    = layout_style$text_hjust,
    box_r         = box_r,
    box_border_col= box_style$border_color,
    box_border_lwd= box_style$border_lwd,
    text_gp       = text_style,
    text_pad      = text_pad,
    box_margin    = box_margin,
    margin_fill   = box_style$margin_fill
  )

  gt <- gtable::gtable_add_grob(gt, content, t = 1, l = 2, z = 1, clip = "on")
  gt
}

#' Two-column banner with logo and text
#'
#' Builds a banner with a fixed-width image lane on the left and title/subtitle text on the right.
#'
#' @param image_path Path to a PNG/JPEG logo.
#' @param title,subtitle Text content.
#' @param layout_style A list from [bannerLayoutStyle()] controlling geometry and colors.
#' @param text_style A list with `title` and `subtitle` entries produced by [textStyle()].
#' @return A `gtable` representing the banner.
#' @export
#' @importFrom grid unit rectGrob gpar viewport rasterGrob gTree gList textGrob grobHeight unit.c
#' @importFrom gtable gtable gtable_add_grob
#' @importFrom tools file_ext
#' @importFrom png readPNG
#' @importFrom jpeg readJPEG
str_banner_row <- function(
    image_path,
    title    = "Project Title",
    subtitle = "Concise one-liner about the project",
    layout_style = bannerLayoutStyle(),
    text_style  = list(
      title    = textStyle(color = "white", size = 18, face = "bold", family = "sans"),
      subtitle = textStyle(color = "white", size = 11, face = "plain", family = "sans")
    )
){
  # merge user overrides with defaults
  if (is.list(layout_style)) {
    defaults <- bannerLayoutStyle()
    defaults[names(layout_style)] <- layout_style
    layout_style <- defaults
  } else {
    layout_style <- bannerLayoutStyle()
  }
  # validate and normalize via bannerLayoutStyle
  layout_style <- do.call(bannerLayoutStyle, layout_style)

  # validate styles
  if (is.null(text_style$title) || !inherits(text_style$title, "gpar")) {
    text_style$title <- textStyle(color = "white", size = 18, face = "bold", family = "sans")
  }
  if (is.null(text_style$subtitle) || !inherits(text_style$subtitle, "gpar")) {
    text_style$subtitle <- textStyle(color = "white", size = 11, face = "plain", family = "sans")
  }

  # read logo
  ext <- tolower(tools::file_ext(image_path))
  img <- switch(
    ext,
    png = png::readPNG(image_path),
    jpg = jpeg::readJPEG(image_path),
    jpeg = jpeg::readJPEG(image_path),
    stop("`image_path` must be a PNG or JPEG file.", call. = FALSE)
  )

  # backgrounds
  banner_bg <- grid::rectGrob(gp = grid::gpar(fill = layout_style$banner_bg, col = NA))

  # LEFT PANEL (color + centered logo with inner padding)
  left_outer_vp <- grid::viewport(x = 0, y = 1, width = layout_style$logo_panel_width, height = layout_style$banner_height,
                                  just = c("left","top"))
  left_inner_vp <- grid::viewport(
    x = 0.5, y = 0.5, just = c("center","center"),
    width  = grid::unit(1, "npc") - 2*layout_style$logo_pad_x,
    height = grid::unit(1, "npc") - 2*layout_style$logo_pad_y
  )
  left_panel_bg <- grid::rectGrob(gp = grid::gpar(fill = layout_style$logo_panel_bg, col = NA))

  # keep aspect ratio
  hpx <- dim(img)[1]; wpx <- dim(img)[2]; aspect <- wpx / hpx
  if (aspect >= 1) { w_unit <- grid::unit(1, "npc"); h_unit <- grid::unit(1/aspect, "npc")
  } else            { w_unit <- grid::unit(aspect, "npc"); h_unit <- grid::unit(1, "npc") }

  logo_img <- grid::rasterGrob(
    img, x = 0.5, y = 0.5, just = c("center","center"),
    width = w_unit, height = h_unit, interpolate = TRUE,
    vp = left_inner_vp
  )
  left_panel <- grid::gTree(children = grid::gList(left_panel_bg, logo_img), vp = left_outer_vp)

  # RIGHT TEXT (uses text styles)
  title_g <- grid::textGrob(
    label = title,
    x = grid::unit(0, "npc") + layout_style$text_left_pad,
    y = grid::unit(1, "npc") - layout_style$text_block_top_pad - layout_style$title_vshift,
    just = c("left","top"),
    gp = text_style$title
  )

  # place subtitle just below measured title height
  title_h <- grid::grobHeight(title_g)
  subtitle_y <- grid::unit(1, "npc") - layout_style$text_block_top_pad - layout_style$title_vshift - title_h - layout_style$subtitle_gap

  subtitle_g <- NULL
  if (!is.null(subtitle) && nzchar(subtitle)) {
    subtitle_g <- grid::textGrob(
      label = subtitle,
      x = grid::unit(0, "npc") + layout_style$text_left_pad,
      y = subtitle_y,
      just = c("left","top"),
      gp = text_style$subtitle
    )
  }

  # assemble
  gt <- gtable::gtable(widths = grid::unit.c(layout_style$logo_panel_width, grid::unit(1, "null")), heights = layout_style$banner_height)
  gt <- gtable::gtable_add_grob(gt, banner_bg,  t = 1, l = 1, b = 1, r = 2, z = 0)
  gt <- gtable::gtable_add_grob(gt, left_panel, t = 1, l = 1, z = 1, clip = "on")
  gt <- gtable::gtable_add_grob(gt, title_g,    t = 1, l = 2, z = 2, clip = "off", name = "title")
  if (!is.null(subtitle_g)) {
    gt <- gtable::gtable_add_grob(gt, subtitle_g, t = 1, l = 2, z = 2, clip = "off", name = "subtitle")
  }
  gt
}

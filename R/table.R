# Tables ---------------------------------------------------------------------------------

#' Table cell with its own style
#'
#' Wraps one table value with overrides for that cell only: a faint "No data",
#' a bold value, an indented sub-term. Fields left `NULL` come from the
#' column style.
#'
#' @param x Cell text.
#' @param style A [text_style()] (layered over the column style) or a role
#'   name.
#' @param indent Left indent (`grid::unit` or inches).
#' @param markup `"plain"`, `"markdown"` or `"html"`, as in [bb_text()].
#' @param align Optional alignment overriding the column's.
#' @return A `bb_cell` object.
#' @examples
#' cell("No data", style = text_style(color = "faint"))
#' @export
cell <- function(x, style = NULL, indent = 0, markup = c("plain", "markdown", "html"), align = NULL) {
  if (!is.null(align)) align <- match.arg(align, c("left", "center", "right"))
  structure(list(x = x, style = style, indent = .in(indent, "indent"), markup = match.arg(markup),
                 align = align), class = "bb_cell")
}

#' @noRd
.cell_block <- function(c, col_style, align, role = "table_body") {
  st <- .layer_style(col_style, c$style)
  b <- .text_block(c$x, st, role, c$markup, c$align %||% align)
  if (c$indent > 0) bb_box(b, box_style(padding = c(0, 0, 0, c$indent))) else b
}

#' @noRd
.table_cell <- function(x, col_style, align, role = "table_body") {
  if (is.null(x)) return(NULL)
  if (inherits(x, "bb_cell")) return(.cell_block(x, col_style, align, role))
  if (inherits(x, "bb_block")) return(x)
  if ((is.character(x) || is.numeric(x) || is.factor(x) || is.logical(x)) && length(x) <= 1) {
    if (!length(x) || is.na(x) || !nzchar(as.character(x))) return(NULL)
    return(.text_block(as.character(x), col_style, role, "plain", align))
  }
  as_block(x)
}

#' Table style
#'
#' `table_style()` defaults to a rules-only table: no fills, no vertical
#' borders, light dividers between rows and a stronger rule under the header.
#' `table_style_grid()` is the boxed look: filled header, borders around every
#' cell, alternating row fills.
#'
#' @param divider A [line_style()] drawn under each body row, or `NULL`.
#' @param header_rule A [line_style()] under the header row, or `NULL`.
#' @param last_divider Draw the divider under the last row too.
#' @param pad_x,pad_y Cell padding (`grid::unit` or inches).
#' @param header_pad_y Vertical padding of header cells.
#' @param col_gap Space kept free at the right of every column but the last.
#' @param valign Vertical alignment of body cells: `"center"`, `"top"` (for
#'   rows of long wrapped text) or `"bottom"`.
#' @param header_valign Vertical alignment of header cells (`"bottom"` lines
#'   up wrapped header labels on the rule).
#' @param fill,alt_fill Body row fills; `alt_fill` on even rows. `NA` for
#'   none.
#' @param header_fill Header row fill.
#' @param border A [line_style()] for the outer border and vertical lines
#'   between columns, or `NULL`.
#' @param header_style,body_style Default text styles (or role names) for
#'   header and body cells; roles `table_header` and `table_body`.
#' @param ... For `table_style_grid()`, [table_style()] arguments that
#'   override the grid preset.
#' @return A `bb_table_style` object.
#' @examples
#' table_style(divider = line_style("rule_faint"), valign = "top")
#' table_style_grid()
#' @export
table_style <- function(divider = line_style("rule_light", 0.75), header_rule = line_style("rule_strong", 0.75),
                        last_divider = TRUE, pad_x = 0, pad_y = 9 / 96, header_pad_y = 7 / 96,
                        col_gap = 12 / 96, valign = c("center", "top", "bottom"),
                        header_valign = c("center", "top", "bottom"), fill = NA, alt_fill = NA,
                        header_fill = NA, border = NULL, header_style = NULL, body_style = NULL) {
  structure(list(divider = .as_line_style(divider, "divider"),
                 header_rule = .as_line_style(header_rule, "header_rule"),
                 last_divider = isTRUE(last_divider), pad_x = .in(pad_x, "pad_x"), pad_y = .in(pad_y, "pad_y"),
                 header_pad_y = .in(header_pad_y, "header_pad_y"), col_gap = .in(col_gap, "col_gap"),
                 valign = match.arg(valign), header_valign = match.arg(header_valign),
                 fill = fill, alt_fill = alt_fill, header_fill = header_fill,
                 border = .as_line_style(border, "border"), header_style = header_style,
                 body_style = body_style),
            class = "bb_table_style")
}

#' @rdname table_style
#' @export
table_style_grid <- function(...) {
  args <- list(divider = line_style("rule_strong", 0.5), header_rule = line_style("rule_strong", 0.5),
               pad_x = 4 / 72, pad_y = 4 / 72, header_pad_y = 4 / 72, col_gap = 0, fill = "white",
               alt_fill = "panel", header_fill = "primary", border = line_style("rule_strong", 0.5),
               header_style = text_style("table_header", color = "on_primary", weight = 700))
  over <- list(...)
  args[names(over)] <- over
  do.call(table_style, args)
}

#' Table
#'
#' A table whose rows are as tall as their content at the width the table
#' gets. Every cell can hold text (with per-column style and alignment, and
#' per-cell overrides through [cell()]) or any block: [bb_status()],
#' [bb_dot()], images, plots with a height, even nested stacks.
#'
#' @param rows A list of rows (each a list with one entry per column), or a
#'   `data.frame`.
#' @param header Optional header labels; `NULL` for no header row. For a
#'   data frame, defaults to its column names.
#' @param widths Column widths as in [bb_cols()]: `NULL` (equal), numeric
#'   proportions, or a unit vector mixing absolute and `"null"` widths.
#' @param align Per-column alignment (`"left"`, `"center"`, `"right"`),
#'   recycled.
#' @param col_style Per-column text style(s): one [text_style()] / role name,
#'   or a list recycled over columns. Layered over `style$body_style`.
#' @param header_style Header text style; overrides `style$header_style`.
#' @param style A [table_style()].
#' @param min_row_heights Minimum body row height(s), recycled.
#' @param header_case Letter case for header labels (`"none"`, `"upper"`).
#' @return A block. Inside [bb_cols()] with `sync_rows = TRUE`, side-by-side
#'   tables share row heights.
#' @examples
#' bb_table(list(list("DTPCV3", "94.1%"), list("MCV1", cell("No data", text_style(color = "faint")))),
#'          header = c("Vaccine", "Coverage"), widths = c(3, 1), align = c("left", "right"))
#' @export
bb_table <- function(rows, header = NULL, widths = NULL, align = "left", col_style = NULL,
                     header_style = NULL, style = table_style(), min_row_heights = 0,
                     header_case = c("none", "upper")) {
  if (!inherits(style, "bb_table_style")) stop("`style` must be a table_style().", call. = FALSE)
  header_case <- match.arg(header_case)
  args <- list(rows = rows, header = header, widths = widths, align = align, col_style = col_style,
               header_style = header_style, style = style, header_case = header_case)
  if (is.data.frame(rows)) {
    if (missing(header)) header <- names(rows)
    df <- rows
    rows <- lapply(seq_len(nrow(df)), function(i) lapply(df[i, , drop = TRUE], function(v) {
      if (is.factor(v)) v <- as.character(v)
      if (length(v) == 1 && is.na(v)) "" else v
    }))
    args$rows <- rows; args$header <- header
  }
  if (!is.list(rows)) stop("`rows` must be a list of rows or a data.frame.", call. = FALSE)
  nc <- if (!is.null(widths)) length(widths) else if (length(rows)) length(rows[[1]]) else length(header)
  if (nc < 1) stop("Can't tell how many columns the table has.", call. = FALSE)
  for (i in seq_along(rows)) {
    if (!is.list(rows[[i]])) rows[[i]] <- as.list(rows[[i]])
    if (length(rows[[i]]) != nc) {
      stop(sprintf("Row %d has %d cells; expected %d.", i, length(rows[[i]]), nc), call. = FALSE)
    }
  }
  if (!is.null(header) && length(header) != nc) stop("`header` must have ", nc, " labels.", call. = FALSE)
  align <- rep_len(align, nc)
  bad <- !align %in% c("left", "center", "right")
  if (any(bad)) stop("`align` must use left, center or right.", call. = FALSE)
  if (is.null(col_style) || is.character(col_style) || inherits(col_style, "bb_text_style")) col_style <- list(col_style)
  col_style <- rep_len(col_style, nc)
  col_style <- lapply(col_style, function(s) .layer_style(style$body_style, s))
  h_style <- .layer_style(style$header_style, header_style)
  if (header_case != "none") h_style <- .layer_style(h_style, text_style(case = header_case))

  hdr <- if (is.null(header)) NULL else lapply(seq_len(nc), function(j) .table_cell(header[[j]], h_style, align[j], "table_header"))
  body <- lapply(rows, function(r) lapply(seq_len(nc), function(j) .table_cell(r[[j]], col_style[[j]], align[j])))
  nr <- length(body)
  mins <- if (nr) rep_len(.gap_vec(min_row_heights), nr) else numeric()

  cache <- new.env(parent = emptyenv())
  lay <- function(width) {
    key <- paste(.theme_id(), format(round(width, 6), nsmall = 6))
    if (!is.null(cache[[key]])) return(cache[[key]])
    w <- .resolve_widths(widths, nc, width)
    inner <- pmax(w - c(rep(style$col_gap, nc - 1), 0) - 2 * style$pad_x, 0.01)
    x_off <- c(0, cumsum(w))[seq_len(nc)]
    cell_h <- function(b, j) if (is.null(b)) 0 else { h <- .measure(b, inner[j]); if (is.na(h)) .min_height(b, inner[j]) else h }
    hh <- if (is.null(hdr)) 0 else max(vapply(seq_len(nc), function(j) cell_h(hdr[[j]], j), numeric(1))) + 2 * style$header_pad_y
    rh <- vapply(seq_len(nr), function(i) {
      max(mins[i], max(vapply(seq_len(nc), function(j) cell_h(body[[i]][[j]], j), numeric(1))) + 2 * style$pad_y)
    }, numeric(1))
    out <- list(w = w, inner = inner, x_off = x_off, hh = hh, rh = rh, total = hh + sum(rh))
    cache[[key]] <- out
    out
  }

  place_cell <- function(b, j, l, top, row_h, pad_y, valign) {
    if (is.null(b)) return(NULL)
    iw <- l$inner[j]
    h <- .measure(b, iw)
    flex <- is.na(h)
    if (flex) h <- row_h - 2 * pad_y
    nw <- .natural_width(b, iw)
    x <- l$x_off[j] + style$pad_x + .align_x(align[j], iw, nw)
    y <- if (valign == "top" || flex) top + pad_y
         else if (valign == "bottom") top + row_h - pad_y - h
         else top + (row_h - h) / 2
    .place_block(b, x, y, nw, h)
  }

  hline <- function(y, ls, width) {
    yy <- unit(1, "npc") - unit(y, "in")
    segmentsGrob(unit(0, "in"), yy, unit(width, "in"), yy, gp = .line_gp(ls))
  }

  new_block("table",
    measure = function(width) lay(width)$total,
    render = function(width, height) {
      l <- lay(width)
      kids <- gList()
      if (!is.null(hdr) && !(length(style$header_fill) == 1 && is.na(style$header_fill))) {
        kids <- gList(kids, .place(rectGrob(gp = gpar(fill = .col(style$header_fill), col = NA)), 0, 0, width, l$hh))
      }
      y <- l$hh
      for (i in seq_len(nr)) {
        f <- if (i %% 2 == 0 && !is.na(style$alt_fill)) style$alt_fill else style$fill
        if (!is.na(f)) kids <- gList(kids, .place(rectGrob(gp = gpar(fill = .col(f), col = NA)), 0, y, width, l$rh[i]))
        y <- y + l$rh[i]
      }
      if (!is.null(hdr)) {
        for (j in seq_len(nc)) kids <- gList(kids, place_cell(hdr[[j]], j, l, 0, l$hh, style$header_pad_y, style$header_valign))
        if (.has_line(style$header_rule)) kids <- gList(kids, hline(l$hh, style$header_rule, width))
      }
      y <- l$hh
      for (i in seq_len(nr)) {
        for (j in seq_len(nc)) kids <- gList(kids, place_cell(body[[i]][[j]], j, l, y, l$rh[i], style$pad_y, style$valign))
        y <- y + l$rh[i]
        if (.has_line(style$divider) && (i < nr || style$last_divider)) kids <- gList(kids, hline(y, style$divider, width))
      }
      if (.has_line(style$border)) {
        gp <- .line_gp(style$border); gp$fill <- NA
        kids <- gList(kids, .place(rectGrob(gp = gp), 0, 0, width, l$total))
        xs <- cumsum(l$w)[-nc]
        if (length(xs)) {
          kids <- gList(kids, segmentsGrob(unit(xs, "in"), unit(1, "npc"), unit(xs, "in"),
                                           unit(1, "npc") - unit(l$total, "in"), gp = .line_gp(style$border)))
        }
      }
      gTree(children = kids)
    },
    row_heights = function(width) lay(width)$rh,
    with_min_rows = function(m) {
      a <- args
      a$min_row_heights <- pmax(rep_len(m, max(nr, 1))[seq_len(nr)], mins)
      do.call(bb_table, a)
    },
    n_rows = nr)
}

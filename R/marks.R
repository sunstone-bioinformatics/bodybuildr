# Status icons and dots ----------------------------------------------------------------

#' @noRd
.status_state <- function(state) {
  if (is.null(state) || length(state) == 0) return("unknown")
  s <- state[[1]]
  if (is.logical(s)) return(if (is.na(s)) "unknown" else if (s) "yes" else "no")
  s <- tolower(trimws(as.character(s)))
  if (is.na(s) || !s %in% c("yes", "no", "unknown")) "unknown" else s
}

#' Internal: status icon (filled circle + white glyph) centred at (cx, cy)
#'
#' `cx`, `cy` are units; `s` the diameter in inches.
#' @noRd
.status_glyph <- function(state, cx, cy, s, palette) {
  state <- .status_state(state)
  col <- .col(palette[[state]])
  circle <- circleGrob(x = cx, y = cy, r = unit(s / 2, "in"), gp = gpar(fill = col, col = NA))
  glyph_gp <- gpar(col = "white", lwd = s * 96 * 0.14, lineend = "round", linejoin = "round")
  off <- function(u, d) u + unit(d * s, "in")
  glyph <- switch(state,
    yes = linesGrob(x = unit.c(off(cx, -0.22), off(cx, -0.06), off(cx, 0.23)),
                    y = unit.c(off(cy, 0.01), off(cy, -0.15), off(cy, 0.16)), gp = glyph_gp),
    no = gTree(children = gList(
      segmentsGrob(off(cx, -0.16), off(cy, -0.16), off(cx, 0.16), off(cy, 0.16), gp = glyph_gp),
      segmentsGrob(off(cx, -0.16), off(cy, 0.16), off(cx, 0.16), off(cy, -0.16), gp = glyph_gp))),
    unknown = segmentsGrob(off(cx, -0.2), cy, off(cx, 0.2), cy, gp = glyph_gp))
  gTree(children = gList(circle, glyph))
}

#' Internal: one mark shape centred at (cx, cy), size s inches
#' @noRd
.mark_grob <- function(shape, cx, cy, s, color) {
  gp <- gpar(fill = .col(color), col = NA)
  switch(shape,
    circle = circleGrob(cx, cy, r = unit(s / 2, "in"), gp = gp),
    square = rectGrob(cx, cy, unit(s, "in"), unit(s, "in"), gp = gp),
    diamond = polygonGrob(unit.c(cx - unit(s / 2, "in"), cx, cx + unit(s / 2, "in"), cx),
                          unit.c(cy, cy + unit(s / 2, "in"), cy, cy - unit(s / 2, "in")), gp = gp))
}

.align_x <- function(align, slot, used) switch(align, right = slot - used, center = (slot - used) / 2, 0)

#' Status icon
#'
#' A filled circle with a white check (`"yes"`), cross (`"no"`) or dash
#' (`"unknown"`), drawn as vectors in the theme status palette, optionally
#' followed by a label such as "Yes". `TRUE`/`FALSE` map to yes/no; `NA` and
#' anything else to unknown. Use it as a table cell, in columns, or anywhere
#' a block goes.
#'
#' @param state `"yes"`, `"no"`, `"unknown"`, or a logical.
#' @param label Optional text printed after the icon.
#' @param size Icon diameter (`grid::unit` or inches). Default 14px.
#' @param palette Named colours for yes/no/unknown; defaults to the theme's.
#' @param style Text style of the label ([text_style()] or a role name);
#'   defaults to the `status_label` role.
#' @param gap Space between icon and label.
#' @param align Horizontal position in its slot: `"left"`, `"center"`,
#'   `"right"`. Inside [bb_table()] the column alignment places it instead.
#' @param nudge_y Upward shift (inches) that lines the icon up optically with
#'   neighbouring text (text boxes sit slightly high). Default 1.5px.
#' @return A block.
#' @examples
#' bb_status("yes", label = "Yes")
#' bb_status(NA)
#' @export
bb_status <- function(state, label = NULL, size = 14 / 96, palette = NULL, style = NULL,
                      gap = 7 / 96, align = c("left", "center", "right"), nudge_y = 1.5 / 96) {
  align <- match.arg(align)
  st <- .status_state(state)
  s <- .in(size, "size"); g <- .in(gap, "gap")
  has_label <- !is.null(label) && length(label) == 1 && !is.na(label) && nzchar(label)
  pal <- function() palette %||% bb_get_theme()$status
  lab <- function() {
    rs <- .resolve_text_style(style, "status_label")
    list(rs = rs, gp = .as_gpar(rs))
  }
  used_w <- function() if (has_label) s + g + .text_w_in(label, lab()$gp) else s
  new_block("status",
    measure = function(width) if (has_label) max(s, .line_h_in(lab()$rs)) else s,
    natural_width = function(width) used_w(),
    render = function(width, height) {
      x0 <- .align_x(align, width, min(used_w(), width))
      cy <- unit(0.5, "npc") + unit(nudge_y, "in")
      icon <- .status_glyph(st, unit(x0 + s / 2, "in"), cy, s, pal())
      if (!has_label) return(icon)
      gTree(children = gList(icon, textGrob(label, x = unit(x0 + s + g, "in"), y = cy,
                                            just = c("left", "center"), gp = lab()$gp)))
    },
    state = st)
}

#' Dots and other small marks
#'
#' One or more filled marks in a row: stock-out dots, schedule dots and
#' diamonds. `color`, `shape` and `size` are recycled to the longest, so
#' `bb_dot("primary", shape = c("circle", "circle", "diamond"))` draws two
#' dots and a diamond. Marks are centred vertically and separated by `gap`.
#'
#' @param color Mark colour(s); theme names allowed. Marks with an `NA`
#'   colour are skipped.
#' @param size Mark size(s) (`grid::unit` or inches). Default 10px.
#' @param shape `"circle"`, `"square"` or `"diamond"`, one per mark or
#'   recycled.
#' @param gap Space between marks.
#' @param align Horizontal position in its slot. Inside [bb_table()] the
#'   column alignment places it instead.
#' @return A block.
#' @examples
#' bb_dot("#2F7D55")
#' bb_dot("primary", size = c(7, 7, 9) / 96, shape = c("circle", "circle", "diamond"))
#' @export
bb_dot <- function(color, size = 10 / 96, shape = "circle", gap = 3 / 96,
                   align = c("left", "center", "right")) {
  align <- match.arg(align)
  bad <- !shape %in% c("circle", "square", "diamond")
  if (any(bad)) stop("`shape` must use circle, square or diamond.", call. = FALSE)
  sz <- if (inherits(size, "unit")) .unit_in(size) else size
  if (!is.numeric(sz) || anyNA(sz) || any(sz < 0)) stop("`size` must be non-negative.", call. = FALSE)
  n <- if (length(color)) max(length(color), length(shape), length(sz)) else 0
  color <- rep_len(color, n); shape <- rep_len(shape, n); sz <- rep_len(sz, n)
  keep <- !is.na(color)
  color <- color[keep]; shape <- shape[keep]; sz <- sz[keep]
  n <- length(color)
  g <- .in(gap, "gap")
  used <- if (n) sum(sz) + (n - 1) * g else 0
  new_block("dot",
    measure = function(width) if (n) max(sz) else 0,
    natural_width = function(width) used,
    render = function(width, height) {
      if (!n) return(nullGrob())
      x <- .align_x(align, width, min(used, width))
      kids <- vector("list", n)
      for (i in seq_len(n)) {
        kids[[i]] <- .mark_grob(shape[i], unit(x + sz[i] / 2, "in"), unit(0.5, "npc"), sz[i], color[i])
        x <- x + sz[i] + g
      }
      gTree(children = do.call(gList, kids))
    })
}

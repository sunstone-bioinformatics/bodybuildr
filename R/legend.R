# Legends ------------------------------------------------------------------------------

.key_types <- c("swatch", "dot", "diamond", "status", "line", "dash")

#' Legend key
#'
#' One entry of a [bb_legend()].
#'
#' @param type `"swatch"` (square), `"dot"`, `"diamond"`, `"status"` (a
#'   [bb_status()] icon), `"line"` or `"dash"`.
#' @param label Label text.
#' @param color Key colour (theme names allowed). Not needed for `"status"`.
#' @param state Status for `type = "status"`.
#' @return A `bb_legend_key` object.
#' @examples
#' legend_key("swatch", "<80%", "#C8503F")
#' legend_key("status", "Meets", state = "yes")
#' @export
legend_key <- function(type, label, color = NULL, state = NULL) {
  if (!is.character(type) || length(type) != 1 || !type %in% .key_types) {
    stop("`type` must be one of: ", paste(.key_types, collapse = ", "), ".", call. = FALSE)
  }
  if (type != "status" && is.null(color)) stop("`color` is required for `", type, "` keys.", call. = FALSE)
  structure(list(type = type, label = as.character(label), color = color, state = state),
            class = "bb_legend_key")
}

#' Inline legend
#'
#' Keys and labels flow left to right and wrap onto further lines when they
#' don't fit the width (long translated labels). An optional `note` sits
#' right-aligned on the first line when there is room, otherwise on its own
#' line below.
#'
#' @param keys A list of [legend_key()]s.
#' @param note Optional note text.
#' @param align `"left"` or `"right"`.
#' @param style Label text style ([text_style()] or role name); defaults to
#'   the `legend` role.
#' @param key_size Key size (`grid::unit` or inches). Default 12px.
#' @param gap Space between entries.
#' @param key_gap Space between a key and its label.
#' @param row_height Height of one legend line; by default from the key and
#'   label size.
#' @param wrap Wrap onto several lines when needed.
#' @return A block.
#' @examples
#' bb_legend(list(legend_key("swatch", "<80%", "#C8503F"),
#'                legend_key("swatch", "95-100%", "#8CC49A")),
#'           note = "National coverage")
#' @export
bb_legend <- function(keys, note = NULL, align = c("left", "right"), style = NULL,
                      key_size = 12 / 96, gap = 18 / 96, key_gap = 6 / 96, row_height = NULL,
                      wrap = TRUE) {
  align <- match.arg(align)
  if (inherits(keys, "bb_legend_key")) keys <- list(keys)
  if (!is.list(keys) || !all(vapply(keys, inherits, logical(1), "bb_legend_key"))) {
    stop("`keys` must be a list of legend_key() objects.", call. = FALSE)
  }
  ks <- .in(key_size, "key_size"); g <- .in(gap, "gap"); kg <- .in(key_gap, "key_gap")
  rh_user <- .in(row_height, "row_height", allow_null = TRUE)
  key_w <- function(k) if (k$type %in% c("line", "dash")) ks * 4 / 3 else ks

  lay <- function(width) {
    rs <- .resolve_text_style(style, "legend")
    gp <- .as_gpar(rs)
    rh <- rh_user %||% (max(ks, .line_h_in(rs)) * 1.75)
    lw <- if (length(keys)) .text_w_in(vapply(keys, `[[`, character(1), "label"), gp) else numeric()
    iw <- vapply(seq_along(keys), function(i) key_w(keys[[i]]) + kg + lw[i], numeric(1))
    line_of <- integer(length(keys)); line <- 1L; run <- 0
    for (i in seq_along(keys)) {
      if (wrap && run > 0 && run + iw[i] > width + 1e-9) { line <- line + 1L; run <- 0 }
      line_of[i] <- line
      run <- run + iw[i] + g
    }
    n_lines <- if (length(keys)) max(line_of) else 0L
    totals <- vapply(seq_len(n_lines), function(l) sum(iw[line_of == l]) + g * (sum(line_of == l) - 1), numeric(1))
    note_line <- 0L; note_w <- 0
    if (!is.null(note) && nzchar(note)) {
      note_w <- .text_w_in(note, gp)
      if (n_lines >= 1 && totals[1] + g + note_w <= width) note_line <- 1L
      else { n_lines <- n_lines + 1L; note_line <- n_lines }
    }
    list(gp = gp, rh = rh, iw = iw, line_of = line_of, n_lines = n_lines, totals = totals,
         note_line = note_line, note_w = note_w)
  }

  new_block("legend",
    measure = function(width) { l <- lay(width); l$n_lines * l$rh },
    render = function(width, height) {
      l <- lay(width)
      pal <- bb_get_theme()$status
      kids <- gList(); x <- 0
      for (i in seq_along(keys)) {
        if (i == 1 || l$line_of[i] != l$line_of[i - 1]) {
          x <- if (align == "right") width - l$totals[l$line_of[i]] else 0
        }
        k <- keys[[i]]; kw <- key_w(k)
        yc <- unit(1, "npc") - unit((l$line_of[i] - 0.5) * l$rh, "in")
        cx <- unit(x + kw / 2, "in")
        col <- if (!is.null(k$color)) .col(k$color) else NA
        key <- switch(k$type,
          swatch  = rectGrob(cx, yc, unit(ks * 0.85, "in"), unit(ks * 0.85, "in"), gp = gpar(fill = col, col = NA)),
          dot     = circleGrob(cx, yc, r = unit(ks * 0.36, "in"), gp = gpar(fill = col, col = NA)),
          diamond = .mark_grob("diamond", cx, yc, ks * 0.76, col),
          status  = .status_glyph(k$state, cx, yc, ks, pal),
          line    = segmentsGrob(unit(x, "in"), yc, unit(x + kw, "in"), yc, gp = gpar(col = col, lwd = 1.5)),
          dash    = segmentsGrob(unit(x, "in"), yc, unit(x + kw, "in"), yc, gp = gpar(col = col, lwd = 1, lty = "22")))
        lab <- textGrob(k$label, x = unit(x + kw + kg, "in"), y = yc, just = c("left", "center"), gp = l$gp)
        kids <- gList(kids, key, lab)
        x <- x + l$iw[i] + g
      }
      if (l$note_line > 0) {
        yc <- unit(1, "npc") - unit((l$note_line - 0.5) * l$rh, "in")
        right <- l$note_line == 1 && length(keys) > 0
        kids <- gList(kids, textGrob(note, x = unit(if (right || align == "right") width else 0, "in"), y = yc,
                                     just = c(if (right || align == "right") "right" else "left", "center"),
                                     gp = l$gp))
      }
      gTree(children = kids)
    })
}

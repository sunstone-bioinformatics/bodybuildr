# Layout containers ------------------------------------------------------------------

.collect <- function(dots, .list) {
  items <- c(dots, .list %||% list())
  lapply(items, as_block)
}

.valign_off <- function(valign, slot, h) switch(valign, center = (slot - h) / 2, bottom = slot - h, 0)

#' Stack blocks vertically
#'
#' Children are placed top to bottom, each as tall as it measures. Flexible
#' children (plots without a height, [bb_spacer()] without a height) share the
#' height left over when the stack is given more room than its content needs,
#' as the body of a [bb_page()] is. A stack with flexible children is itself
#' flexible.
#'
#' @param ... Blocks or anything [as_block()] accepts. `NULL`s are dropped.
#' @param gap Space between children (`grid::unit` or inches), recycled.
#' @param .list Optional list of further children.
#' @return A block.
#' @examples
#' bb_stack("Title", "Body text", gap = unit(6, "pt"))
#' @export
bb_stack <- function(..., gap = 0, .list = NULL) {
  kids <- Filter(Negate(is.null), .collect(list(...), .list))
  gaps <- if (length(kids) > 1) rep_len(.gap_vec(gap), length(kids) - 1) else numeric()

  lay <- function(width, height = NA) {
    h <- vapply(kids, .measure, numeric(1), width = width)
    flex <- is.na(h)
    fixed_total <- sum(h[!flex]) + sum(gaps)
    if (any(flex)) {
      mins <- vapply(kids[flex], .min_height, numeric(1), width = width)
      share <- if (is.na(height)) 0 else max(height - fixed_total, 0) / sum(flex)
      h[flex] <- pmax(share, mins)
    }
    list(h = h, flex = flex)
  }

  new_block(
    "stack",
    measure = function(width) {
      if (!length(kids)) return(0)
      l <- lay(width)
      if (any(l$flex)) NA_real_ else sum(l$h) + sum(gaps)
    },
    min_height = function(width) {
      if (!length(kids)) return(0)
      sum(lay(width)$h) + sum(gaps)
    },
    render = function(width, height) {
      if (!length(kids)) return(nullGrob())
      l <- lay(width, height)
      y <- 0
      out <- gList()
      for (i in seq_along(kids)) {
        out <- gList(out, .place_block(kids[[i]], 0, y, width, l$h[i]))
        y <- y + l$h[i] + if (i < length(kids)) gaps[i] else 0
      }
      gTree(children = out)
    },
    children = kids
  )
}

.gap_vec <- function(gap) {
  if (inherits(gap, "unit")) {
    v <- .unit_in(gap)
  } else if (is.numeric(gap)) {
    v <- as.numeric(gap)
  } else {
    stop("`gap` must be a unit or numeric (inches).", call. = FALSE)
  }
  if (!length(v) || anyNA(v) || any(v < 0)) stop("`gap` must be non-negative.", call. = FALSE)
  v
}

#' Place blocks side by side
#'
#' Splits the available width into columns and places one block in each,
#' top aligned by default. The row is as tall as its tallest fixed-height
#' child; flexible children (plots without a height) stretch to that height.
#'
#' **Widths.** `NULL` gives equal columns. Numbers are proportions
#' (`c(2, 1)`). A unit vector mixes absolute and proportional widths:
#' `unit(c(3.25, 1), c("in", "null"))` takes 3.25 in for the first column
#' and gives the rest to the second.
#'
#' **Row sync.** With `sync_rows = TRUE`, children that are tables
#' ([bb_table()]) get the same row heights, so dividers line up across
#' columns. Shorter tables are padded with nothing; only existing rows grow.
#'
#' @param ... Blocks or anything [as_block()] accepts. `NULL` leaves the
#'   column empty.
#' @param widths Column widths: `NULL`, numeric proportions or a unit vector.
#' @param gap Space between columns (`grid::unit` or inches).
#' @param valign Vertical alignment of shorter children: `"top"`,
#'   `"center"` or `"bottom"`.
#' @param sync_rows Line up row heights of table children.
#' @param .list Optional list of further children.
#' @return A block.
#' @examples
#' bb_cols("Left", "Right", widths = c(2, 1), gap = 0.2)
#' @export
bb_cols <- function(..., widths = NULL, gap = 0, valign = c("top", "center", "bottom"),
                    sync_rows = FALSE, .list = NULL) {
  valign <- match.arg(valign)
  kids <- .collect(list(...), .list)
  n <- length(kids)
  if (!n) stop("`bb_cols()` needs at least one column.", call. = FALSE)
  gap_in <- .in(gap, "gap")
  if (!is.null(widths) && length(widths) != n) {
    stop("`widths` must have one entry per column (", n, "), not ", length(widths), ".", call. = FALSE)
  }

  synced <- new.env(parent = emptyenv())
  col_kids <- function(cw) {
    if (!isTRUE(sync_rows)) return(kids)
    key <- paste(.theme_id(), paste(round(cw, 6), collapse = ","))
    if (!is.null(synced[[key]])) return(synced[[key]])
    rows <- lapply(seq_len(n), function(i) {
      k <- kids[[i]]
      if (!is.null(k) && is.function(k$row_heights)) k$row_heights(cw[i]) else NULL
    })
    len <- max(c(0, lengths(rows)))
    out <- kids
    if (len > 0) {
      padded <- lapply(rows, function(r) c(r, rep(0, len - length(r))))
      mins <- do.call(pmax, padded)
      for (i in seq_len(n)) {
        if (!is.null(rows[[i]])) out[[i]] <- kids[[i]]$with_min_rows(mins[seq_along(rows[[i]])])
      }
    }
    synced[[key]] <- out
    out
  }

  lay <- function(width) {
    cw <- .resolve_widths(widths, n, width, gap_in * (n - 1))
    ks <- col_kids(cw)
    h <- vapply(seq_len(n), function(i) if (is.null(ks[[i]])) 0 else .measure(ks[[i]], cw[i]), numeric(1))
    flex <- is.na(h)
    mins <- vapply(seq_len(n), function(i) if (flex[i]) .min_height(ks[[i]], cw[i]) else 0, numeric(1))
    list(cw = cw, h = h, flex = flex, kids = ks,
         row_h = max(c(0, h[!flex], mins)), any_fixed = any(!flex))
  }

  new_block(
    "cols",
    measure = function(width) {
      l <- lay(width)
      if (!l$any_fixed) NA_real_ else l$row_h
    },
    min_height = function(width) lay(width)$row_h,
    render = function(width, height) {
      l <- lay(width)
      x <- 0
      out <- gList()
      for (i in seq_len(n)) {
        k <- l$kids[[i]]
        if (!is.null(k)) {
          hi <- if (l$flex[i]) height else min(l$h[i], height)
          y <- if (l$flex[i]) 0 else .valign_off(valign, height, hi)
          out <- gList(out, .place_block(k, x, y, l$cw[i], hi))
        }
        x <- x + l$cw[i] + gap_in
      }
      gTree(children = out)
    },
    children = kids
  )
}

#' Box around a block
#'
#' Adds padding, a fill (solid, [gradient_fill()] or [stripe_fill()]), a
#' border and a margin around any block. This is the box-spacing band of the
#' margin model: it never affects page margins or layout gaps.
#'
#' @param x A block or anything [as_block()] accepts. `NULL` gives an empty
#'   box as tall as its padding.
#' @param style A [box_style()].
#' @return A block. Flexible when `x` is flexible.
#' @examples
#' bb_box(bb_text("A note", style = "note"), box_style_panel())
#' @export
bb_box <- function(x, style = box_style()) {
  if (!inherits(style, "bb_box_style")) stop("`style` must be a box_style().", call. = FALSE)
  kid <- as_block(x)
  m <- style$margin; p <- style$padding
  inner_w <- function(width) max(width - m[2] - m[4] - p[2] - p[4], 0)
  extra_h <- m[1] + m[3] + p[1] + p[3]
  new_block(
    "box",
    measure = function(width) {
      if (is.null(kid)) return(extra_h)
      h <- .measure(kid, inner_w(width))
      if (is.na(h)) NA_real_ else h + extra_h
    },
    min_height = function(width) {
      if (is.null(kid)) return(extra_h)
      .min_height(kid, inner_w(width)) + extra_h
    },
    render = function(width, height) {
      out <- gList()
      if (!is.na(style$margin_fill)) out <- gList(out, rectGrob(gp = gpar(fill = .col(style$margin_fill), col = NA)))
      bw <- max(width - m[2] - m[4], 0); bh <- max(height - m[1] - m[3], 0)
      out <- gList(out, .place(.shape_grob(style$fill, bw, bh, style$radius, style$border), m[4], m[1], bw, bh))
      if (!is.null(kid)) {
        out <- gList(out, .place_block(kid, m[4] + p[4], m[1] + p[1], inner_w(width),
                                       max(height - extra_h, 0)))
      }
      gTree(children = out)
    },
    full_bleed = isTRUE(kid$full_bleed)
  )
}

#' Empty space
#'
#' A fixed gap, or with `height = NULL` a flexible one that soaks up spare
#' height in a stack (for example to push the last blocks of a page down).
#'
#' @param height `grid::unit`, inches, or `NULL` for flexible.
#' @return A block.
#' @examples
#' bb_stack("Top", bb_spacer(0.2), "Below")
#' @export
bb_spacer <- function(height = NULL) {
  h <- .in(height, "height", allow_null = TRUE)
  new_block("spacer",
            measure = function(width) if (is.null(h)) NA_real_ else h,
            render = function(width, height) nullGrob())
}

#' Fix a block's height
#'
#' Gives a flexible block (a plot, a grob, a placeholder) a fixed height, or
#' overrides the measured height of any block. Content is drawn top-aligned
#' in that height.
#'
#' @param x A block or anything [as_block()] accepts.
#' @param height `grid::unit` or inches.
#' @return A block.
#' @examples
#' bb_fixed(bb_spacer(), 0.5)
#' @export
bb_fixed <- function(x, height) {
  kid <- as_block(x)
  h <- .in(height, "height")
  new_block("fixed",
            measure = function(width) h,
            render = function(width, height) if (is.null(kid)) nullGrob() else .render(kid, width, height),
            full_bleed = isTRUE(kid$full_bleed))
}

#' Mark a block as full bleed
#'
#' A full-bleed block that sits directly in a [bb_page()] spans the whole page
#' width, ignoring the side margins (for a coloured band, say). Elsewhere the
#' flag has no effect.
#'
#' @param x A block or anything [as_block()] accepts.
#' @return The block, flagged.
#' @examples
#' bb_full_bleed(bb_box(NULL, box_style(fill = "primary", padding = 0.3)))
#' @export
bb_full_bleed <- function(x) {
  b <- as_block(x)
  b$full_bleed <- TRUE
  b
}

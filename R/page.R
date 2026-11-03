# Pages ----------------------------------------------------------------------------------

#' Page template
#'
#' Size, margins, header and footer shared by a set of pages. Header and
#' footer are blocks or `function(ctx)` returning a block, where `ctx` holds
#' `page`, `pages` and the page's `data`. Text in [bb_running_header()] and
#' [bb_page_footer()] can use `\{page\}` and `\{pages\}` directly.
#'
#' Layout of a page, top to bottom:
#' - `margin_top`, then the header and `header_gap`. A full-bleed header (a
#'   [bb_banner()]) sits flush with the top edge instead.
#' - the body, between the side margins (full-bleed body blocks span the
#'   page width).
#' - `footer_gap`, the footer, then `margin_bottom`. The footer is anchored
#'   to the bottom margin, so it is in the same place on every page.
#'
#' @param width,height Page size (`grid::unit` or inches). US Letter by
#'   default.
#' @param margin_x Side margins: one value, or left and right.
#' @param margin_top,margin_bottom Top and bottom margins.
#' @param header,footer Default header and footer (block, function, or
#'   `NULL`).
#' @param header_gap,footer_gap Space between header/footer and body.
#' @param theme Optional [bb_theme()] applied while these pages are exported.
#' @param background Page background colour, or `NA`.
#' @return A `bb_page_template` object.
#' @examples
#' tpl <- page_template(margin_x = 0.5,
#'                      footer = bb_page_footer("My report", "{page} / {pages}"))
#' @export
page_template <- function(width = 8.5, height = 11, margin_x = 0.5, margin_top = 0.5, margin_bottom = 0.5,
                          header = NULL, footer = NULL, header_gap = 0.2, footer_gap = 0.2,
                          theme = NULL, background = NA) {
  mx <- .trbl_in(margin_x, "margin_x")
  if (!length(margin_x) %in% c(1, 2)) stop("`margin_x` takes one value or two (left, right).", call. = FALSE)
  if (!is.null(theme) && !inherits(theme, "bb_theme")) stop("`theme` must come from bb_theme().", call. = FALSE)
  .check_chrome(header, "header"); .check_chrome(footer, "footer")
  structure(list(width = .in(width, "width"), height = .in(height, "height"),
                 margin_left = mx[4], margin_right = mx[2],
                 margin_top = .in(margin_top, "margin_top"), margin_bottom = .in(margin_bottom, "margin_bottom"),
                 header = header, footer = footer, header_gap = .in(header_gap, "header_gap"),
                 footer_gap = .in(footer_gap, "footer_gap"), theme = theme, background = background),
            class = "bb_page_template")
}

.check_chrome <- function(x, name) {
  if (is.null(x) || is.function(x)) return(invisible())
  invisible(as_block(x))
}

#' Page
#'
#' A page body is a vertical stack of blocks placed between the template's
#' header and footer. Nothing needs a hand-set height: each block measures
#' itself at the content width. Flexible blocks (plots without a height,
#' [bb_spacer()]) share whatever height is left.
#'
#' If the content is taller than the space between header and footer,
#' [export_pdf()] warns (or errors, with `overflow = "error"`) and says by
#' how much.
#'
#' @param ... Body blocks (or anything [as_block()] accepts), top to bottom.
#'   `NULL`s are dropped.
#' @param template A [page_template()]. Defaults to `page_template()`.
#' @param header,footer Override the template's header/footer for this page
#'   (block, `function(ctx)`, or `NULL` for none).
#' @param gap Space between body blocks, recycled.
#' @param data Named values for `\{name\}` tokens and for header/footer
#'   functions.
#' @param label Name used in overflow messages.
#' @param overflow `"warn"`, `"error"` or `"ignore"`.
#' @param .list Optional list of further body blocks.
#' @return A `bb_page` object.
#' @examples
#' pg <- bb_page(bb_section_header("Summary"), "Some text.", gap = 0.1)
#' @export
bb_page <- function(..., template = NULL, header, footer, gap = 0, data = list(), label = NULL,
                    overflow = c("warn", "error", "ignore"), .list = NULL) {
  template <- template %||% page_template()
  if (!inherits(template, "bb_page_template")) stop("`template` must come from page_template().", call. = FALSE)
  overflow <- match.arg(overflow)
  if (!missing(header)) .check_chrome(header, "header")
  if (!missing(footer)) .check_chrome(footer, "footer")
  kids <- Filter(Negate(is.null), .collect(list(...), .list))
  structure(list(blocks = kids, template = template,
                 header = if (missing(header)) template$header else header,
                 footer = if (missing(footer)) template$footer else footer,
                 gaps = if (length(kids) > 1) rep_len(.gap_vec(gap), length(kids) - 1) else numeric(),
                 data = data, label = label, overflow = overflow),
            class = "bb_page")
}

#' @export
print.bb_page <- function(x, ...) {
  cat("<bb_page> ", length(x$blocks), " body block(s), ", x$template$width, " x ", x$template$height, " in\n", sep = "")
  invisible(x)
}

#' Document
#'
#' An ordered set of pages exported to one PDF. `NULL` pages are dropped
#' before numbering, so an optional page (built only when there is data)
#' shifts the later page numbers and the total automatically.
#'
#' @param ... [bb_page()]s or `NULL`s.
#' @param .list Optional list of further pages.
#' @return A `bb_document` object.
#' @examples
#' doc <- bb_document(bb_page("One"), NULL, bb_page("Two"))
#' length(doc$pages)
#' @export
bb_document <- function(..., .list = NULL) {
  pages <- Filter(Negate(is.null), c(list(...), .list %||% list()))
  ok <- vapply(pages, inherits, logical(1), "bb_page")
  if (!all(ok)) stop("Every page must come from bb_page().", call. = FALSE)
  structure(list(pages = pages), class = "bb_document")
}

#' @export
print.bb_document <- function(x, ...) {
  cat("<bb_document> ", length(x$pages), " page(s)\n", sep = "")
  invisible(x)
}

#' @noRd
.chrome_block <- function(x, ctx) {
  if (is.null(x)) return(NULL)
  as_block(if (is.function(x)) x(ctx) else x)
}

#' Internal: build the grob for one page
#' @noRd
.page_grob <- function(page, ctx) {
  tpl <- page$template
  W <- tpl$width; H <- tpl$height
  ml <- tpl$margin_left; mr <- tpl$margin_right
  cw <- W - ml - mr
  old_ctx <- .bb_env$ctx
  .bb_env$ctx <- c(ctx, list(margin_left = ml, margin_right = mr, width = W, height = H))
  on.exit(.bb_env$ctx <- old_ctx, add = TRUE)
  ctx <- .bb_env$ctx

  span_of <- function(b) if (isTRUE(b$full_bleed)) c(0, W) else c(ml, cw)
  measure_fixed <- function(b) {
    s <- span_of(b)
    h <- .measure(b, s[2])
    if (is.na(h)) .min_height(b, s[2]) else h
  }

  kids <- gList()
  if (!is.na(tpl$background)) kids <- gList(kids, rectGrob(gp = gpar(fill = .col(tpl$background), col = NA)))

  hdr <- .chrome_block(page$header, ctx)
  body_top <- tpl$margin_top
  if (!is.null(hdr)) {
    hh <- measure_fixed(hdr)
    y0 <- if (isTRUE(hdr$full_bleed)) 0 else tpl$margin_top
    s <- span_of(hdr)
    kids <- gList(kids, .place_block(hdr, s[1], y0, s[2], hh))
    body_top <- y0 + hh + tpl$header_gap
  }

  ftr <- .chrome_block(page$footer, ctx)
  body_bottom <- H - tpl$margin_bottom
  if (!is.null(ftr)) {
    fh <- measure_fixed(ftr)
    ftop <- H - tpl$margin_bottom - fh
    s <- span_of(ftr)
    kids <- gList(kids, .place_block(ftr, s[1], ftop, s[2], fh))
    body_bottom <- ftop - tpl$footer_gap
  }

  blocks <- page$blocks
  if (length(blocks)) {
    avail <- body_bottom - body_top
    h <- vapply(blocks, function(b) .measure(b, span_of(b)[2]), numeric(1))
    flex <- is.na(h)
    fixed_total <- sum(h[!flex]) + sum(page$gaps)
    if (any(flex)) {
      mins <- vapply(blocks[flex], function(b) .min_height(b, span_of(b)[2]), numeric(1))
      h[flex] <- pmax(max(avail - fixed_total, 0) / sum(flex), mins)
    }
    used <- sum(h) + sum(page$gaps)
    over <- used - avail
    if (over > 1e-6 && page$overflow != "ignore") {
      msg <- sprintf("%s: content overflows the body by %.2f in.", page$label %||% paste("Page", ctx$page), over)
      if (page$overflow == "error") stop(msg, call. = FALSE) else warning(msg, call. = FALSE)
    }
    y <- body_top
    for (i in seq_along(blocks)) {
      s <- span_of(blocks[[i]])
      kids <- gList(kids, .place_block(blocks[[i]], s[1], y, s[2], h[i]))
      y <- y + h[i] + if (i < length(blocks)) page$gaps[i] else 0
    }
  }
  gTree(children = kids)
}

#' Page layout report
#'
#' Measures a page without exporting it: where the body starts and ends, how
#' tall the content is, and how much room is left (negative when it
#' overflows). Useful in tests and when tuning templates.
#'
#' @param page A [bb_page()].
#' @param page_number,pages Page number and total used for tokens.
#' @return A list with `body_top`, `body_bottom`, `available`, `used`,
#'   `free` (inches), and `footer_top`.
#' @examples
#' page_layout(bb_page("Hello"))$free
#' @export
page_layout <- function(page, page_number = 1, pages = 1) {
  if (!inherits(page, "bb_page")) stop("`page` must come from bb_page().", call. = FALSE)
  tpl <- page$template
  with_theme(tpl$theme, with_measure_device({
    old_ctx <- .bb_env$ctx
    .bb_env$ctx <- list(page = page_number, pages = pages, data = page$data,
                        margin_left = tpl$margin_left, margin_right = tpl$margin_right,
                        width = tpl$width, height = tpl$height)
    on.exit(.bb_env$ctx <- old_ctx, add = TRUE)
    ctx <- .bb_env$ctx
    W <- tpl$width; cw <- W - tpl$margin_left - tpl$margin_right
    wid <- function(b) if (isTRUE(b$full_bleed)) W else cw
    mh <- function(b) { h <- .measure(b, wid(b)); if (is.na(h)) .min_height(b, wid(b)) else h }
    hdr <- .chrome_block(page$header, ctx)
    body_top <- tpl$margin_top
    if (!is.null(hdr)) body_top <- (if (isTRUE(hdr$full_bleed)) 0 else tpl$margin_top) + mh(hdr) + tpl$header_gap
    ftr <- .chrome_block(page$footer, ctx)
    footer_top <- NA_real_
    body_bottom <- tpl$height - tpl$margin_bottom
    if (!is.null(ftr)) {
      footer_top <- tpl$height - tpl$margin_bottom - mh(ftr)
      body_bottom <- footer_top - tpl$footer_gap
    }
    used <- sum(vapply(page$blocks, mh, numeric(1))) + sum(page$gaps)
    list(body_top = body_top, body_bottom = body_bottom, available = body_bottom - body_top,
         used = used, free = body_bottom - body_top - used, footer_top = footer_top)
  }))
}

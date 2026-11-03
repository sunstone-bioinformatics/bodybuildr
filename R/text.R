# Text -----------------------------------------------------------------------------
# bb_text() renders with gridtext. Text always goes through gridtext's markdown
# mode: plain text is escaped first, because gridtext 0.1.6 with
# use_markdown = FALSE can break lines at every space. Inline spans and links
# travel inside the string as <bb-span>/<bb-link> tags, so they survive
# paste() and are resolved against the theme at draw time.

.tag_re <- "</?bb-(span|link)(\\s[^>]*)?>"

#' Inline text runs
#'
#' `span()` changes weight, colour, size, italics or family for part of a
#' string. `link()` marks a URL. Both return a string, so they can be
#' combined with `paste0()`, and both work in every [bb_text()] markup mode.
#'
#' Weights resolve like [text_style()] (semibold through the installed face).
#' Spans can't be nested.
#'
#' In plain text, links are drawn underlined, and each line of a link is a
#' single unbroken text run so PDF viewers detect the URL. The URL moves to a
#' new line whole when it fits there. Plain text that contains links can't
#' also contain spans. In markdown and HTML text, links are drawn in
#' `link_color` without an underline (gridtext can't underline).
#'
#' @param text Text of the run. For `link()`, the visible label (defaults to
#'   the URL).
#' @param weight,color,size,italic,family Overrides for this run. `size` is
#'   in points; `color` takes theme colour names.
#' @param url Link target.
#' @return A character string with class `bb_inline`.
#' @examples
#' bb_text(paste0("Coverage ", span("rose", weight = 700, color = "accent"), " in 2024."))
#' bb_text(paste0("Source: WHO/UNICEF, ", link("https://immunizationdata.who.int")))
#' @export
span <- function(text, weight = NULL, color = NULL, size = NULL, italic = NULL, family = NULL) {
  attrs <- c(
    w = if (!is.null(weight)) .weight_num(weight),
    c = color,
    s = if (!is.null(size)) as.character(size),
    i = if (!is.null(italic)) as.integer(isTRUE(italic)),
    f = family
  )
  a <- if (length(attrs)) paste0(" ", names(attrs), "=\"", gsub("\"", "&quot;", attrs), "\"", collapse = "") else ""
  structure(paste0("<bb-span", a, ">", text, "</bb-span>"), class = c("bb_inline", "character"))
}

#' @rdname span
#' @export
link <- function(url, text = url) {
  if (!is.character(url) || length(url) != 1 || is.na(url)) stop("`url` must be one string.", call. = FALSE)
  structure(paste0("<bb-link href=\"", gsub("\"", "&quot;", url), "\">", text, "</bb-link>"),
            class = c("bb_inline", "character"))
}

#' Internal: escape markdown/HTML so gridtext prints text literally
#' @noRd
.escape_md <- function(x) {
  x <- gsub("&(?!#?[A-Za-z0-9]+;)", "&amp;", x, perl = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub("([\\\\`*_\\[\\]#|~])", "\\\\\\1", x, perl = TRUE)
  gsub("(^|\n)(\\s*)([0-9]+)\\.", "\\1\\2\\3\\\\.", x, perl = TRUE)
}

#' Internal: split text around bb tags (parts has one more entry than tags)
#' @noRd
.protect_tags <- function(x) {
  m <- gregexpr(.tag_re, x, perl = TRUE)
  list(parts = regmatches(x, m, invert = TRUE)[[1]], tags = regmatches(x, m)[[1]])
}

.restore_tags <- function(parts, tags) {
  if (!length(tags)) return(paste(parts, collapse = ""))
  paste0(c(rbind(parts[seq_along(tags)], tags), parts[length(tags) + 1]), collapse = "")
}

#' @noRd
.apply_case <- function(x, case) {
  switch(case %||% "none",
    upper = toupper(x),
    lower = tolower(x),
    title = gsub("(^|\\s)(\\p{Ll})", "\\1\\U\\2", x, perl = TRUE),
    x)
}

#' Internal: convert Markdown to gridtext-compatible HTML
#' @noRd
.md_to_html <- function(md) {
  if (!requireNamespace("commonmark", quietly = TRUE)) {
    warning("Package 'commonmark' is needed for Markdown text; showing it as plain text.", call. = FALSE)
    return(.escape_md(md))
  }
  html <- paste(commonmark::markdown_html(md, smart = TRUE), collapse = "")
  html <- gsub("<h[1-6][^>]*>(.*?)</h[1-6]>", "<b>\\1</b><br/>", html)
  html <- gsub("<li><p>", "<li>", html)
  html <- gsub("</p></li>", "</li>", html)
  html <- gsub("<li>", "&#x2022; ", html)
  html <- gsub("</li>\n?", "<br/>", html)
  html <- gsub("</?[uo]l>\n?", "", html)
  html <- gsub("<a href=\"([^\"]*)\">(.*?)</a>", "<bb-link href=\"\\1\">\\2</bb-link>", html)
  html <- gsub("<pre><code[^>]*>", "", html)
  html <- gsub("</code></pre>", "", html)
  html <- gsub("</?code>", "", html)
  html <- gsub("<hr[^>]*/?>", "<br/>", html)
  html <- gsub("</p>\n?", "<br/><br/>", html)
  html <- gsub("<p>\n?", "", html)
  html <- gsub("(<br/>\\s*)+$", "", trimws(html))
  # commonmark escapes characters gridtext's own markdown pass would read again
  html <- gsub("([\\\\`*_\\[\\]])", "\\\\\\1", html, perl = TRUE)
  trimws(html)
}

#' Internal: parse attributes of a bb tag
#' @noRd
.tag_attrs <- function(tag) {
  m <- regmatches(tag, gregexpr("([a-z]+)=\"([^\"]*)\"", tag))[[1]]
  if (!length(m)) return(list())
  keys <- sub("=.*$", "", m)
  vals <- gsub("&quot;", "\"", sub("^[a-z]+=\"(.*)\"$", "\\1", m))
  stats::setNames(as.list(vals), keys)
}

#' Internal: <bb-span>/<bb-link> -> gridtext HTML, resolved against the theme
#' @noRd
.resolve_inline <- function(html, rs, link_color) {
  span_re <- "<bb-span(\\s[^>]*)?>(.*?)</bb-span>"
  repeat {
    m <- regexpr(span_re, html, perl = TRUE)
    if (m < 0) break
    whole <- regmatches(html, m)
    open_tag <- sub("^(<bb-span[^>]*>).*$", "\\1", whole)
    inner <- sub("^<bb-span[^>]*>(.*)</bb-span>$", "\\1", whole)
    a <- .tag_attrs(open_tag)
    s <- rs
    if (!is.null(a$w)) s$weight <- as.numeric(a$w)
    if (!is.null(a$c)) s$color <- a$c
    if (!is.null(a$s)) s$size <- as.numeric(a$s)
    if (!is.null(a$i)) s$italic <- a$i == "1"
    if (!is.null(a$f)) s$family <- a$f
    font <- .resolve_font(s$family, s$weight, isTRUE(s$italic))
    # gridtext only resolves multi-word family names when they are quoted.
    css <- paste0("font-family:'", gsub("'", "", font$family), "';")
    if (!is.null(a$c)) css <- paste0(css, "color:", .col(a$c), ";")
    if (!is.null(a$s)) css <- paste0(css, "font-size:", a$s, "pt;")
    bold <- font$face %in% c("bold", "bold.italic")
    ital <- font$face %in% c("italic", "bold.italic")
    rep_html <- paste0("<span style=\"", css, "\">", if (bold) "<b>", if (ital) "<i>", inner,
                       if (ital) "</i>", if (bold) "</b>", "</span>")
    regmatches(html, m) <- rep_html
  }
  lc <- .col(link_color %||% rs$color)
  html <- gsub("<bb-link[^>]*>(.*?)</bb-link>", paste0("<span style='color:", lc, ";'>\\1</span>"),
               html, perl = TRUE)
  html
}

#' Internal: build gridtext HTML from text + markup mode
#' @noRd
.prepare_html <- function(x, markup, rs, link_color = NULL) {
  p <- .protect_tags(x)
  parts <- .apply_case(p$parts, rs$case)
  if (markup == "plain") parts <- gsub("\n", "<br>", .escape_md(parts), fixed = TRUE)
  txt <- .restore_tags(parts, p$tags)
  if (markup == "markdown") txt <- .md_to_html(txt)
  .defuse_autolinks(.resolve_inline(txt, rs, link_color))
}

#' Internal: stop gridtext's markdown pass from autolinking URLs and emails
#'
#' gridtext turns "https://...", "www." and "a@b.org" into <a> tags, which it
#' then can't draw. Escaping the trigger characters in text (never inside
#' tags) keeps them literal.
#' @noRd
.defuse_autolinks <- function(html) {
  m <- gregexpr("<[^>]*>", html)
  text <- regmatches(html, m, invert = TRUE)[[1]]
  tags <- regmatches(html, m)[[1]]
  text <- gsub("://", "\\\\://", text, fixed = FALSE)
  text <- gsub("(?i)\\b(www)\\.", "\\1\\\\.", text, perl = TRUE)
  text <- gsub("@", "<span>@</span>", text, fixed = TRUE)
  .restore_tags(text, tags)
}

#' Internal: gridtext textbox anchored top-left
#' @noRd
.textbox <- function(html, width, gp, halign = 0, x = unit(0, "npc"), y = unit(1, "npc"),
                     hjust = 0, vjust = 1, padding = c(0, 0, 0, 0), fill = NA) {
  gridtext::textbox_grob(
    html, x = x, y = y, hjust = hjust, vjust = vjust, halign = halign,
    width = unit(max(width, 0.01), "in"),
    padding = unit(padding, "in"), margin = unit(c(0, 0, 0, 0), "in"),
    r = unit(0, "pt"), box_gp = gpar(col = NA, fill = fill),
    gp = gp, use_markdown = TRUE
  )
}

.halign <- function(align) switch(align, right = 1, center = 0.5, 0)

#' Text block
#'
#' Wrapped text that is exactly as tall as its content at the width it is
#' given.
#'
#' - `markup = "plain"` (default) prints the text literally: characters such
#'   as `<80%`, `*` or `[1]` are escaped. `"\n"` breaks the line. [span()] and
#'   [link()] runs are kept.
#' - `markup = "markdown"` reads Markdown: bold, italic, lists, headings,
#'   links.
#' - `markup = "html"` passes the gridtext HTML subset (`<b>`, `<i>`,
#'   `<span style>`, `<br>`, `<sup>`, `<sub>`).
#'
#' A character vector is pasted together without separators, so
#' `c("Total: ", span("4", weight = 600))` reads as one line.
#'
#' @param x Text (character vector, pasted together).
#' @param style A [text_style()], a theme role name, or `NULL` for `"body"`.
#' @param markup `"plain"`, `"markdown"` or `"html"`.
#' @param align Horizontal alignment: `"left"`, `"center"` or `"right"`.
#' @param link_color Colour of links; defaults to the text colour.
#' @return A block.
#' @examples
#' bb_text("Values below <80% are flagged.")
#' bb_text("**Bold** and *italic*", markup = "markdown", style = "note")
#' @export
bb_text <- function(x, style = NULL, markup = c("plain", "markdown", "html"),
                    align = c("left", "center", "right"), link_color = NULL) {
  markup <- match.arg(markup)
  align <- match.arg(align)
  .text_block(x, style, "body", markup, align, link_color)
}

#' @noRd
.text_block <- function(x, style, role, markup = "plain", align = "left", link_color = NULL) {
  force(style); force(role); force(markup); force(align); force(link_color)
  if (is.null(x) || !length(x)) x <- ""
  x <- paste(ifelse(is.na(x), "", as.character(x)), collapse = "")
  has_link <- grepl("<bb-link", x, fixed = TRUE)
  use_runs <- markup == "plain" && has_link
  if (use_runs && grepl("<bb-span", x, fixed = TRUE)) {
    stop("Plain text with link() can't also contain span().", call. = FALSE)
  }
  empty <- !nzchar(trimws(gsub(.tag_re, "", x, perl = TRUE)))

  build <- function(width) {
    rs <- .resolve_text_style(style, role)
    gp <- .as_gpar(rs)
    if (use_runs) return(list(runs = .link_layout(x, width, rs, gp, align, link_color)))
    html <- .prepare_html(x, markup, rs, link_color)
    list(html = html, gp = gp)
  }

  new_block(
    "text",
    measure = function(width) {
      if (empty) return(0)
      b <- build(width)
      if (!is.null(b$runs)) return(b$runs$height)
      .grob_h_in(.textbox(b$html, width, b$gp, .halign(align)))
    },
    render = function(width, height) {
      if (empty) return(nullGrob())
      b <- build(width)
      if (!is.null(b$runs)) return(b$runs$grob)
      .textbox(b$html, width, b$gp, .halign(align))
    },
    text = x, markup = markup
  )
}

# Link runs ----------------------------------------------------------------------
# A small line breaker for plain text with underlined links: gridtext ignores
# text-decoration, and viewers only detect a URL that is one text run.

#' @noRd
.link_tokens <- function(x, case) {
  pieces <- list()
  rest <- x
  re <- "<bb-link\\s[^>]*>(.*?)</bb-link>"
  repeat {
    m <- regexpr(re, rest, perl = TRUE)
    if (m < 0) {
      if (nzchar(rest)) pieces[[length(pieces) + 1]] <- list(text = rest, link = FALSE)
      break
    }
    if (m > 1) pieces[[length(pieces) + 1]] <- list(text = substr(rest, 1, m - 1), link = FALSE)
    whole <- regmatches(rest, m)
    href <- .tag_attrs(sub("^(<bb-link[^>]*>).*$", "\\1", whole))$href
    label <- sub("^<bb-link[^>]*>(.*)</bb-link>$", "\\1", whole)
    pieces[[length(pieces) + 1]] <- list(text = label, link = TRUE, href = href)
    rest <- substr(rest, m + attr(m, "match.length"), nchar(rest))
  }

  tok <- list(); pending_space <- FALSE; group <- 0L
  add <- function(txt, link, space, grp, brk = FALSE) {
    tok[[length(tok) + 1]] <<- list(txt = txt, link = link, space = space, group = grp, brk = brk)
  }
  for (p in pieces) {
    if (!p$link) {
      bits <- regmatches(p$text, gregexpr("\n|[ \t]+|[^ \t\n]+", p$text))[[1]]
      for (b in bits) {
        if (b == "\n") { add("", FALSE, FALSE, 0L, brk = TRUE); pending_space <- FALSE }
        else if (grepl("^[ \t]+$", b)) pending_space <- TRUE
        else { add(.apply_case(b, case), FALSE, pending_space, 0L); pending_space <- FALSE }
      }
    } else {
      group <- group + 1L
      label <- p$text
      segs <- if (identical(label, p$href)) {
        regmatches(label, gregexpr("[^/]*/+|[^/]+$", label))[[1]]
      } else {
        strsplit(trimws(label), "\\s+")[[1]]
      }
      sep_space <- !identical(label, p$href)
      for (k in seq_along(segs)) {
        add(segs[k], TRUE, if (k == 1) pending_space else sep_space, group)
      }
      pending_space <- FALSE
    }
  }
  tok
}

#' @noRd
.link_layout <- function(x, width, rs, gp, align, link_color) {
  tok <- .link_tokens(x, rs$case)
  n <- length(tok)
  lh <- .line_h_in(rs)
  if (!n) return(list(height = 0, grob = nullGrob()))
  txt <- vapply(tok, `[[`, character(1), "txt")
  w <- numeric(n)
  real <- nzchar(txt)
  w[real] <- .text_w_in(txt[real], gp)
  space_w <- with_measure_device(
    convertWidth(grobWidth(textGrob("a a", gp = gp)) - grobWidth(textGrob("aa", gp = gp)), "in", valueOnly = TRUE)
  )
  grp <- vapply(tok, `[[`, integer(1), "group")
  group_w <- tapply(w, grp, sum)

  line <- 1L; xpos <- 0
  tline <- integer(n); tx <- numeric(n)
  for (i in seq_len(n)) {
    if (tok[[i]]$brk) { line <- line + 1L; xpos <- 0; tline[i] <- line; next }
    gap <- if (tok[[i]]$space && xpos > 0) space_w else 0
    first_of_group <- grp[i] > 0 && (i == 1 || grp[i - 1] != grp[i])
    need <- if (first_of_group && group_w[[as.character(grp[i])]] <= width) group_w[[as.character(grp[i])]] else w[i]
    if (xpos > 0 && xpos + gap + need > width + 1e-9) { line <- line + 1L; xpos <- 0; gap <- 0 }
    tline[i] <- line; tx[i] <- xpos + gap
    xpos <- xpos + gap + w[i]
  }
  n_lines <- line
  height <- (n_lines - 1) * lh + rs$size * 1.15 / 72

  is_link <- vapply(tok, `[[`, logical(1), "link")
  keep <- !vapply(tok, `[[`, logical(1), "brk")
  run <- cumsum(c(TRUE, diff(tline) != 0 | diff(is_link) != 0 | diff(grp) != 0))
  line_end <- tapply(ifelse(keep, tx + w, 0), tline, max)
  offset <- function(l) {
    free <- width - line_end[[as.character(l)]]
    switch(align, right = free, center = free / 2, 0)
  }
  ascent <- rs$size * 0.64 / 72
  lc <- .col(link_color %||% rs$color)
  kids <- gList()
  for (r in unique(run[keep])) {
    idx <- which(run == r & keep)
    if (!length(idx)) next
    label <- paste0(ifelse(seq_along(idx) > 1 & vapply(tok[idx], `[[`, logical(1), "space"), " ", ""),
                    txt[idx], collapse = "")
    l <- tline[idx[1]]
    x0 <- tx[idx[1]] + offset(l)
    base_y <- unit(1, "npc") - unit((l - 1) * lh + ascent, "in")
    run_gp <- gp
    if (is_link[idx[1]]) run_gp$col <- lc
    kids <- gList(kids, textGrob(label, x = unit(x0, "in"), y = base_y, just = c("left", "bottom"), gp = run_gp))
    if (is_link[idx[1]]) {
      x1 <- tx[idx[length(idx)]] + w[idx[length(idx)]] + offset(l)
      uy <- base_y - unit(rs$size * 0.12 / 72, "in")
      kids <- gList(kids, segmentsGrob(unit(x0, "in"), uy, unit(x1, "in"), uy,
                                       gp = gpar(col = lc, lwd = max(0.5, rs$size / 15), lineend = "butt")))
    }
  }
  list(height = height, grob = gTree(children = kids), lines = n_lines)
}

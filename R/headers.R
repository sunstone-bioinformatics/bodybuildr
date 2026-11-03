# Headers, banners, footers ---------------------------------------------------------------

#' Internal: replace {page}, {pages} and {<data name>} with the page context
#' @noRd
.fill_tokens <- function(x, ctx = .bb_env$ctx) {
  if (is.null(x) || is.null(ctx)) return(x)
  vals <- c(list(page = ctx$page, pages = ctx$pages), ctx$data %||% list())
  for (nm in names(vals)) {
    v <- vals[[nm]]
    if (length(v) == 1 && (is.character(v) || is.numeric(v))) {
      x <- gsub(paste0("{", nm, "}"), as.character(v), x, fixed = TRUE)
    }
  }
  x
}

#' @noRd
.single_line <- function(label, style, role) {
  rs <- .resolve_text_style(style, role)
  label <- .apply_case(label, rs$case)
  list(label = label, rs = rs, gp = .as_gpar(rs), h = .line_h_in(rs))
}

#' Section header
#'
#' A small accent marker, the section title, optional muted references such
#' as "[1][2]", and a rule underneath. No filled band.
#'
#' @param title Section title (one line).
#' @param refs Optional references printed after the title.
#' @param style A [section_header_style()].
#' @return A block.
#' @examples
#' bb_section_header("Vaccination coverage", refs = "[3]")
#' @export
bb_section_header <- function(title, refs = NULL, style = section_header_style()) {
  if (!inherits(style, "bb_section_header_style")) stop("`style` must be a section_header_style().", call. = FALSE)
  has_refs <- !is.null(refs) && length(refs) == 1 && !is.na(refs) && nzchar(refs)
  rule_h <- function() if (.has_line(style$rule)) style$rule$lwd / 96 else 0
  new_block("section_header",
    measure = function(width) {
      t <- .single_line(title, style$title_style, "section")
      style$space_above + max(t$h, style$marker_height) + style$rule_gap + rule_h() + style$space_below
    },
    render = function(width, height) {
      t <- .single_line(title, style$title_style, "section")
      line_h <- max(t$h, style$marker_height)
      yc <- unit(1, "npc") - unit(style$space_above + line_h / 2, "in")
      kids <- gList()
      x <- 0
      if (style$marker_width > 0 && !is.na(style$marker_color)) {
        kids <- gList(kids, rectGrob(unit(0, "in"), yc, unit(style$marker_width, "in"),
                                     unit(style$marker_height, "in"), just = c("left", "center"),
                                     gp = gpar(fill = .col(style$marker_color), col = NA)))
        x <- style$marker_width + style$marker_gap
      }
      tg <- textGrob(t$label, x = unit(x, "in"), y = yc, just = c("left", "center"), gp = t$gp)
      kids <- gList(kids, tg)
      if (has_refs) {
        r <- .single_line(refs, style$refs_style, "refs")
        kids <- gList(kids, textGrob(r$label, x = unit(x + .grob_w_in(tg) + style$refs_gap, "in"), y = yc,
                                     just = c("left", "center"), gp = r$gp))
      }
      if (.has_line(style$rule)) {
        ry <- unit(1, "npc") - unit(style$space_above + line_h + style$rule_gap + rule_h() / 2, "in")
        kids <- gList(kids, segmentsGrob(unit(0, "in"), ry, unit(width, "in"), ry, gp = .line_gp(style$rule)))
      }
      gTree(children = kids)
    })
}

#' Section header style
#'
#' @param title_style,refs_style Text styles (or role names) for the title
#'   and references. Default roles `section` and `refs`.
#' @param marker_color Colour of the marker before the title (theme names
#'   allowed); `NA` for none.
#' @param marker_width,marker_height Marker size.
#' @param marker_gap Space between marker and title.
#' @param refs_gap Space between title and references.
#' @param rule A [line_style()] for the rule under the title, or `NULL`.
#' @param space_above Space above the title line.
#' @param rule_gap Space between the title line and the rule.
#' @param space_below Space below the rule.
#' @return A `bb_section_header_style` object.
#' @examples
#' section_header_style(marker_color = NA, rule = line_style("primary", 1))
#' @export
section_header_style <- function(title_style = NULL, refs_style = NULL, marker_color = "accent",
                                 marker_width = 4 / 96, marker_height = 16 / 96, marker_gap = 10 / 96,
                                 refs_gap = 8 / 96, rule = line_style("primary", 0.75),
                                 space_above = 0.065, rule_gap = 0.0875, space_below = 0.08) {
  structure(list(title_style = title_style, refs_style = refs_style, marker_color = marker_color,
                 marker_width = .in(marker_width, "marker_width"),
                 marker_height = .in(marker_height, "marker_height"),
                 marker_gap = .in(marker_gap, "marker_gap"), refs_gap = .in(refs_gap, "refs_gap"),
                 rule = .as_line_style(rule, "rule"), space_above = .in(space_above, "space_above"),
                 rule_gap = .in(rule_gap, "rule_gap"), space_below = .in(space_below, "space_below")),
            class = "bb_section_header_style")
}

#' Banner
#'
#' A full-bleed coloured band with logos on the left, an optional thin
#' divider, a title and a subtitle, and an optional accent strip underneath.
#' Place it as the first block of a page (or as the page header), where it
#' spans the whole page width.
#'
#' @param title Title text.
#' @param subtitle Optional subtitle text.
#' @param logo `NULL`, or one logo or a list of logos placed side by side.
#'   Each logo is a png/jpg path, a numeric array/raster, or a grob (a grob
#'   uses its `"width_in"` attribute, else it is drawn square).
#' @param style A [banner_style()].
#' @return A full-bleed block.
#' @examples
#' bb_banner("Immunization Profile", "Argentina, 2025")
#' @export
bb_banner <- function(title, subtitle = NULL, logo = NULL, style = banner_style()) {
  if (!inherits(style, "bb_banner_style")) stop("`style` must be a banner_style().", call. = FALSE)
  logos <- if (is.null(logo)) list() else if (is.list(logo) && !inherits(logo, "grob")) logo else list(logo)
  logos <- lapply(logos, function(l) if (inherits(l, "grob")) l else .read_image(l))
  lh <- style$logo_height
  logo_w <- vapply(logos, function(l) {
    if (inherits(l, "grob")) (attr(l, "width_in") %||% lh) else lh * .img_aspect(l)
  }, numeric(1))
  has_sub <- !is.null(subtitle) && length(subtitle) == 1 && !is.na(subtitle) && nzchar(subtitle)
  accent_h <- if (!is.null(style$accent_height) && !is.na(style$accent_color)) style$accent_height else 0

  new_block("banner",
    measure = function(width) style$height + accent_h,
    render = function(width, height) {
      band <- style$height
      pad <- style$padding_x %||% .bb_env$ctx$margin_left %||% 0.5
      mid <- unit(1, "npc") - unit(band / 2, "in")
      kids <- gList(.place(.shape_grob(style$fill, width, band), 0, 0, width, band))
      if (accent_h > 0) {
        kids <- gList(kids, rectGrob(0, unit(1, "npc") - unit(band, "in"), unit(1, "npc"), unit(accent_h, "in"),
                                     just = c("left", "top"), gp = gpar(fill = .col(style$accent_color), col = NA)))
      }
      x <- pad
      for (i in seq_along(logos)) {
        l <- logos[[i]]
        g <- if (inherits(l, "grob")) l else rasterGrob(l, interpolate = TRUE)
        kids <- gList(kids, .place(g, x, band / 2 - lh / 2, logo_w[i], lh))
        x <- x + logo_w[i] + if (i < length(logos)) style$logo_gap else 0
      }
      text_x <- pad
      if (length(logos)) {
        div_x <- x + style$text_gap
        if (.has_line(style$divider)) {
          dh <- style$divider_height / 2
          kids <- gList(kids, segmentsGrob(unit(div_x, "in"), mid - unit(dh, "in"), unit(div_x, "in"),
                                           mid + unit(dh, "in"), gp = .line_gp(style$divider)))
        }
        text_x <- div_x + style$text_gap
      }
      t <- .single_line(title, style$title_style, "title")
      blk <- t$h
      if (has_sub) {
        s <- .single_line(subtitle, style$subtitle_style, "subtitle")
        blk <- blk + style$title_gap + s$h
      }
      top <- band / 2 - blk / 2
      kids <- gList(kids, textGrob(t$label, x = unit(text_x, "in"), y = unit(1, "npc") - unit(top + t$h / 2, "in"),
                                   just = c("left", "center"), gp = t$gp))
      if (has_sub) {
        kids <- gList(kids, textGrob(s$label, x = unit(text_x, "in"),
                                     y = unit(1, "npc") - unit(top + t$h + style$title_gap + s$h / 2, "in"),
                                     just = c("left", "center"), gp = s$gp))
      }
      gTree(children = kids)
    },
    full_bleed = style$full_bleed)
}

#' Banner style
#'
#' @param fill Band fill (colour, theme name, [gradient_fill()] ...).
#' @param height Band height (without the accent strip).
#' @param padding_x Left inset of the logos/text. `NULL` uses the page's left
#'   margin.
#' @param logo_height Height of the logos.
#' @param logo_gap Space between logos.
#' @param divider A [line_style()] for the vertical divider after the logos,
#'   or `NULL`.
#' @param divider_height Divider length.
#' @param text_gap Space on each side of the divider.
#' @param title_style,subtitle_style Text styles (or role names); default
#'   roles `title` and `subtitle`.
#' @param title_gap Space between title and subtitle.
#' @param accent_color,accent_height Strip under the band; `accent_color = NA`
#'   for none.
#' @param full_bleed Span the full page width.
#' @return A `bb_banner_style` object.
#' @examples
#' banner_style(fill = "primary", logo_height = unit(36, "pt"))
#' @export
banner_style <- function(fill = "primary", height = 1.12, padding_x = NULL, logo_height = 32 / 96,
                         logo_gap = 10 / 96, divider = line_style("white", 1, alpha = 0.3),
                         divider_height = 0.6, text_gap = 30 / 96, title_style = NULL,
                         subtitle_style = NULL, title_gap = 0.12, accent_color = "accent",
                         accent_height = 4 / 96, full_bleed = TRUE) {
  .check_fill(fill)
  structure(list(fill = fill, height = .in(height, "height"),
                 padding_x = .in(padding_x, "padding_x", allow_null = TRUE),
                 logo_height = .in(logo_height, "logo_height"), logo_gap = .in(logo_gap, "logo_gap"),
                 divider = .as_line_style(divider, "divider"),
                 divider_height = .in(divider_height, "divider_height"),
                 text_gap = .in(text_gap, "text_gap"), title_style = title_style,
                 subtitle_style = subtitle_style, title_gap = .in(title_gap, "title_gap"),
                 accent_color = accent_color, accent_height = .in(accent_height, "accent_height"),
                 full_bleed = isTRUE(full_bleed)),
            class = "bb_banner_style")
}

#' Running header and page footer
#'
#' One line with text on the left and on the right, and a rule: under the
#' text for `bb_running_header()`, above it for `bb_page_footer()`. Both
#' replace `\{page\}`, `\{pages\}` and `\{<name>\}` (from the page's `data`) when
#' the page is exported, so one template serves every page.
#'
#' @param left,right Text (either may be `NULL`).
#' @param style A [header_line_style()].
#' @return A block.
#' @examples
#' bb_running_header("Immunization Profile", "Argentina, 2025")
#' bb_page_footer("PAHO, 2026", "Argentina · {page} / {pages}")
#' @export
bb_running_header <- function(left, right = NULL, style = header_line_style()) {
  .header_line(left, right, style, rule_above = FALSE)
}

#' @rdname bb_running_header
#' @export
bb_page_footer <- function(left, right = NULL, style = footer_line_style()) {
  .header_line(left, right, style, rule_above = TRUE)
}

#' @noRd
.header_line <- function(left, right, style, rule_above) {
  if (!inherits(style, "bb_header_line_style")) stop("`style` must be a header_line_style().", call. = FALSE)
  rule_h <- function() if (.has_line(style$rule)) style$rule$lwd / 96 else 0
  lines <- function() {
    l <- .single_line(.fill_tokens(left %||% ""), style$left_style, style$left_role)
    r <- .single_line(.fill_tokens(right %||% ""), style$right_style, style$right_role)
    list(l = l, r = r, h = max(l$h, r$h))
  }
  new_block(if (rule_above) "page_footer" else "running_header",
    measure = function(width) {
      style$space_above + lines()$h + style$rule_gap + rule_h() + style$space_below
    },
    render = function(width, height) {
      ln <- lines()
      text_top <- style$space_above + if (rule_above) rule_h() + style$rule_gap else 0
      yc <- unit(1, "npc") - unit(text_top + ln$h / 2, "in")
      rule_y <- if (rule_above) style$space_above + rule_h() / 2 else style$space_above + ln$h + style$rule_gap + rule_h() / 2
      kids <- gList()
      if (nzchar(ln$l$label)) kids <- gList(kids, textGrob(ln$l$label, 0, yc, just = c("left", "center"), gp = ln$l$gp))
      if (nzchar(ln$r$label)) kids <- gList(kids, textGrob(ln$r$label, unit(width, "in"), yc, just = c("right", "center"), gp = ln$r$gp))
      if (.has_line(style$rule)) {
        ry <- unit(1, "npc") - unit(rule_y, "in")
        kids <- gList(kids, segmentsGrob(unit(0, "in"), ry, unit(width, "in"), ry, gp = .line_gp(style$rule)))
      }
      gTree(children = kids)
    })
}

#' Header and footer line styles
#'
#' Styles for [bb_running_header()] (`header_line_style()`) and
#' [bb_page_footer()] (`footer_line_style()`).
#'
#' @param left_style,right_style Text styles (or role names). Defaults:
#'   roles `running` / `running_right` for headers, `footer` for footers.
#' @param rule A [line_style()] or `NULL`.
#' @param space_above,rule_gap,space_below Vertical spacing.
#' @return A `bb_header_line_style` object.
#' @examples
#' header_line_style(rule = line_style("primary", 2))
#' @export
header_line_style <- function(left_style = NULL, right_style = NULL, rule = line_style("primary", 2),
                              space_above = 0, rule_gap = 0.1, space_below = 0.07) {
  .hl_style(left_style, right_style, "running", "running_right", rule, space_above, rule_gap, space_below)
}

#' @rdname header_line_style
#' @export
footer_line_style <- function(left_style = NULL, right_style = NULL, rule = line_style("rule_strong", 1),
                              space_above = 0, rule_gap = 0.16, space_below = 0.1) {
  .hl_style(left_style, right_style, "footer", "footer", rule, space_above, rule_gap, space_below)
}

.hl_style <- function(ls, rs, lrole, rrole, rule, sa, rg, sb) {
  structure(list(left_style = ls, right_style = rs, left_role = lrole, right_role = rrole,
                 rule = .as_line_style(rule, "rule"), space_above = .in(sa, "space_above"),
                 rule_gap = .in(rg, "rule_gap"), space_below = .in(sb, "space_below")),
            class = "bb_header_line_style")
}

#' Placeholder panel
#'
#' A patterned panel (diagonal stripes by default) with a centred sentence,
#' for content a data source doesn't provide. Flexible by default, so it
#' takes the height of its siblings in [bb_cols()].
#'
#' @param text Sentence shown on the panel.
#' @param fill Panel fill: [stripe_fill()], a colour, or [gradient_fill()].
#' @param height `grid::unit`, inches, or `NULL` for flexible.
#' @param style Text style (or role name); default role `placeholder`.
#' @param label_fill Fill behind the sentence (theme names allowed); `NA` for
#'   none.
#' @param label_width Width of the sentence box as a fraction of the panel.
#' @param label_padding Padding around the sentence.
#' @return A block.
#' @examples
#' bb_placeholder("This country does not report subnational data.", height = 2)
#' @export
bb_placeholder <- function(text, fill = stripe_fill(), height = NULL, style = NULL,
                           label_fill = "panel", label_width = 0.8,
                           label_padding = unit(c(6, 10, 6, 10), "pt")) {
  .check_fill(fill)
  h <- .in(height, "height", allow_null = TRUE)
  pad <- .trbl_in(label_padding, "label_padding")
  label <- function(width) {
    rs <- .resolve_text_style(style, "placeholder")
    html <- .prepare_html(text, "plain", rs)
    .textbox(html, width * label_width, .as_gpar(rs), halign = 0.5, x = unit(0.5, "npc"), y = unit(0.5, "npc"),
             hjust = 0.5, vjust = 0.5, padding = pad, fill = .col(label_fill))
  }
  new_block("placeholder",
    measure = function(width) if (is.null(h)) NA_real_ else h,
    min_height = function(width) .grob_h_in(label(width)),
    render = function(width, height) {
      gTree(children = gList(.shape_grob(fill, width, height), label(width)))
    })
}

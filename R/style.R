# Style constructors ---------------------------------------------------------------

.weight_names <- c(thin = 100, extralight = 200, ultralight = 200, light = 300,
                   normal = 400, regular = 400, plain = 400, book = 400, medium = 500,
                   semibold = 600, demibold = 600, bold = 700, extrabold = 800,
                   ultrabold = 800, black = 900, heavy = 900)

.weight_num <- function(w) {
  if (is.numeric(w)) return(as.numeric(w))
  key <- gsub("[^a-z]", "", tolower(as.character(w)))
  out <- unname(.weight_names[key])
  if (anyNA(out)) stop("Unknown font weight: ", paste(w[is.na(out)], collapse = ", "), call. = FALSE)
  out
}

#' Define a text style
#'
#' A text style lists only the properties it changes. Anything left `NULL` is
#' inherited from `base` (a theme role name or another text style), or from
#' the role the component uses by default. So `text_style(weight = 600)`
#' passed to [bb_text()] means "body text, semibold", and the same style
#' passed as a table header style means "table header, semibold".
#'
#' **Weights.** `weight` takes a number (100-900) or a name such as
#' `"semibold"`. 400 and 700 use the family's regular and bold faces. Other
#' weights are looked up with systemfonts: if a face with that weight is
#' installed (for example "Source Sans 3 Semibold"), its family name is used,
#' which `cairo_pdf()` resolves through fontconfig. Otherwise bodybuildr falls
#' back to bold (600 and above) or regular, with a one-time message.
#'
#' @param base A theme role name (e.g. `"note"`) or another `text_style()` to
#'   inherit from.
#' @param size Font size in points.
#' @param weight Font weight, numeric (100-900) or a name (`"regular"`,
#'   `"semibold"`, `"bold"`, ...).
#' @param color Text colour: an R colour or a theme colour name.
#' @param family Font family.
#' @param italic `TRUE` for italic.
#' @param lineheight Line height as a multiple of the font size.
#' @param case Letter case applied to plain text: `"none"`, `"upper"`,
#'   `"lower"` or `"title"`.
#' @return A `bb_text_style` object.
#' @examples
#' text_style(size = 12, weight = "semibold", color = "muted")
#' text_style("note", italic = TRUE)
#' @export
text_style <- function(base = NULL, size = NULL, weight = NULL, color = NULL, family = NULL,
                       italic = NULL, lineheight = NULL, case = NULL) {
  if (!is.null(base) && !(is.character(base) && length(base) == 1) && !inherits(base, "bb_text_style")) {
    stop("`base` must be a theme role name or a text_style().", call. = FALSE)
  }
  if (!is.null(size) && (!is.numeric(size) || length(size) != 1 || is.na(size) || size < 0)) {
    stop("`size` must be length-1, non-negative.", call. = FALSE)
  }
  if (!is.null(weight)) {
    if (length(weight) != 1) stop("`weight` must be length 1.", call. = FALSE)
    weight <- .weight_num(weight)
    if (is.na(weight) || weight < 1 || weight > 1000) stop("`weight` must be between 1 and 1000.", call. = FALSE)
  }
  if (!is.null(lineheight) && (!is.numeric(lineheight) || length(lineheight) != 1 || is.na(lineheight) || lineheight <= 0)) {
    stop("`lineheight` must be one positive number.", call. = FALSE)
  }
  if (!is.null(italic) && (!is.logical(italic) || length(italic) != 1 || is.na(italic))) {
    stop("`italic` must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.null(case)) case <- match.arg(case, c("none", "upper", "lower", "title"))
  if (!is.null(color) && length(color) != 1) stop("`color` must be length 1.", call. = FALSE)
  if (!is.null(family) && (!is.character(family) || length(family) != 1)) {
    stop("`family` must be one family name.", call. = FALSE)
  }
  structure(list(base = base, family = family, size = size, weight = weight, color = color,
                 italic = italic, lineheight = lineheight, case = case),
            class = "bb_text_style")
}

#' @export
print.bb_text_style <- function(x, ...) {
  set <- Filter(Negate(is.null), unclass(x)[.style_fields])
  cat("<text_style>", if (!is.null(x$base) && is.character(x$base)) paste0("base: ", x$base), "\n")
  for (n in names(set)) cat(" ", n, ": ", format(set[[n]]), "\n", sep = "")
  invisible(x)
}

#' Internal: resolve a style (role name, text_style, or NULL) to a complete list
#' @noRd
.resolve_text_style <- function(style, default_role = "body", depth = 0L) {
  if (depth > 20L) stop("text_style() bases are nested too deeply (circular?).", call. = FALSE)
  th <- bb_get_theme()
  role_style <- function(name) {
    r <- th$text[[name]]
    if (is.null(r)) {
      stop("Unknown text role `", name, "`. Known roles: ",
           paste(names(th$text), collapse = ", "), ".", call. = FALSE)
    }
    r
  }
  if (is.null(style)) return(if (is.null(default_role)) th$root else role_style(default_role))
  if (is.character(style)) return(role_style(style))
  if (inherits(style, "gpar")) {
    stop("Pass a text_style(), not a grid::gpar().", call. = FALSE)
  }
  if (!inherits(style, "bb_text_style")) stop("`style` must be a text_style() or a role name.", call. = FALSE)
  out <- if (!is.null(style$base)) .resolve_text_style(style$base, default_role, depth + 1L)
         else .resolve_text_style(NULL, default_role, depth + 1L)
  for (f in .style_fields) if (!is.null(style[[f]])) out[[f]] <- style[[f]]
  out
}

#' Internal: layer `inner` over `outer` (inner fields win)
#' @noRd
.layer_style <- function(outer, inner) {
  if (is.null(inner)) return(outer)
  if (is.null(outer)) return(inner)
  if (is.character(inner)) return(inner)
  inner$base <- if (is.null(inner$base)) outer else inner$base
  inner
}

#' Internal: resolved style -> gpar
#' @noRd
.as_gpar <- function(rs) {
  font <- .resolve_font(rs$family, rs$weight, isTRUE(rs$italic))
  gpar(fontfamily = font$family, fontface = font$face, fontsize = rs$size,
       col = .col(rs$color), lineheight = rs$lineheight)
}

#' Internal: family + weight -> (family name, grid face)
#' @noRd
.resolve_font <- function(family, weight, italic = FALSE) {
  if (is.null(.bb_env$fonts)) .bb_env$fonts <- new.env(parent = emptyenv())
  key <- paste(family, weight, italic, sep = "|")
  hit <- .bb_env$fonts[[key]]
  if (!is.null(hit)) return(hit)
  face_for <- function(bold) {
    if (bold && italic) "bold.italic" else if (bold) "bold" else if (italic) "italic" else "plain"
  }
  res <- if (abs(weight - 400) < 50) {
    list(family = family, face = face_for(FALSE))
  } else if (abs(weight - 700) < 50) {
    list(family = family, face = face_for(TRUE))
  } else {
    cand <- .variant_family(family, weight, italic)
    if (!is.null(cand)) {
      list(family = cand, face = "plain")
    } else {
      bold <- weight >= 600
      message("bodybuildr: no weight-", weight, " face found for \"", family, "\"; using ",
              if (bold) "bold" else "regular", ".")
      list(family = family, face = face_for(bold))
    }
  }
  .bb_env$fonts[[key]] <- res
  res
}

#' Internal: installed family name for a weight variant, verified on the device
#' @noRd
.variant_family <- function(family, weight, italic) {
  if (!requireNamespace("systemfonts", quietly = TRUE)) return(NULL)
  sf <- tryCatch(systemfonts::system_fonts(), error = function(e) NULL)
  if (is.null(sf)) return(NULL)
  faces <- sf[sf$family == family, , drop = FALSE]
  if (!nrow(faces)) return(NULL)
  wnum <- suppressWarnings(vapply(as.character(faces$weight), function(w) {
    tryCatch(.weight_num(w), error = function(e) NA_real_)
  }, numeric(1)))
  ok <- faces[!is.na(wnum) & wnum == weight & faces$italic == italic, , drop = FALSE]
  if (!nrow(ok)) return(NULL)
  cands <- unique(paste(family, ok$style))
  for (cand in cands) if (.family_resolves(cand)) return(cand)
  NULL
}

#' Internal: does the device resolve this family to a real font?
#' @noRd
.family_resolves <- function(family) {
  probe <- "Hamburgefonstiv 0123456789"
  w <- function(f) {
    convertWidth(grobWidth(textGrob(probe, gp = gpar(fontfamily = f, fontsize = 24))),
                 "in", valueOnly = TRUE)
  }
  with_measure_device(abs(w(family) - w("bodybuildr-missing-font")) > 1e-4)
}

#' Define a line style
#'
#' Used for rules, dividers, borders and legend keys.
#'
#' @param color Line colour: an R colour or a theme colour name. `NA` hides
#'   the line.
#' @param lwd Line width in grid `lwd` units (1 = 1/96 inch).
#' @param lty Line type.
#' @param alpha Optional opacity (0-1) applied to `color`.
#' @return A `bb_line_style` object.
#' @examples
#' line_style("rule_light", lwd = 0.75)
#' @export
line_style <- function(color = "rule_light", lwd = 0.75, lty = "solid", alpha = NULL) {
  if (!is.numeric(lwd) || length(lwd) != 1 || is.na(lwd) || lwd < 0) {
    stop("`lwd` must be one non-negative number.", call. = FALSE)
  }
  if (!is.null(alpha) && (!is.numeric(alpha) || alpha < 0 || alpha > 1)) {
    stop("`alpha` must be between 0 and 1.", call. = FALSE)
  }
  structure(list(color = color, lwd = lwd, lty = lty, alpha = alpha), class = "bb_line_style")
}

#' @noRd
.line_gp <- function(ls) {
  col <- .col(ls$color)
  if (!is.null(ls$alpha) && !is.na(col)) col <- grDevices::adjustcolor(col, alpha.f = ls$alpha)
  gpar(col = col, lwd = ls$lwd, lty = ls$lty, lineend = "butt")
}

#' @noRd
.has_line <- function(ls) !is.null(ls) && !is.na(ls$color) && ls$lwd > 0

#' @noRd
.as_line_style <- function(x, name) {
  if (is.null(x) || inherits(x, "bb_line_style")) return(x)
  if (length(x) == 1 && is.na(x)) return(NULL)
  if (is.character(x) && length(x) == 1) return(line_style(x))
  stop("`", name, "` must be a line_style(), a colour, or NULL.", call. = FALSE)
}

#' Define a box style
#'
#' Fill, border and spacing for [bb_box()] (and the label of
#' [bb_placeholder()]). Padding sits inside the border, margin outside it.
#' Lengths are `grid::unit` or inches, with 1, 2 (vertical, horizontal) or 4
#' (top, right, bottom, left) values.
#'
#' `box_style_panel()` is the flat note panel: theme `panel` fill, no border,
#' square corners, 12/14px padding.
#'
#' @param fill Fill: a colour (theme names allowed), [gradient_fill()],
#'   [stripe_fill()], or `NA`.
#' @param border A [line_style()] or a colour for the border; `NULL`/`NA` for
#'   none.
#' @param radius Corner radius.
#' @param padding Space between the border and the content.
#' @param margin Space outside the border.
#' @param margin_fill Fill colour of the margin band.
#' @param ... For `box_style_panel()`, further [box_style()] arguments.
#' @return A `bb_box_style` object.
#' @examples
#' box_style(fill = "panel", padding = unit(c(6, 8), "pt"))
#' @export
box_style <- function(fill = NA, border = NULL, radius = 0, padding = 0, margin = 0,
                      margin_fill = NA) {
  border <- .as_line_style(border, "border")
  .check_fill(fill)
  structure(list(fill = fill, border = border, radius = .in(radius, "radius"),
                 padding = .trbl_in(padding, "padding"), margin = .trbl_in(margin, "margin"),
                 margin_fill = margin_fill),
            class = "bb_box_style")
}

#' @rdname box_style
#' @export
box_style_panel <- function(fill = "panel", padding = c(12, 14, 12, 14) / 96, ...) {
  box_style(fill = fill, padding = padding, ...)
}

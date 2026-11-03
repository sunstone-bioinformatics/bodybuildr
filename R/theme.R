# Theme --------------------------------------------------------------------------
# One theme carries the colour palette, the text roles every component reads
# from, and the status palette. Components resolve `style = NULL` against the
# theme when they are measured and drawn, so a page or document can switch
# themes without rebuilding its blocks.

.default_colors <- function() {
  list(
    primary          = "#0C2C5E",
    accent           = "#E5782A",
    ink              = "#1D2430",
    text2            = "#3A4250",
    muted            = "#5B6472",
    faint            = "#8A919C",
    rule_strong      = "#C9CED6",
    rule_light       = "#E3E6EA",
    rule_faint       = "#EEF0F3",
    panel            = "#F4F5F7",
    panel_alt        = "#ECEEF1",
    on_primary       = "#FFFFFF",
    on_primary_muted = "#C9D3E4"
  )
}

.default_roles <- function(base_size) {
  s <- function(px) base_size * px / 12
  list(
    body          = list(lineheight = 1.45),
    table_body    = list(),
    note          = list(size = s(11), color = "text2", lineheight = 1.4),
    small         = list(size = s(10), color = "muted"),
    subheading    = list(size = s(12.5), weight = 700),
    section       = list(size = s(15), weight = 700, color = "primary"),
    refs          = list(size = s(10.5), color = "muted"),
    title         = list(size = s(26), weight = 700, color = "on_primary"),
    subtitle      = list(size = s(16), color = "on_primary_muted"),
    running       = list(weight = 700, color = "primary"),
    running_right = list(color = "muted"),
    table_header  = list(size = s(10.5), weight = 600, color = "muted"),
    legend        = list(size = s(10), color = "muted"),
    footer        = list(size = s(10), color = "muted"),
    status_label  = list(color = "text2"),
    placeholder   = list(size = s(11), color = "text2", lineheight = 1.4)
  )
}

.style_fields <- c("family", "size", "weight", "color", "italic", "lineheight", "case")

#' Define a theme
#'
#' A theme holds the colour palette, the text roles components draw with, and
#' the status palette used by [bb_status()]. Set it once with
#' [bb_set_theme()], or attach it to a [page_template()].
#'
#' **Colours.** Every colour argument in bodybuildr accepts either an R colour
#' or the name of a theme colour, for example `"muted"` or `"rule_light"`.
#' Defaults: `primary`, `accent`, `ink`, `text2`, `muted`, `faint`,
#' `rule_strong`, `rule_light`, `rule_faint`, `panel`, `panel_alt`,
#' `on_primary`, `on_primary_muted`. Add your own names freely.
#'
#' **Text roles.** Components take `style = NULL` and fall back to a role:
#' `body`, `table_body`, `note`, `small`, `subheading`, `section`, `refs`,
#' `title`, `subtitle`, `running`, `running_right`, `table_header`, `legend`,
#' `footer`, `status_label`, `placeholder`. Pass a role name as `style`
#' anywhere (`bb_text(x, style = "note")`), override a role through `text`, or
#' add new roles.
#'
#' Default sizes follow a 12px = 9pt body scale; `base_size` scales them all.
#'
#' @param font Default font family. With systemfonts installed, weights such
#'   as 600 resolve to the matching installed face (see [text_style()]).
#' @param base_size Body font size in points.
#' @param colors Named list of colours that override or extend the palette.
#' @param text Named list of [text_style()] objects that override or extend
#'   the text roles. Fields left `NULL` keep the role default.
#' @param status Named colours for `yes`, `no` and `unknown`.
#' @return A `bb_theme` object.
#' @examples
#' th <- bb_theme(font = "sans", colors = list(primary = "#123456"),
#'                text = list(note = text_style(size = 8)))
#' th$colors$primary
#' @export
bb_theme <- function(font = "sans", base_size = 9, colors = list(), text = list(),
                     status = c(yes = "#2F7D55", no = "#C2412F", unknown = "#9AA1AA")) {
  if (!is.character(font) || length(font) != 1) stop("`font` must be one family name.", call. = FALSE)
  if (!is.numeric(base_size) || length(base_size) != 1 || is.na(base_size) || base_size <= 0) {
    stop("`base_size` must be one positive number.", call. = FALSE)
  }
  if (!is.list(colors) || (length(colors) && is.null(names(colors)))) {
    stop("`colors` must be a named list.", call. = FALSE)
  }
  if (!is.list(text) || (length(text) && is.null(names(text)))) {
    stop("`text` must be a named list of text_style() objects.", call. = FALSE)
  }
  if (!all(c("yes", "no", "unknown") %in% names(status))) {
    stop("`status` needs colours named yes, no and unknown.", call. = FALSE)
  }
  pal <- .default_colors()
  pal[names(colors)] <- colors

  root <- list(family = font, size = base_size, weight = 400, color = "ink",
               italic = FALSE, lineheight = 1.2, case = "none")
  roles <- .default_roles(base_size)
  for (nm in names(text)) {
    ov <- text[[nm]]
    if (is.character(ov)) stop("Theme role `", nm, "` must be a text_style(), not a role name.", call. = FALSE)
    if (!inherits(ov, "bb_text_style")) stop("Theme role `", nm, "` must be a text_style().", call. = FALSE)
    base <- roles[[nm]] %||% list()
    for (f in .style_fields) if (!is.null(ov[[f]])) base[[f]] <- ov[[f]]
    roles[[nm]] <- base
  }
  full <- lapply(roles, function(r) {
    out <- root
    for (f in names(r)) out[[f]] <- r[[f]]
    out
  })

  .bb_env$theme_seq <- (.bb_env$theme_seq %||% 0L) + 1L
  structure(list(font = font, base_size = base_size, colors = pal, text = full,
                 root = root, status = status, id = .bb_env$theme_seq),
            class = "bb_theme")
}

#' @export
print.bb_theme <- function(x, ...) {
  cat("<bb_theme> font:", x$font, " base size:", x$base_size, "pt\n")
  cat("colours:", paste(names(x$colors), collapse = ", "), "\n")
  cat("text roles:", paste(names(x$text), collapse = ", "), "\n")
  invisible(x)
}

#' Get or set the active theme
#'
#' `bb_set_theme()` makes a theme the default for every block measured or
#' drawn afterwards. `with_theme()` applies one for the duration of an
#' expression. A [page_template()] with a `theme` applies it while its pages
#' are exported.
#'
#' @param theme A [bb_theme()]. `NULL` restores the default theme.
#' @param expr Code to evaluate with `theme` active.
#' @return `bb_set_theme()` returns the previous theme invisibly;
#'   `bb_get_theme()` the active theme; `with_theme()` the value of `expr`.
#' @examples
#' old <- bb_set_theme(bb_theme(font = "serif"))
#' bb_get_theme()$font
#' bb_set_theme(old)
#' @export
bb_set_theme <- function(theme) {
  if (!is.null(theme) && !inherits(theme, "bb_theme")) stop("`theme` must come from bb_theme().", call. = FALSE)
  old <- .bb_env$theme
  .bb_env$theme <- theme
  invisible(old)
}

#' @rdname bb_set_theme
#' @export
bb_get_theme <- function() {
  if (is.null(.bb_env$theme)) .bb_env$theme <- bb_theme()
  .bb_env$theme
}

#' @rdname bb_set_theme
#' @export
with_theme <- function(theme, expr) {
  if (is.null(theme)) return(force(expr))
  old <- bb_set_theme(theme)
  on.exit(.bb_env$theme <- old, add = TRUE)
  force(expr)
}

#' @noRd
.theme_id <- function() bb_get_theme()$id

#' Internal: resolve theme colour names, keep everything else
#' @noRd
.col <- function(x) {
  if (is.null(x)) return(NA)
  if (!is.character(x)) return(x)
  pal <- bb_get_theme()$colors
  out <- x
  hit <- !is.na(x) & x %in% names(pal)
  out[hit] <- unlist(pal[x[hit]], use.names = FALSE)
  out
}

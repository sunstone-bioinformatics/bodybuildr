# Unit helpers -----------------------------------------------------------------
# Public arguments take a grid::unit or a number of inches. Layout maths runs
# in plain inches once a block knows its width.

`%||%` <- function(x, y) if (is.null(x)) y else x

.abs_unit_in <- c(inches = 1, `in` = 1, cm = 1 / 2.54, mm = 1 / 25.4, points = 1 / 72.27,
                  pt = 1 / 72.27, bigpts = 1 / 72, picas = 12 / 72.27, dida = 1238 / 1157 / 72.27,
                  cicero = 12 * 1238 / 1157 / 72.27, scaledpts = 1 / 65536 / 72.27)

#' Internal: unit -> inches without opening a default graphics device
#'
#' Physical units convert arithmetically. Anything else (sums, string
#' widths) is converted on the measuring device.
#' @noRd
.unit_in <- function(u) {
  vapply(seq_along(u), function(i) {
    ui <- u[i]
    ty <- unitType(ui)
    f <- .abs_unit_in[ty]
    if (!is.na(f)) return(as.numeric(ui) * unname(f))
    if (ty %in% c("null", "npc", "snpc", "native")) {
      stop("A \"", ty, "\" unit has no absolute size here.", call. = FALSE)
    }
    with_measure_device(as.numeric(convertUnit(ui, "in", valueOnly = TRUE)))
  }, numeric(1))
}

#' Internal: coerce to a non-negative length-1 unit
#'
#' @param x A `grid::unit` or numeric inches.
#' @param name Argument name used in error messages.
#' @return A length-1 `unit`.
#' @keywords internal
#' @noRd
.as_unit_nonneg <- function(x, name) {
  if (inherits(x, "unit")) {
    u <- x
  } else if (is.numeric(x)) {
    u <- unit(x, "in")
  } else {
    stop("`", name, "` must be a unit or numeric (inches).", call. = FALSE)
  }
  if (length(u) != 1) stop("`", name, "` must be length 1.", call. = FALSE)
  vals <- tryCatch(.unit_in(u),
                   error = function(e) stop("`", name, "` must be an absolute unit.", call. = FALSE))
  if (is.na(vals)) stop("`", name, "` cannot be NA.", call. = FALSE)
  if (vals < 0) stop("`", name, "` must be non-negative.", call. = FALSE)
  u
}

#' Internal: convert a unit to inches
#' @noRd
.to_in <- function(u) {
  if (!inherits(u, "unit")) stop(".to_in() expects a unit object.", call. = FALSE)
  .unit_in(u)
}

#' Internal: validated length-1 length in inches (NULL allowed when asked)
#' @noRd
.in <- function(x, name, allow_null = FALSE) {
  if (is.null(x)) {
    if (allow_null) return(NULL)
    stop("`", name, "` is required.", call. = FALSE)
  }
  .to_in(.as_unit_nonneg(x, name))
}

#' Internal: top/right/bottom/left spacing in inches from length 1, 2 or 4
#' @noRd
.trbl_in <- function(x, name) {
  if (is.null(x)) return(c(0, 0, 0, 0))
  v <- if (inherits(x, "unit")) {
    tryCatch(.unit_in(x),
             error = function(e) stop("`", name, "` must use absolute units.", call. = FALSE))
  } else if (is.numeric(x)) {
    as.numeric(x)
  } else {
    stop("`", name, "` must be a unit or numeric (inches).", call. = FALSE)
  }
  if (anyNA(v)) stop("`", name, "` cannot contain NA.", call. = FALSE)
  if (any(v < 0)) stop("`", name, "` must be non-negative.", call. = FALSE)
  if (length(v) == 1) return(rep(v, 4))
  if (length(v) == 2) return(c(v[1], v[2], v[1], v[2]))
  if (length(v) == 4) return(v)
  stop("`", name, "` must have length 1, 2 or 4 (top, right, bottom, left).", call. = FALSE)
}

#' Internal: resolve column widths against the available width
#'
#' Absolute units are taken first; numbers and `"null"` units share what is
#' left in proportion.
#' @noRd
.resolve_widths <- function(widths, n, avail, gap_total = 0) {
  if (is.null(widths)) widths <- rep(1, n)
  if (length(widths) != n) {
    stop("`widths` must have one entry per column (", n, "), not ", length(widths), ".", call. = FALSE)
  }
  free <- avail - gap_total
  if (inherits(widths, "unit")) {
    types <- vapply(seq_len(n), function(i) unitType(widths[i]), character(1))
    is_null <- types == "null"
    vals <- numeric(n)
    if (any(!is_null)) vals[!is_null] <- .unit_in(widths[!is_null])
    if (any(is_null)) {
      props <- as.numeric(widths)[is_null]
      rest <- free - sum(vals[!is_null])
      vals[is_null] <- if (sum(props) > 0) pmax(rest, 0) * props / sum(props) else 0
    }
  } else if (is.numeric(widths)) {
    if (anyNA(widths) || any(widths < 0) || sum(widths) <= 0) {
      stop("Numeric `widths` are proportions and must be non-negative with a positive sum.", call. = FALSE)
    }
    vals <- free * widths / sum(widths)
  } else {
    stop("`widths` must be numeric proportions or a grid unit vector.", call. = FALSE)
  }
  if (any(vals < 0)) stop("Column widths cannot be negative.", call. = FALSE)
  if (sum(vals) > free + 1e-6) {
    warning(sprintf("Columns need %.2f in but only %.2f in is available.", sum(vals), free), call. = FALSE)
  }
  vals
}

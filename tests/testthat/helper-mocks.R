# Helper fixtures for tests -------------------------------------------------

make_test_plot <- function() {
  if (!requireNamespace("ggplot2", quietly = TRUE)) return(NULL)
  ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
}

make_test_png <- function(width = 20, height = 10) {
  tf <- tempfile(fileext = ".png")
  img <- array(0.5, dim = c(height, width, 3))
  png::writePNG(img, tf)
  tf
}

# A block that records the width/height it is measured and drawn at.
probe_block <- function(env, height = 0.5, full_bleed = FALSE, name = "probe") {
  new_block(
    "probe",
    measure = function(width) { env[[paste0(name, "_mw")]] <- width; height },
    render = function(width, height) {
      env[[paste0(name, "_rw")]] <- width
      env[[paste0(name, "_rh")]] <- height
      grid::nullGrob()
    },
    full_bleed = full_bleed
  )
}

# Export to a temp PDF and return the path.
export_tmp <- function(x, ...) {
  f <- tempfile(fileext = ".pdf")
  export_pdf(x, f, ...)
  f
}

h_in <- function(x, width) as.numeric(measure_block(x, width))

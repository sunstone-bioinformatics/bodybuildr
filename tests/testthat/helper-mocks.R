# Helper fixtures for tests -------------------------------------------------

# Minimal ggplot fixture (only if ggplot2 is installed)
make_test_plot <- function() {
  if (!requireNamespace("ggplot2", quietly = TRUE)) return(NULL)
  ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
}

# Minimal grob fixture
make_test_grob <- function() {
  grid::rectGrob(width = grid::unit(1, "npc"), height = grid::unit(1, "npc"))
}

# Minimal PNG written to a temp file (skip if not writable)
make_test_png <- function() {
  tf <- tempfile(fileext = ".png")
  grDevices::png(tf, width = 10, height = 10)
  on.exit(grDevices::dev.off(), add = TRUE)
  grid::grid.rect(gp = grid::gpar(fill = "blue"))
  tf
}

# Rectangular PNG fixture (custom aspect ratio)
make_test_png_rect <- function(width = 200, height = 100) {
  tf <- tempfile(fileext = ".png")
  grDevices::png(tf, width = width, height = height)
  on.exit(grDevices::dev.off(), add = TRUE)
  grid::grid.rect(gp = grid::gpar(fill = "blue"))
  tf
}

# Find the first raster grob inside a grob tree
find_first_raster_grob <- function(g) {
  if (inherits(g, "rastergrob")) return(g)
  if (inherits(g, c("gTree", "grobTree"))) {
    kids <- g$children
    if (length(kids)) {
      for (kid in kids) {
        res <- find_first_raster_grob(kid)
        if (!is.null(res)) return(res)
      }
    }
  }
  if (is.list(g)) {
    for (kid in g) {
      res <- find_first_raster_grob(kid)
      if (!is.null(res)) return(res)
    }
  }
  NULL
}

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
  grid::grid.rect(gp = grid::gpar(fill = "red"))
  tf
}

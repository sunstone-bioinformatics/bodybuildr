test_that("str_n_panel_row renders mixed content with per-column styles", {
  skip_if_not_installed("ggplot2")
  logo <- make_test_png()
  plot_obj <- make_test_plot()
  items <- list(logo, plot_obj, "Text cell")

  col_styles <- list(
    list(bg = "#F1F5F9"),
    list(bg = "#E0F2FE", pad_x = grid::unit(6, "pt")),
    list(
      bg = "#FEE2E2",
      text_style = textStyle(color = "#7F1D1D", size = 12, face = "bold"),
      box_style  = boxStyle(
        radius = grid::unit(10, "pt"),
        border_color = "#B91C1C",
        border_lwd = 1.2,
        fill = "#FFE4E6",
        margin = grid::unit(c(6,6,6,6), "pt"),
        padding = grid::unit(c(6,10,6,10), "pt")
      )
    )
  )

  gt <- str_n_panel_row(
    items = items,
    column_bg = c("#FFFFFF", "#FFFFFF", "#FFFFFF"),
    column_gap = grid::unit(8, "pt"),
    outer_margin = grid::unit(6, "pt"),
    bottom_margin = grid::unit(6, "pt"),
    column_styles = col_styles
  )
  expect_s3_class(gt, "gtable")
})

test_that("str_n_panel_row export pdf with multiple rows", {
  skip_if_not_installed("ggplot2")
  logo <- make_test_png()
  plot_obj <- make_test_plot()
  if (is.null(plot_obj)) skip("plot fixture unavailable")

  row3 <- str_n_panel_row(
    items = list(logo, plot_obj, "Third panel text"),
    column_styles = list(
      list(bg = "#F9FAFB"),
      list(bg = "#EFF6FF"),
      list(bg = "#F8FAE5", text_style = textStyle(color = "#374151"))
    )
  )

  row2 <- str_n_panel_row(
    items = list("Left text box", "Right text box"),
    column_styles = list(
      list(
        bg = "#ECFEFF",
        text_style = textStyle(color = "#0F172A", size = 11),
        box_style = boxStyle(fill = "#E0F2FE", radius = grid::unit(12, "pt"))
      ),
      list(
        bg = "#FEF2F2",
        text_style = textStyle(color = "#7F1D1D", size = 12, face = "bold"),
        box_style = boxStyle(fill = "#FFE4E6", radius = grid::unit(4, "pt"))
      )
    ),
    column_gap = grid::unit(12, "pt")
  )

  canvas <- new_canvas()
  canvas <- canvas_add_row(canvas, row3, grid::unit(3, "in"))
  canvas <- canvas_add_row(canvas, row2, grid::unit(2, "in"))

  out_dir <- normalizePath(file.path("..", "..", "test_files"), mustWork = FALSE)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  pdf_path <- file.path(out_dir, "str_n_panel_row.pdf")
  if (file.exists(pdf_path)) file.remove(pdf_path)

  res <- export_pdf(
    canvas,
    file = pdf_path,
    width = grid::unit(8.5, "in"),
    height = grid::unit(6, "in"),
    margin_left = grid::unit(0.2, "in"),
    margin_right = grid::unit(0.2, "in")
  )
  expect_true(file.exists(pdf_path))
  expect_equal(res, pdf_path)
})

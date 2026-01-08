test_that("str_n_panel_row renders mixed content with per-column styles", {
  skip_if_not_installed("ggplot2")
  logo <- make_test_png()
  plot_obj <- make_test_plot()
  items <- list(
    logo,
    plot_obj,
    text_box(
      "Text cell",
      text_style = text_style(color = "#7F1D1D", size = 12, face = "bold"),
      box_style  = box_style(
        radius = grid::unit(10, "pt"),
        border_color = "#B91C1C",
        border_lwd = 1.2,
        fill = "#FFE4E6",
        margin = grid::unit(c(6,6,6,6), "pt"),
        padding = grid::unit(c(6,10,6,10), "pt")
      ),
      bg = "#FEE2E2"
    )
  )

  gt <- str_n_panel_row(
    items = items,
    column_style = column_layout_style(
      column_bg = c("#ffa200ff", "#FFFFFF", "#f90000ff"),
      column_gap = grid::unit(8, "pt"),
      outer_margin = grid::unit(6, "pt"),
      bottom_margin = grid::unit(6, "pt")
    )
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
    column_style = column_layout_style(
      column_bg = c("#425569", "#828992", "#acb64f"),bottom_margin_bg = "#0c74dbff"
    ),
    text_style = text_style(color = "#374151")
  )

  row2 <- str_n_panel_row(
    items = list(
      text_box(
        "Left text box",
        text_style = text_style(color = "#0F172A", size = 11),
        box_style = box_style(fill = "#E0F2FE", radius = grid::unit(12, "pt")),
        bg = "#ECFEFF"
      ),
      text_box(
        "Right text box",
        text_style = text_style(color = "#7F1D1D", size = 12, face = "bold"),
        box_style = box_style(fill = "#FFE4E6", radius = grid::unit(4, "pt")),
        bg = "#FEF2F2"
      )
    ),
    column_style = column_layout_style(column_gap = grid::unit(20, "pt"),
    column_gap_bg = "#0c74dbff", 
    outer_margin_bg = "#0c74dbff",outer_margin = grid::unit(5, "pt"),
    column_bg = c("#0c74dbff", "#0c74dbff"),
    bottom_margin_bg = "#0c74dbff")
  )

  canvas <- new_canvas()
  canvas <- canvas_add_row(canvas, row3, grid::unit(6, "in"))
  canvas <- canvas_add_row(canvas, row2, grid::unit(6, "in"))
  out_dir <- normalizePath(file.path("..", "..", "test_files"), mustWork = FALSE)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  pdf_path <- file.path(out_dir, "str_n_panel_row.pdf")
  if (file.exists(pdf_path)) file.remove(pdf_path)

  res <- export_pdf(
    canvas,
    file = pdf_path,
    width = grid::unit(8.5, "in"),
    height = grid::unit(12, "in"),
    margin_left = grid::unit(0.0, "in"),
    margin_right = grid::unit(0.0, "in")
  )
  expect_true(file.exists(pdf_path))
  expect_equal(res, pdf_path)
})

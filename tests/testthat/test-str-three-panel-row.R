test_that("str_three_panel_row renders three text boxes", {
  row <- str_three_panel_row(
    A_item = text_box(
      "Left panel text",
      text_style = textStyle(color = "#1F2937", size = 12, face = "bold"),
      box_style = boxStyle(
        radius = grid::unit(6, "pt"),
        border_color = "#0EA5E9",
        border_lwd = 1,
        fill = "#2a86c3ff",
        margin = grid::unit(0, "pt"),
        padding = grid::unit(c(6, 10, 6, 10), "pt")
      ),
      bg = "#2c7bcaff"
    ),
    B_item = text_box(
      "Top-right text",
      text_style = textStyle(color = "#14532D", size = 11),
      box_style = boxStyle(
        radius = grid::unit(4, "pt"),
        border_color = "#22C55E",
        border_lwd = 1,
        fill = "#23954bff",
        margin = grid::unit(0, "pt"),
        padding = grid::unit(c(6, 10, 6, 10), "pt")
      ),
      bg = "#ECFDF5"
    ),
    C_item = text_box(
      "Bottom-right text",
      text_style = textStyle(color = "#7C2D12", size = 11),
      box_style = boxStyle(
        radius = grid::unit(4, "pt"),
        border_color = "#F97316",
        border_lwd = 1,
        fill = "#ad7123ff",
        margin = grid::unit(0, "pt"),
        padding = grid::unit(c(6, 10, 6, 10), "pt")
      ),
      bg = "#FFF7ED"
    ),
    layout_style = threePanelLayoutStyle(
      A_bg = "#ffffffff",
      B_bg = "#ffffffff",
      C_bg = "#ffffffff",
      outer_margin = grid::unit(6, "pt"),
      bottom_margin = grid::unit(6, "pt")
    )
  )
  expect_s3_class(row, "gtable")
})

test_that("str_three_panel_row supports reverse layout", {
  row <- str_three_panel_row(
    A_item = text_box("Right panel", text_style = textStyle(color = "#111827", size = 12)),
    B_item = text_box("Left top", text_style = textStyle(color = "#111827", size = 11)),
    C_item = text_box("Left bottom", text_style = textStyle(color = "#111827", size = 11)),
    layout_style = threePanelLayoutStyle(
      A_bg = "#ffffff",
      B_bg = "#ffffff",
      C_bg = "#ffffff",
      outer_margin = grid::unit(4, "pt"),
      bottom_margin = grid::unit(4, "pt")
    ),
    reverse = TRUE
  )
  expect_s3_class(row, "gtable")
})

test_that("str_three_panel_row exports mixed content to PDF", {
  skip_if_not_installed("ggplot2")
  logo <- make_test_png()
  plot_obj <- make_test_plot()
  if (is.null(plot_obj)) skip("plot fixture unavailable")

  row_mixed <- str_three_panel_row(
    A_item = logo,
    B_item = plot_obj,
    C_item = text_box(
      "Notes on the right panel",
      text_style = textStyle(color = "#111827", size = 11),
      box_style = boxStyle(
        radius = grid::unit(6, "pt"),
        border_color = "#D1D5DB",
        border_lwd = 1,
        fill = "#F9FAFB",
        margin = grid::unit(0, "pt"),
        padding = grid::unit(c(6, 10, 6, 10), "pt")
      ),
      bg = "#FFFFFF"
    ),
    layout_style = threePanelLayoutStyle(
      A_bg = "#FFFFFF",
      B_bg = "#FFFFFF",
      C_bg = "#FFFFFF",
      hgap = grid::unit(8, "pt"),
      vgap = grid::unit(8, "pt"),
      outer_margin = grid::unit(6, "pt"),
      bottom_margin = grid::unit(6, "pt")
    )
  )

  row_text <- str_three_panel_row(
    A_item = text_box("A panel",box_style = boxStyle(fill="#316ab9ff",padding = grid::unit(c(10,15,20,10), "pt")),  text_style = textStyle(color = "#1F2937", size = 12)),
    B_item = text_box("B panel", text_style = textStyle(color = "#1F2937", size = 12)),
    C_item = text_box("C panel", text_style = textStyle(color = "#1F2937", size = 12)),
    layout_style = threePanelLayoutStyle(
      A_bg = "#ffffffff",
      B_bg = "#ffffffff",
      C_bg = "#ffffffff",
      outer_margin = grid::unit(6, "pt"),
      bottom_margin = grid::unit(6, "pt")
    )
  )

  row_reverse <- str_three_panel_row(
    A_item = text_box("Right A", text_style = textStyle(color = "#0f172a", size = 12)),
    B_item = text_box("Left B", text_style = textStyle(color = "#0f172a", size = 12)),
    C_item = text_box("Left C", text_style = textStyle(color = "#0f172a", size = 12)),
    layout_style = threePanelLayoutStyle(
      A_bg = "#ffffff",
      B_bg = "#ffffff",
      C_bg = "#ffffff",
      outer_margin = grid::unit(6, "pt"),
      bottom_margin = grid::unit(6, "pt")
    ),
    reverse = TRUE
  )

  canvas <- new_canvas()
  canvas <- canvas_add_row(canvas, row_mixed, grid::unit(3.5, "in"))
  canvas <- canvas_add_row(canvas, row_text, grid::unit(3, "in"))
  canvas <- canvas_add_row(canvas, row_reverse, grid::unit(2.5, "in"))

  out_dir <- normalizePath(file.path("..", "..", "test_files"), mustWork = FALSE)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  pdf_path <- file.path(out_dir, "str_three_panel_row.pdf")
  if (file.exists(pdf_path)) file.remove(pdf_path)

  res <- export_pdf(
    canvas,
    file = pdf_path,
    width = grid::unit(8.5, "in"),
    height = grid::unit(9, "in")
  )
  expect_true(file.exists(pdf_path))
  expect_equal(res, pdf_path)
})

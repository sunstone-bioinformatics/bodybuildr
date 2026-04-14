test_that("str_three_panel_row renders three text boxes", {
  row <- str_three_panel_row(
    A_item = text_box(
      "Left panel text",
      text_style = text_style(color = "#1F2937", size = 12, face = "bold"),
      box_style = box_style(
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
      text_style = text_style(color = "#14532D", size = 11),
      box_style = box_style(
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
      text_style = text_style(color = "#7C2D12", size = 11),
      box_style = box_style(
        radius = grid::unit(4, "pt"),
        border_color = "#F97316",
        border_lwd = 1,
        fill = "#ad7123ff",
        margin = grid::unit(0, "pt"),
        padding = grid::unit(c(6, 10, 6, 10), "pt")
      ),
      bg = "#FFF7ED"
    ),
    layout_style = layout_style(
      type = "three_panel",
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
    A_item = text_box("Right panel", text_style = text_style(color = "#111827", size = 12)),
    B_item = text_box("Left top", text_style = text_style(color = "#111827", size = 11)),
    C_item = text_box("Left bottom", text_style = text_style(color = "#111827", size = 11)),
    layout_style = layout_style(
      type = "three_panel",
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
      text_style = text_style(color = "#111827", size = 11),
      box_style = box_style(
        radius = grid::unit(6, "pt"),
        border_color = "#D1D5DB",
        border_lwd = 1,
        fill = "#F9FAFB",
        margin = grid::unit(0, "pt"),
        padding = grid::unit(c(6, 10, 6, 10), "pt")
      ),
      bg = "#FFFFFF"
    ),
    layout_style = layout_style(
      type = "three_panel",
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
    A_item = text_box("A panel",box_style = box_style(fill="#316ab9ff",padding = grid::unit(c(10,15,20,10), "pt")),  text_style = text_style(color = "#1F2937", size = 12)),
    B_item = text_box("B panel", text_style = text_style(color = "#1F2937", size = 12)),
    C_item = text_box("C panel", text_style = text_style(color = "#1F2937", size = 12)),
    layout_style = layout_style(
      type = "three_panel",
      A_bg = "#ffffffff",
      B_bg = "#ffffffff",
      C_bg = "#ffffffff",
      outer_margin = grid::unit(6, "pt"),
      bottom_margin = grid::unit(6, "pt")
    )
  )

  row_reverse <- str_three_panel_row(
    A_item = text_box("Right A", text_style = text_style(color = "#0f172a", size = 12)),
    B_item = text_box("Left B", text_style = text_style(color = "#0b47d4ff", size = 12)),
    C_item = text_box("Left C", text_style = text_style(color = "#0f172a", size = 12)),
    layout_style = layout_style(
      type = "three_panel",
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

test_that("str_three_panel_row fit images respect panel aspect ratio", {
  img <- make_test_png_rect(width = 200, height = 100)
  row <- str_three_panel_row(
    A_item = img,
    layout_style = layout_style(
      type = "three_panel",
      A_width = grid::unit(4, "in"),
      right_split = 0.5,
      hgap = grid::unit(0, "pt"),
      vgap = grid::unit(0, "pt"),
      outer_margin = grid::unit(0, "pt"),
      bottom_margin = grid::unit(0, "pt"),
      A_pad_x = grid::unit(0, "pt"),
      A_pad_y = grid::unit(0, "pt"),
      B_pad_x = grid::unit(0, "pt"),
      B_pad_y = grid::unit(0, "pt"),
      C_pad_x = grid::unit(0, "pt"),
      C_pad_y = grid::unit(0, "pt")
    ),
    image_scale = "fit"
  )

  canvas <- new_canvas()
  canvas <- canvas_add_row(canvas, row, grid::unit(2, "in"))

  tmp <- tempfile(fileext = ".png")
  grDevices::png(tmp, width = 6, height = 2, units = "in", res = 72)
  on.exit(unlink(tmp), add = TRUE)
  on.exit(grDevices::dev.off(), add = TRUE)

  captured <- grid::grid.grabExpr({
    grid::grid.newpage()
    bodybuildr:::.draw_canvas_top(
      canvas,
      margin_top = grid::unit(0, "in"),
      margin_right = grid::unit(0, "in"),
      margin_bottom = grid::unit(0, "in"),
      margin_left = grid::unit(0, "in")
    )
  })

  forced <- grid::grid.force(captured)
  raster <- find_first_raster_grob(forced)
  expect_true(inherits(raster, "rastergrob"))
  expect_equal(as.numeric(raster$width), 1, tolerance = 1e-6)
  expect_equal(as.numeric(raster$height), 1, tolerance = 1e-6)
})

test_that("str_three_panel_row supports blank_box panels", {
  row <- str_three_panel_row(
    A_item = blank_box(),
    B_item = text_box("Center"),
    C_item = blank_box(),
    layout_style = layout_style(
      type = "three_panel",
      A_bg = "#E5E7EB",
      B_bg = "#FFFFFF",
      C_bg = "#E5E7EB",
      outer_margin = grid::unit(0, "pt"),
      bottom_margin = grid::unit(0, "pt")
    )
  )

  expect_s3_class(row, "gtable")
  expect_equal(length(row$grobs), 3)
})

test_that("str_three_panel_row blank_box does not use text-box rendering", {
  row <- str_three_panel_row(
    A_item = blank_box(),
    layout_style = layout_style(
      type = "three_panel",
      A_bg = "#F3F4F6",
      B_bg = "#FFFFFF",
      C_bg = "#FFFFFF",
      outer_margin = grid::unit(0, "pt"),
      bottom_margin = grid::unit(0, "pt")
    )
  )

  expect_s3_class(row$grobs[[1]], "gTree")
  expect_false(any(vapply(row$grobs[[1]]$children, inherits, logical(1), "text")))
})

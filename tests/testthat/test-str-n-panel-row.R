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
    layout_style = layout_style(
      type = "columns",
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
    layout_style = layout_style(
      type = "columns",
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
    layout_style = layout_style(type = "columns", column_gap = grid::unit(20, "pt"),
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

test_that("str_n_panel_row export pdf with debug boxes enabled", {
  img <- make_test_png_rect(width = 430, height = 200)
  row <- str_n_panel_row(
    items = list(img),
    layout_style = layout_style(
      type = "columns",
      column_bg = c("red", "red"),
      column_pad_x = grid::unit(0, "pt"),
      column_pad_y = grid::unit(0, "pt"),
      column_gap = grid::unit(0, "pt"),
      outer_margin = grid::unit(0, "pt"),
      bottom_margin = grid::unit(0, "pt"),
      outer_margin_bg = "#F1F5F9",
      bottom_margin_bg = "#F1F5F9",
      column_gap_bg = "#E2E8F0"
    ),
    image_scale = "fit",
    debug_boxes = TRUE
  )

  canvas <- new_canvas()
  canvas <- canvas_add_row(canvas, row, grid::unit(2, "in"))

  out_dir <- normalizePath(file.path("..", "..", "test_files"), mustWork = FALSE)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  pdf_path <- file.path(out_dir, "str_n_panel_row_debug.pdf")
  if (file.exists(pdf_path)) file.remove(pdf_path)

  res <- export_pdf(
    canvas,
    file = pdf_path,
    width = grid::unit(8.5, "in"),
    height = grid::unit(11, "in"),
    margin_left = grid::unit(0.0, "in"),
    margin_right = grid::unit(0.0, "in")
  )
  expect_true(file.exists(pdf_path))
  expect_equal(res, pdf_path)
})

test_that("str_n_panel_row fit images respect panel aspect ratio", {
  img <- make_test_png_rect(width = 200, height = 100)
  row <- str_n_panel_row(
    items = list(img),
    layout_style = layout_style(
      type = "columns",
      column_bg = "white",
      column_pad_x = grid::unit(0, "pt"),
      column_pad_y = grid::unit(0, "pt"),
      column_gap = grid::unit(0, "pt"),
      outer_margin = grid::unit(0, "pt"),
      bottom_margin = grid::unit(0, "pt")
    ),
    image_scale = "fit"
  )

  canvas <- new_canvas()
  canvas <- canvas_add_row(canvas, row, grid::unit(2, "in"))

  tmp <- tempfile(fileext = ".png")
  grDevices::png(tmp, width = 4, height = 2, units = "in", res = 72)
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

test_that("str_n_panel_row supports deprecated column_style alias", {
  expect_warning(
    gt <- str_n_panel_row(
      items = list("Text"),
      column_style = column_layout_style(column_gap = grid::unit(4, "pt"))
    ),
    "`column_style` is deprecated; use `layout_style` instead."
  )
  expect_s3_class(gt, "gtable")
})

test_that("str_n_panel_row errors when both layout_style and column_style are supplied", {
  expect_error(
    str_n_panel_row(
      items = list("Text"),
      layout_style = layout_style(type = "columns"),
      column_style = column_layout_style()
    ),
    "Supply only one of `layout_style` or `column_style`."
  )
})

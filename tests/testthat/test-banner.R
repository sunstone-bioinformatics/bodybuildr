test_that("text_style returns gpar and validates size", {
  gp <- text_style(col = "red", size = 12, face = "bold", family = "mono")
  expect_s3_class(gp, "gpar")
  expect_error(text_style(size = -1), "`size` must be length-1, non-negative")
})

test_that("box_style validates non-negative units and border width", {
  bs <- box_style()
  expect_type(bs, "list")
  expect_error(box_style(border_lwd = -1), "`border_lwd` must be length-1, non-negative")
  expect_error(box_style(radius = grid::unit(-1, "pt")), "`radius` must be non-negative")
  expect_error(box_style(margin = grid::unit(c(1, -1, 1, 1), "pt")), "`margin` must be non-negative")
})

test_that("banner_layout_style builds defaults and rejects negatives", {
  ls <- banner_layout_style()
  expect_true(is.list(ls))
  expect_error(
    banner_layout_style(banner_height = grid::unit(-1, "in")),
    "`banner_height` must be non-negative"
  )
})

test_that("str_banner_row builds a gtable with styles", {
  logo <- make_test_png()
  ls <- layout_style(type = "banner", banner_height = grid::unit(2, "in"))
  gt <- str_banner_row(
    image_path = logo,
    title = "Title",
    subtitle = "Subtitle",
    layout_style = ls,
    text_style = list(
      title = text_style(col = "white", size = 16, face = "bold"),
      subtitle = text_style(col = "white", size = 12)
    )
  )
  expect_s3_class(gt, "gtable")
})

test_that("str_banner_row errors on negative layout overrides", {
  logo <- make_test_png()
  expect_error(
    str_banner_row(
      image_path = logo,
      layout_style = list(banner_height = grid::unit(-1, "in"))
    ),
    "`banner_height` must be non-negative"
  )
})

test_that("banner_layout_style logo_position right builds valid gtable", {
  logo <- make_test_png()
  gt <- str_banner_row(image_path = logo, title = "T",
                       layout_style = banner_layout_style(logo_position = "right"))
  expect_s3_class(gt, "gtable")
  expect_equal(ncol(gt), 2L)
})

test_that("banner_layout_style image_scale fill builds valid gtable", {
  logo <- make_test_png()
  gt <- str_banner_row(image_path = logo, title = "T",
                       layout_style = banner_layout_style(image_scale = "fill"))
  expect_s3_class(gt, "gtable")
})

test_that("str_banner_row export creates PDF", {
  logo <- make_test_png()
  banner <- str_banner_row(image_path = logo, title = "Title", subtitle = "Subtitle", text_style = list(
    title = text_style(color = "sandybrown", size = 22)))
  out_dir <- normalizePath(file.path("..", "..", "test_files"), mustWork = FALSE)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  pdf_path <- file.path(out_dir, "banner_row.pdf")
  if (file.exists(pdf_path)) file.remove(pdf_path)
  res <- export_pdf(
    banner,
    file = pdf_path,
    width = grid::unit(8.5, "in"),
    height = grid::unit(11, "in"),
    margin_left = grid::unit(0, "in"),
    margin_right = grid::unit(0, "in")
  )
  expect_true(file.exists(pdf_path))
  expect_equal(res, pdf_path)
})

test_that("new_canvas returns an empty gtable", {
  cnv <- new_canvas()
  expect_s3_class(cnv, "gtable")
  expect_equal(nrow(cnv), 1)
  expect_equal(sum(as.numeric(grid::convertUnit(cnv$heights, "pt"))), 0)
})

test_that("canvas_add_row appends a row of given height", {
  cnv <- new_canvas()
  row <- make_test_grob()
  h <- grid::unit(1, "in")
  cnv2 <- canvas_add_row(cnv, row, h)
  expect_s3_class(cnv2, "gtable")
  expect_gt(nrow(cnv2), nrow(cnv))
})

test_that("canvas_add_row errors on negative height", {
  cnv <- new_canvas()
  row <- make_test_grob()
  expect_error(
    canvas_add_row(cnv, row, grid::unit(-1, "in")),
    "`height` must be non-negative"
  )
})

test_that("draw_canvas_top accepts margins without error", {
  cnv <- new_canvas()
  row <- make_test_grob()
  h <- grid::unit(0.5, "in")
  cnv <- canvas_add_row(cnv, row, h)
  expect_no_error(draw_canvas_top(cnv,
    margin_top = grid::unit(0.1, "in"),
    margin_left = grid::unit(0.1, "in"),
    margin_right= grid::unit(0.2, "in"),
    clip = TRUE
  ))
})

test_that("draw_canvas_top errors on negative margins", {
  cnv <- new_canvas()
  row <- make_test_grob()
  h <- grid::unit(0.5, "in")
  cnv <- canvas_add_row(cnv, row, h)
  expect_error(
    draw_canvas_top(cnv, margin_left = grid::unit(-0.1, "in")),
    "`margin_left` must be non-negative"
  )
})

test_that("export_pdf writes a PDF", {
  cnv <- new_canvas()
  row <- make_test_grob()
  h <- grid::unit(0.5, "in")
  cnv <- canvas_add_row(cnv, row, h)
  out_dir <- normalizePath(file.path("..", "..", "test_files"), mustWork = FALSE)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  pdf_path <- file.path(out_dir, "export_pdf_canvas.pdf")
  if (file.exists(pdf_path)) file.remove(pdf_path)
  res <- export_pdf(
    cnv,
    file = pdf_path,
    width = grid::unit(8.5, "in"),
    height = grid::unit(11, "in"),
    margin_left = grid::unit(0.2, "in"),
    margin_right = grid::unit(0.2, "in"),
    margin_top = grid::unit(0.2, "in")
  )
  expect_true(file.exists(pdf_path))
  expect_equal(res, pdf_path)
})

test_that("export_pdf errors on negative sizes", {
  cnv <- new_canvas()
  row <- make_test_grob()
  h <- grid::unit(0.5, "in")
  cnv <- canvas_add_row(cnv, row, h)
  expect_error(
    export_pdf(cnv, file = tempfile(fileext = ".pdf"), width = grid::unit(-1, "cm")),
    "`width` must be non-negative"
  )
  expect_error(
    export_pdf(cnv, file = tempfile(fileext = ".pdf"), margin_right = grid::unit(-1, "pt")),
    "`margin_right` must be non-negative"
  )
})

test_that("to_in converts units to numeric inches", {
  u <- grid::unit(72, "pt")
  expect_equal(to_in(u), 1, tolerance = 0.01)
})

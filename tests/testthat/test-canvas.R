test_that("new_canvas returns an empty gtable", {
  skip("TODO: implement new_canvas")
  cnv <- new_canvas()
  expect_s3_class(cnv, "gtable")
  expect_equal(nrow(cnv), 0)
})

test_that("canvas_add_row appends a row of given height", {
  skip("TODO: implement canvas_add_row")
  cnv <- new_canvas()
  row <- make_test_grob()
  h <- grid::unit(1, "in")
  cnv2 <- canvas_add_row(cnv, row, h)
  expect_s3_class(cnv2, "gtable")
  expect_gt(nrow(cnv2), nrow(cnv))
})

test_that("draw_canvas_top accepts margins without error", {
  skip("TODO: implement draw_canvas_top")
  cnv <- new_canvas()
  row <- make_test_grob()
  h <- grid::unit(0.5, "in")
  cnv <- canvas_add_row(cnv, row, h)
  expect_no_error(draw_canvas_top(cnv,
    margin_top = grid::unit(0.1, "in"),
    margin_left = grid::unit(0.1, "in")
  ))
})

test_that("export_pdf_top writes a PDF", {
  skip("TODO: implement export_pdf_top")
  cnv <- new_canvas()
  row <- make_test_grob()
  h <- grid::unit(0.5, "in")
  cnv <- canvas_add_row(cnv, row, h)
  tf <- tempfile(fileext = ".pdf")
  res <- export_pdf_top(cnv, file = tf, width_in = 2, height_in = 2)
  expect_true(file.exists(tf))
  expect_equal(res, tf)
})

test_that("to_in converts units to numeric inches", {
  skip("TODO: implement to_in")
  u <- grid::unit(72, "pt")
  expect_equal(to_in(u), 1)
})

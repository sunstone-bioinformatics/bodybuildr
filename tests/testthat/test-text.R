test_that("wrap_text_top_left returns a grob", {
  skip("TODO: implement wrap_text_top_left")
  vp <- grid::viewport()
  g <- wrap_text_top_left("Hello", inner_vp = vp)
  expect_s3_class(g, "grob")
})

test_that(".subtitle_cell returns a grob", {
  skip("TODO: implement .subtitle_cell")
  g <- .subtitle_cell("Subtitle")
  expect_s3_class(g, "grob")
})

test_that(".gradient_fill returns a gradient or color", {
  skip("TODO: implement .gradient_fill")
  cols <- c("#000000", "#ffffff")
  gf <- .gradient_fill(cols)
  expect_true(is.character(gf) || inherits(gf, "linearGradient"))
})

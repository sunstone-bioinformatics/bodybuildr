test_that(".wrap_text_top_left returns a grob", {
  vp <- grid::viewport()
  g <- bodybuildr:::.wrap_text_top_left("Hello", inner_vp = vp)
  expect_s3_class(g, "grob")
})

test_that(".wrap_text_top_left defaults to native text grob", {
  vp <- grid::viewport()
  g <- bodybuildr:::.wrap_text_top_left("Hello", inner_vp = vp)
  expect_true(any(vapply(g$children, inherits, logical(1), what = "text")))
})

test_that(".wrap_text_top_left can use gridtext for rich text", {
  skip_if_not_installed("gridtext")
  vp <- grid::viewport()
  g <- bodybuildr:::.wrap_text_top_left("Hello", inner_vp = vp, prefer_gridtext = TRUE)
  expect_false(any(vapply(g$children, inherits, logical(1), what = "text")))
})

test_that("blank_box returns a dedicated blank layout object", {
  b <- blank_box()
  expect_s3_class(b, "bbdr_blank_box")
  expect_false("label" %in% names(b))
  expect_false("text_style" %in% names(b))
  expect_false("box_style" %in% names(b))
})

test_that(".subtitle_cell returns a grob", {
  g <- bodybuildr:::.subtitle_cell("Subtitle")
  expect_s3_class(g, "grob")
})

test_that(".gradient_fill returns a gradient or color", {
  cols <- c("#000000", "#ffffff")
  gf <- bodybuildr:::.gradient_fill(cols)
  expect_true(
    is.character(gf) ||
      inherits(gf, c("GridPattern", "GridLinearGradient", "linearGradient"))
  )
})

test_that("layout_style dispatches to the expected row-specific constructors", {
  banner <- layout_style(type = "banner", banner_height = grid::unit(2, "in"))
  expect_true(is.list(banner))
  expect_equal(banner$banner_height, grid::unit(2, "in"))

  columns <- layout_style(type = "columns", column_gap = grid::unit(12, "pt"))
  expect_true(is.list(columns))
  expect_equal(columns$column_gap, grid::unit(12, "pt"))

  columns_alias <- layout_style(type = "column", outer_margin = grid::unit(4, "pt"))
  expect_true(is.list(columns_alias))
  expect_equal(columns_alias$outer_margin, grid::unit(4, "pt"))

  subtitle <- layout_style(type = "subtitle", text_hjust = "center")
  expect_true(is.list(subtitle))
  expect_equal(subtitle$text_hjust, "center")

  three_panel <- layout_style(type = "three panel", right_split = 0.4)
  expect_true(is.list(three_panel))
  expect_equal(three_panel$right_split, 0.4)
})

test_that("layout_style rejects invalid or mismatched requests", {
  expect_error(
    layout_style(type = "unknown"),
    "`type` must be one of: banner, columns, three_panel, subtitle"
  )

  expect_error(
    layout_style(type = "columns", A_width = grid::unit(3, "in")),
    "unused argument"
  )
})

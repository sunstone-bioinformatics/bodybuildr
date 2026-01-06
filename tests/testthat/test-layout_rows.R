test_that("str_n_panel_row builds a gtable", {
  skip("TODO: implement str_n_panel_row")
  gt <- str_n_panel_row(items = list("text box"))
  expect_s3_class(gt, "gtable")
})

test_that("str_three_panel_row builds a gtable", {
  skip("TODO: implement str_three_panel_row")
  gt <- str_three_panel_row(A_item = "A", B_item = "B", C_item = "C")
  expect_s3_class(gt, "gtable")
})

test_that("str_subtitle_row builds a gtable", {
  skip("TODO: implement str_subtitle_row")
  gt <- str_subtitle_row(label = "Subtitle")
  expect_s3_class(gt, "gtable")
})

test_that("banner_grob builds a gtable", {
  skip("TODO: implement banner_grob")
  logo <- make_test_png()
  gt <- banner_grob(image_path = logo, title = "Title", subtitle = "Subtitle")
  expect_s3_class(gt, "gtable")
})

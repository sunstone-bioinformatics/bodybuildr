rows <- list(list("Total population", "45,696,159"),
             list("Births attended", cell("No data", text_style(color = "faint"))),
             list("Has a plan", bb_status("yes", "Yes")))

test_that("tables grow with wrapped text and drop the header when NULL", {
  t_no <- bb_table(rows, widths = c(3, 1))
  t_hdr <- bb_table(rows, header = c("Indicator", "Value"), widths = c(3, 1))
  expect_gt(h_in(t_hdr, 4), h_in(t_no, 4))
  long <- bb_table(list(list(paste(rep("word", 40), collapse = " "), "1")), widths = c(3, 1))
  expect_gt(h_in(long, 2), h_in(long, 6))
})

test_that("tables validate their shape", {
  expect_error(bb_table(list(list("a", "b"), list("c")), widths = c(1, 1)), "Row 2 has 1 cells")
  expect_error(bb_table(rows, header = c("one")), "`header` must have 2")
  expect_error(bb_table(rows, align = "middle"), "left, center or right")
  expect_error(bb_table(rows, style = list()), "table_style")
})

test_that("data frames become tables with their names as header", {
  df <- data.frame(vaccine = c("BCG", "MCV1"), coverage = c(95.1, NA))
  t <- bb_table(df)
  expect_s3_class(t, "bb_table")
  expect_equal(t$n_rows, 2)
})

test_that("min_row_heights and row sync hooks work", {
  t <- bb_table(rows, widths = c(3, 1), min_row_heights = 0.6)
  expect_true(all(t$row_heights(4) >= 0.6))
  t2 <- t$with_min_rows(c(1, 1, 1))
  expect_equal(t2$row_heights(4), c(1, 1, 1))
})

test_that("rules and grid styles both export", {
  f <- export_tmp(bb_page(
    bb_table(rows, header = c("Indicator", "Value"), align = c("left", "right"), header_case = "upper"),
    bb_table(rows, header = c("Indicator", "Value"), style = table_style_grid()),
    bb_table(rows, style = table_style(valign = "top", divider = NULL)),
    bb_table(rows, header = c("A long header label that wraps", "B"), widths = c(1, 3),
             style = table_style(valign = "bottom", header_valign = "bottom"))
  ))
  expect_true(file.exists(f))
})

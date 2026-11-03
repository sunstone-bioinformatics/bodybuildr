test_that("unit helpers accept units and inches and reject bad values", {
  expect_equal(bodybuildr:::.in(unit(72, "bigpts"), "x"), 1)
  expect_equal(bodybuildr:::.in(0.5, "x"), 0.5)
  expect_error(bodybuildr:::.in(-1, "x"), "non-negative")
  expect_error(bodybuildr:::.in("a", "x"), "unit or numeric")
  expect_error(bodybuildr:::.in(unit(1, "npc"), "x"), "absolute")
  expect_equal(bodybuildr:::.trbl_in(c(1, 2), "p"), c(1, 2, 1, 2))
  expect_error(bodybuildr:::.trbl_in(c(1, 2, 3), "p"), "length 1, 2 or 4")
})

test_that("unit conversion does not open a default device", {
  withr_dir <- tempfile(); dir.create(withr_dir)
  old <- setwd(withr_dir); on.exit(setwd(old), add = TRUE)
  bodybuildr:::.in(unit(10, "pt"), "x")
  measure_block(bb_text("hello"), 2)
  expect_false(file.exists(file.path(withr_dir, "Rplots.pdf")))
})

test_that("widths resolve absolute first, then proportions", {
  w <- bodybuildr:::.resolve_widths(unit(c(2, 1, 3), c("in", "null", "null")), 3, 6)
  expect_equal(w, c(2, 1, 3))
  expect_equal(bodybuildr:::.resolve_widths(c(1, 3), 2, 4), c(1, 3))
  expect_equal(bodybuildr:::.resolve_widths(NULL, 2, 4, gap_total = 1), c(1.5, 1.5))
  expect_error(bodybuildr:::.resolve_widths(c(1, 2), 3, 4), "one entry per column")
  expect_warning(bodybuildr:::.resolve_widths(unit(c(3, 3), "in"), 2, 4), "only 4.00 in")
})

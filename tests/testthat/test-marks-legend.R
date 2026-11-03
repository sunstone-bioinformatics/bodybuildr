test_that("status states normalise", {
  st <- function(x) bodybuildr:::.status_state(x)
  expect_equal(st("YES"), "yes")
  expect_equal(st(FALSE), "no")
  expect_equal(st(NA), "unknown")
  expect_equal(st("maybe"), "unknown")
  expect_equal(bb_status("no")$state, "no")
})

test_that("marks report a natural width for alignment", {
  d <- bb_dot(c("red", "blue", NA), size = 0.1, gap = 0.05)
  expect_equal(d$natural_width(1), 0.25)
  expect_equal(h_in(d, 1), 0.1)
  mixed <- bb_dot("primary", size = c(0.1, 0.1, 0.2), shape = c("circle", "circle", "diamond"), gap = 0)
  expect_equal(mixed$natural_width(1), 0.4)
  expect_equal(h_in(mixed, 1), 0.2)
  expect_error(bb_dot("red", shape = "star"), "circle, square or diamond")
  s <- bb_status("yes", label = "Yes")
  expect_gt(s$natural_width(2), 14 / 96)
})

test_that("legend keys validate and legends wrap", {
  expect_error(legend_key("blob", "x", "red"), "must be one of")
  expect_error(legend_key("swatch", "x"), "color")
  keys <- lapply(1:8, function(i) legend_key("swatch", paste("A fairly long label", i), "#C8503F"))
  lg <- bb_legend(keys, note = "Note on the right")
  expect_gt(h_in(lg, 2), h_in(lg, 20))
  expect_error(bb_legend(list("x")), "legend_key")
})

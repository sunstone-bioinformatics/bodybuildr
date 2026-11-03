test_that("themes override colours and roles", {
  th <- bb_theme(colors = list(primary = "#000001", brand = "#123456"),
                 text = list(note = text_style(size = 7), callout = text_style(weight = 700)))
  expect_equal(th$colors$primary, "#000001")
  expect_equal(th$text$note$size, 7)
  expect_equal(th$text$note$color, "text2")
  expect_equal(th$text$callout$weight, 700)
  with_theme(th, {
    expect_equal(bodybuildr:::.col(c("brand", "red", NA)), c("#123456", "red", NA))
    expect_equal(bodybuildr:::.resolve_text_style("callout")$weight, 700)
  })
  expect_error(bb_theme(text = list(note = "x")), "text_style")
  expect_error(bb_theme(status = c(yes = "green")), "yes, no and unknown")
  expect_error(bb_set_theme(list()), "bb_theme")
})

test_that("measurements follow the active theme", {
  b <- bb_text(paste(rep("text", 30), collapse = " "))
  small <- with_theme(bb_theme(base_size = 6), h_in(b, 3))
  large <- with_theme(bb_theme(base_size = 14), h_in(b, 3))
  expect_gt(large, small)
})

test_that("chrome blocks measure and validate", {
  expect_gt(h_in(bb_section_header("Title", "[1]"), 7), 0.3)
  expect_equal(h_in(bb_banner("T", "S", style = banner_style(height = 1, accent_height = 0.05)), 8.5), 1.05)
  expect_error(bb_section_header("x", style = list()), "section_header_style")
  expect_error(line_style(lwd = -1), "non-negative")
  expect_error(stripe_fill(angle = 0), "between 0 and 180")
  expect_error(gradient_fill("red"), "at least two")
  logo <- bb_banner("T", logo = list(make_test_png(40, 10), make_test_png(10, 10)))
  expect_s3_class(logo, "bb_banner")
})

test_that("placeholder is flexible with a text minimum", {
  p <- bb_placeholder("No subnational data.")
  expect_true(is.na(h_in(p, 3)))
  expect_gt(p$min_height(3), 0)
  expect_equal(h_in(bb_placeholder("x", height = 2), 3), 2)
})

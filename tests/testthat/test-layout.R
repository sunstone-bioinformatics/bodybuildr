test_that("stack height is the sum of children plus gaps", {
  e <- new.env()
  s <- bb_stack(bb_spacer(0.5), bb_spacer(0.25), NULL, bb_spacer(1), gap = 0.1)
  expect_equal(h_in(s, 3), 1.95)
  expect_true(is.na(h_in(bb_stack(bb_spacer(), bb_spacer(0.2)), 3)))
})

test_that("flexible children share leftover height in a page body", {
  e <- new.env()
  pg <- bb_page(bb_spacer(1), bb_fixed(probe_block(e, name = "a"), 1), bb_spacer(), bb_spacer(),
                template = page_template(width = 4, height = 6, margin_x = 0.5, margin_top = 0.5, margin_bottom = 0.5))
  export_tmp(pg)
  expect_equal(e$a_rh, 1)
  lay <- page_layout(pg)
  expect_equal(lay$available, 5)
})

test_that("columns resolve mixed widths and stretch flexible children", {
  e <- new.env()
  flex <- new_block("flex", measure = function(w) NA_real_,
                    render = function(w, h) { e$fw <- w; e$fh <- h; nullGrob() })
  cols <- bb_cols(probe_block(e, height = 1.2, name = "a"), flex,
                  widths = unit(c(1.5, 1), c("in", "null")), gap = 0.5)
  expect_equal(h_in(cols, 4), 1.2)
  pg <- bb_page(cols, template = page_template(width = 5, height = 4, margin_x = 0.5))
  export_tmp(pg)
  expect_equal(e$a_rw, 1.5)
  expect_equal(e$fw, 2)
  expect_equal(e$fh, 1.2)
  expect_error(bb_cols("a", "b", widths = c(1, 2, 3)), "one entry per column")
})

test_that("sync_rows lines up table rows across columns", {
  long <- paste(rep("long label", 12), collapse = " ")
  t1 <- bb_table(list(list(long, "x"), list("b", "y")), widths = c(3, 1))
  t2 <- bb_table(list(list("a", "x"), list("b", "y"), list("c", "z")), widths = c(3, 1))
  plain <- bb_cols(t1, t2, gap = 0.2)
  synced <- bb_cols(t1, t2, gap = 0.2, sync_rows = TRUE)
  expect_gt(h_in(synced, 6), 0)
  r1 <- t1$row_heights(2.9)
  t2s <- t2$with_min_rows(c(r1, 0))
  expect_equal(t2s$row_heights(2.9)[1:2], pmax(t2$row_heights(2.9)[1:2], r1))
  expect_gte(h_in(synced, 6), h_in(plain, 6))
})

test_that("box adds padding and margin around content", {
  inner <- bb_spacer(1)
  b <- bb_box(inner, box_style(padding = 0.1, margin = c(0.2, 0)))
  expect_equal(h_in(b, 3), 1.6)
  expect_equal(h_in(bb_box(NULL, box_style(padding = 0.25)), 3), 0.5)
  expect_error(bb_box("x", list()), "box_style")
  expect_error(box_style(padding = -1), "non-negative")
  expect_error(box_style(fill = 3), "fill")
})

test_that("fixed overrides height, spacer validates", {
  expect_equal(h_in(bb_fixed(make_test_plot(), 2), 3), 2)
  expect_true(is.na(h_in(bb_plot(make_test_plot()), 3)))
  expect_equal(bb_plot(make_test_plot(), min_height = 1.2)$min_height(3), 1.2)
  expect_error(bb_spacer(-1), "non-negative")
})

test_that("as_block dispatches content types", {
  expect_s3_class(as_block("text"), "bb_text")
  expect_s3_class(as_block(3.5), "bb_text")
  expect_s3_class(as_block(make_test_plot()), "bb_plot")
  expect_s3_class(as_block(grid::rectGrob()), "bb_grob")
  expect_s3_class(as_block(make_test_png()), "bb_image")
  expect_null(as_block(NULL))
  expect_error(as_block(list(1)), "Can't turn")
})

test_that("images keep their aspect ratio", {
  img <- bb_image(make_test_png(20, 10))
  expect_equal(h_in(img, 2), 1)
  expect_equal(h_in(bb_image(make_test_png(), height = 0.3), 2), 0.3)
  expect_error(bb_image("nope.png"), "not found")
})

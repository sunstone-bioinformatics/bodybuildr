tpl <- page_template(width = 8.5, height = 11, margin_x = 0.5, margin_top = 0.3, margin_bottom = 0.4,
                     header = bb_running_header("Report", "Country"),
                     footer = bb_page_footer("Org", "{page} / {pages}"))

test_that("footer is pinned to the bottom margin", {
  pg <- bb_page("Body", template = tpl)
  lay <- page_layout(pg)
  fh <- h_in(bb_page_footer("Org", "1 / 1"), 7.5)
  expect_equal(lay$footer_top + fh, 11 - 0.4)
  expect_equal(lay$body_bottom, lay$footer_top - tpl$footer_gap)
})

test_that("overflow warns, errors, or is ignored", {
  big <- bb_spacer(20)
  expect_warning(export_tmp(bb_page(big, template = tpl, label = "Big")), "Big: content overflows the body by")
  expect_error(export_tmp(bb_page(big, template = tpl, overflow = "error")), "overflows")
  expect_silent(export_tmp(bb_page(big, template = tpl, overflow = "ignore")))
  expect_lt(page_layout(bb_page(big, template = tpl))$free, 0)
})

test_that("full-bleed blocks span the page width, others the content width", {
  e <- new.env()
  pg <- bb_page(probe_block(e, full_bleed = TRUE, name = "fb"), probe_block(e, name = "in"), template = tpl)
  export_tmp(pg)
  expect_equal(e$fb_rw, 8.5)
  expect_equal(e$in_rw, 7.5)
  expect_true(bb_full_bleed("x")$full_bleed)
  expect_true(bb_banner("Title")$full_bleed)
})

test_that("tokens are numbered after NULL pages are dropped", {
  seen <- new.env()
  footer_fn <- function(ctx) {
    seen[[as.character(ctx$page)]] <- c(ctx$page, ctx$pages, ctx$data$country)
    bb_page_footer("Org", "{country} {page}/{pages}")
  }
  t2 <- page_template(footer = footer_fn)
  doc <- bb_document(bb_page("a", template = t2, data = list(country = "ARG")), NULL,
                     bb_page("b", template = t2, data = list(country = "ARG")))
  f <- export_tmp(doc)
  expect_equal(seen[["2"]], c("2", "2", "ARG"))
  expect_equal(bodybuildr:::.fill_tokens("{country} {page}/{pages}", list(page = 3, pages = 5, data = list(country = "X"))),
               "X 3/5")
  if (requireNamespace("qpdf", quietly = TRUE)) expect_equal(qpdf::pdf_length(f), 2)
})

test_that("a full-bleed header sits flush with the top edge", {
  pg <- bb_page("Body", template = tpl, header = bb_banner("Title", "Sub"))
  lay <- page_layout(pg)
  expect_equal(lay$body_top, h_in(bb_banner("Title", "Sub"), 8.5) + tpl$header_gap)
})

test_that("export accepts pages, lists and blocks and leaves no Rplots.pdf", {
  d <- tempfile(); dir.create(d)
  old <- setwd(d); on.exit(setwd(old), add = TRUE)
  export_pdf(list(bb_page("one"), NULL, bb_page(make_test_plot())), "a.pdf")
  export_pdf(bb_text("just a block"), "b.pdf", debug = TRUE)
  expect_true(all(file.exists(c("a.pdf", "b.pdf"))))
  expect_false(file.exists("Rplots.pdf"))
  expect_error(export_pdf(list(bb_page("x"), bb_page("y", template = page_template(width = 5)))), "one page size")
  expect_error(export_pdf(list()), "no pages")
  expect_error(bb_document("x"), "bb_page")
  expect_error(bb_page("x", template = list()), "page_template")
})

test_that("measuring restores the caller's device", {
  f <- tempfile(fileext = ".pdf")
  grDevices::pdf(f)
  d <- grDevices::dev.cur()
  measure_block(bb_text("x"), 2)
  expect_equal(grDevices::dev.cur(), d)
  grDevices::dev.off()
})

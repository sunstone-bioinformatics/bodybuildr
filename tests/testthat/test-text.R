test_that("text is taller when narrower and when longer", {
  short <- bb_text("A short line.")
  long <- bb_text(paste(rep("A longer sentence that will wrap.", 6), collapse = " "))
  expect_gt(h_in(long, 1.5), h_in(long, 4))
  expect_gt(h_in(long, 3), h_in(short, 3))
  expect_equal(h_in(bb_text(""), 3), 0)
})

test_that("plain text is escaped, markdown is parsed", {
  rs <- bodybuildr:::.resolve_text_style(NULL, "body")
  html <- bodybuildr:::.prepare_html("<80% *x* [1] HEPB_BD", "plain", rs)
  expect_match(html, "&lt;80%", fixed = TRUE)
  expect_match(html, "\\*x\\*", fixed = TRUE)
  expect_match(html, "HEPB\\_BD", fixed = TRUE)
  md <- bodybuildr:::.prepare_html("**bold**", "markdown", rs)
  expect_match(md, "<strong>bold</strong>", fixed = TRUE)
})

test_that("spans survive paste and resolve to gridtext spans", {
  s <- span("hi", weight = 700, color = "accent")
  expect_s3_class(s, "bb_inline")
  rs <- bodybuildr:::.resolve_text_style(NULL, "body")
  html <- bodybuildr:::.prepare_html(paste0("a <b> ", s), "plain", rs)
  expect_match(html, "&lt;b&gt;", fixed = TRUE)
  expect_match(html, "<b>hi</b>", fixed = TRUE)
  expect_match(html, bb_get_theme()$colors$accent, fixed = TRUE)
  expect_false(grepl("bb-span", html))
  # multi-word families must be quoted or gridtext falls back to another font
  th <- bb_theme(font = "Source Sans 3")
  html2 <- with_theme(th, bodybuildr:::.prepare_html(span("x", color = "muted"), "plain",
                                                     bodybuildr:::.resolve_text_style(NULL, "body")))
  expect_match(html2, "font-family:'Source Sans 3';", fixed = TRUE)
})

test_that("links wrap as runs and the URL stays whole when it fits", {
  url <- "https://example.org/a/very/long/path/to/a/page"
  b <- bb_text(c("Short text. ", link(url)))
  one_line <- h_in(b, 8)
  expect_gt(h_in(b, 2.5), one_line)
  expect_error(bb_text(c(span("x", weight = 700), link(url))), "can't also contain span")
  expect_gt(h_in(bb_text(link(url), markup = "markdown"), 8), 0)
})

test_that("text_style validates and inherits", {
  expect_error(text_style(size = -1), "non-negative")
  expect_error(text_style(weight = "chunky"), "Unknown font weight")
  expect_error(text_style(lineheight = 0), "positive")
  expect_equal(text_style(weight = "semibold")$weight, 600)
  rs <- bodybuildr:::.resolve_text_style(text_style("note", weight = 700), "body")
  expect_equal(rs$size, bb_get_theme()$text$note$size)
  expect_equal(rs$weight, 700)
  rs2 <- bodybuildr:::.resolve_text_style(text_style(color = "red"), "table_header")
  expect_equal(rs2$weight, bb_get_theme()$text$table_header$weight)
  expect_error(bodybuildr:::.resolve_text_style("nope", "body"), "Unknown text role")
  expect_error(bodybuildr:::.resolve_text_style(grid::gpar(), "body"), "not a grid::gpar")
})

test_that("missing font weights fall back with a message", {
  rm(list = ls(bodybuildr:::.bb_env$fonts), envir = bodybuildr:::.bb_env$fonts)
  expect_message(f <- bodybuildr:::.resolve_font("bodybuildr-missing-family", 600), "no weight-600 face")
  expect_equal(f$face, "bold")
  expect_equal(bodybuildr:::.resolve_font("sans", 700)$face, "bold")
  expect_equal(bodybuildr:::.resolve_font("sans", 400, TRUE)$face, "italic")
})

test_that("case transforms apply to plain text", {
  rs <- bodybuildr:::.resolve_text_style(text_style(case = "upper"), "body")
  expect_match(bodybuildr:::.prepare_html("vaccine", "plain", rs), "VACCINE")
})

test_that("text_gpar resolves roles and weights", {
  gp <- text_gpar(text_style("note", color = "muted"))
  expect_equal(gp$fontsize, bb_get_theme()$text$note$size)
  expect_equal(gp$col, bb_get_theme()$colors$muted)
})

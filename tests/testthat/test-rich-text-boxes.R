# md_text_box() ---------------------------------------------------------------

test_that("md_text_box returns correct class", {
  b <- md_text_box("**bold**")
  expect_s3_class(b, "bbdr_md_text_box")
  expect_s3_class(b, "bbdr_text_box")
})

test_that("md_text_box stores label, text_style, box_style", {
  b <- md_text_box("hello")
  expect_equal(b$label, "hello")
  expect_s3_class(b$text_style, "gpar")
  expect_true(is.list(b$box_style))
})

test_that("md_text_box accepts custom text_style and box_style", {
  ts <- text_style(size = 14, color = "red")
  bs <- box_style(fill = "#eeeeee")
  b  <- md_text_box("text", text_style = ts, box_style = bs)
  expect_equal(b$text_style$fontsize, 14)
  expect_equal(b$box_style$fill, "#eeeeee")
})

test_that("md_text_box rejects invalid text_style", {
  expect_error(md_text_box("x", text_style = list()), "`text_style` must be a gpar")
})

test_that("md_text_box rejects invalid box_style", {
  expect_error(md_text_box("x", box_style = "bad"), "`box_style` must be a list")
})

test_that("md_text_box NULL label coerced to empty string", {
  b <- md_text_box(NULL)
  expect_equal(b$label, "")
})

test_that("md_text_box default link_color is blue hex", {
  b <- md_text_box("text")
  expect_match(b$link_color, "^#[0-9A-Fa-f]{6}$")
})

test_that("md_text_box pad_x/pad_y reject negative units", {
  expect_error(md_text_box("x", pad_x = grid::unit(-1, "pt")))
  expect_error(md_text_box("x", pad_y = grid::unit(-1, "pt")))
})

# .md_to_html() ---------------------------------------------------------------

test_that(".md_to_html converts bold and italic", {
  skip_if_not_installed("commonmark")
  html <- bodybuildr:::.md_to_html("**bold** and *italic*")
  expect_match(html, "<strong>bold</strong>")
  expect_match(html, "<em>italic</em>")
})

test_that(".md_to_html converts bullet list to bullet lines", {
  skip_if_not_installed("commonmark")
  html <- bodybuildr:::.md_to_html("- one\n- two")
  expect_match(html, "&#x2022; one")
  expect_match(html, "&#x2022; two")
  expect_match(html, "<br/>")
})

test_that(".md_to_html converts numbered list to bullet lines", {
  skip_if_not_installed("commonmark")
  html <- bodybuildr:::.md_to_html("1. first\n2. second")
  expect_match(html, "&#x2022; first")
  expect_match(html, "&#x2022; second")
})

test_that(".md_to_html renders headings as bold", {
  skip_if_not_installed("commonmark")
  html <- bodybuildr:::.md_to_html("## Section")
  expect_match(html, "<b>Section</b>")
})

test_that(".md_to_html styles links with color span", {
  skip_if_not_installed("commonmark")
  html <- bodybuildr:::.md_to_html("[click](https://example.com)", link_color = "#FF0000")
  expect_match(html, "color:#FF0000")
  expect_match(html, "click")
  expect_false(grepl("href", html))
})

test_that(".md_to_html separates paragraphs with double break", {
  skip_if_not_installed("commonmark")
  html <- bodybuildr:::.md_to_html("para one\n\npara two")
  expect_match(html, "<br/><br/>")
})

test_that(".md_to_html does not leave trailing breaks", {
  skip_if_not_installed("commonmark")
  html <- bodybuildr:::.md_to_html("simple text")
  expect_false(grepl("<br/>$", trimws(html)))
})

test_that(".md_to_html warns and returns plain text without commonmark", {
  skip_if(requireNamespace("commonmark", quietly = TRUE), "commonmark installed")
  expect_warning(
    out <- bodybuildr:::.md_to_html("**bold**"),
    "commonmark"
  )
  expect_equal(out, "**bold**")
})

# md_text_box renders as grob via str_n_panel_row ----------------------------

test_that("md_text_box renders without error in str_n_panel_row", {
  skip_if_not_installed("commonmark")
  b <- md_text_box("**Title**\n\n- point one\n- point two")
  tf <- tempfile(fileext = ".pdf")
  on.exit(unlink(tf), add = TRUE)
  cnv <- new_canvas()
  row <- str_n_panel_row(list(b))
  cnv <- canvas_add_row(cnv, row, height = grid::unit(3, "cm"))
  expect_equal(export_pdf(cnv, file = tf), tf)
  expect_true(file.exists(tf))
})

# html_text_box() -------------------------------------------------------------

test_that("html_text_box returns correct class", {
  b <- html_text_box("<b>bold</b>")
  expect_s3_class(b, "bbdr_html_text_box")
  expect_s3_class(b, "bbdr_text_box")
})

test_that("html_text_box stores label unchanged", {
  raw <- "<b>bold</b> and <em>italic</em>"
  b   <- html_text_box(raw)
  expect_equal(b$label, raw)
})

test_that("html_text_box accepts custom text_style and box_style", {
  ts <- text_style(size = 12, color = "navy")
  bs <- box_style(fill = "#f0f0f0")
  b  <- html_text_box("<i>hi</i>", text_style = ts, box_style = bs)
  expect_equal(b$text_style$fontsize, 12)
  expect_equal(b$box_style$fill, "#f0f0f0")
})

test_that("html_text_box rejects invalid text_style", {
  expect_error(html_text_box("x", text_style = list()), "`text_style` must be a gpar")
})

test_that("html_text_box rejects invalid box_style", {
  expect_error(html_text_box("x", box_style = "bad"), "`box_style` must be a list")
})

test_that("html_text_box NULL label coerced to empty string", {
  b <- html_text_box(NULL)
  expect_equal(b$label, "")
})

test_that("html_text_box pad_x/pad_y reject negative units", {
  expect_error(html_text_box("x", pad_x = grid::unit(-1, "pt")))
  expect_error(html_text_box("x", pad_y = grid::unit(-1, "pt")))
})

test_that("html_text_box renders without error in str_n_panel_row", {
  b  <- html_text_box("<b>Header</b><br/>body text with <em>emphasis</em>")
  tf <- tempfile(fileext = ".pdf")
  on.exit(unlink(tf), add = TRUE)
  cnv <- new_canvas()
  row <- str_n_panel_row(list(b))
  cnv <- canvas_add_row(cnv, row, height = grid::unit(3, "cm"))
  expect_equal(export_pdf(cnv, file = tf), tf)
  expect_true(file.exists(tf))
})

test_that("html_text_box renders without error in str_three_panel_row", {
  b  <- html_text_box("<b>A</b>")
  g  <- make_test_grob()
  tf <- tempfile(fileext = ".pdf")
  on.exit(unlink(tf), add = TRUE)
  cnv <- new_canvas()
  row <- str_three_panel_row(A_item = b, B_item = g, C_item = NULL)
  cnv <- canvas_add_row(cnv, row, height = grid::unit(4, "cm"))
  expect_equal(export_pdf(cnv, file = tf), tf)
  expect_true(file.exists(tf))
})

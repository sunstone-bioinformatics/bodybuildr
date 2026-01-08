test_that("str_subtitle_row builds a gtable and exports", {
  layout1 <- subtitle_layout_style(
    row_height = grid::unit(1, "in"),
    outer_margin = grid::unit(0, "pt"),
    outer_margin_bg = "#0EA5E9",
    bottom_margin = grid::unit(0, "pt"),
    bottom_margin_bg = "#0284C7",
    cell_bg_cols = c("#0369A1", "#95e90eff")
  )
  gt <- str_subtitle_row(
    label = "Section title",
    layout_style = layout1,
    text_style = text_style(color = "white", size = 14, face = "bold"),
    box_style = box_style(
      radius = grid::unit(8, "pt"),
      border_color = layout1$outer_margin_bg,
      border_lwd = 0.5,
      fill = layout1$outer_margin_bg,
      margin_fill = layout1$outer_margin_bg,
      margin = grid::unit(c(0, 0, 0, 0), "pt"),
      padding = grid::unit(c(8, 14, 8, 14), "pt")
    )
  )
  expect_s3_class(gt, "gtable")

  out_dir <- normalizePath(file.path("..", "..", "test_files"), mustWork = FALSE)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  pdf_path <- file.path(out_dir, "subtitle_row.pdf")
  if (file.exists(pdf_path)) file.remove(pdf_path)

  # second style to exercise gradient + font sizes
  layout2 <- subtitle_layout_style(
    row_height = grid::unit(0.8, "in"),
    outer_margin = grid::unit(10, "pt"),
    outer_margin_bg = "#F97316",
    bottom_margin = grid::unit(4, "pt"),
    bottom_margin_bg = "#C2410C",
    cell_bg_cols = c("#FB923C", "#EA580C")
  )
  gt2 <- str_subtitle_row(
    label = "Another Subtitle",
    layout_style = layout2,
    text_style = text_style(color = "black", size = 12, face = "plain"),
    box_style = box_style(
      radius = grid::unit(6, "pt"),
      border_color = "#F97316",
      border_lwd = 0.2,
      fill = "#FED7AA",
      margin_fill = "#4f4b47ff",
      margin = grid::unit(c(4, 8, 6, 8), "pt"),
      padding = grid::unit(c(6, 10, 6, 10), "pt")
    )
  )

  canvas <- new_canvas()
  canvas <- canvas_add_row(canvas, gt, layout1$row_height)
  canvas <- canvas_add_row(canvas, gt2, layout2$row_height)
  # center aligned row
  layout3 <- subtitle_layout_style(
    row_height = grid::unit(0.8, "in"),
    outer_margin = grid::unit(10, "pt"),
    outer_margin_bg = "#22C55E",
    bottom_margin = grid::unit(4, "pt"),
    bottom_margin_bg = "#16A34A",
    cell_bg_cols = c("#BBF7D0", "#22C55E"),
    text_hjust = "center"
  )
  gt3 <- str_subtitle_row(
    label = "Centered subtitle",
    layout_style = layout3,
    text_style = text_style(color = "#064E3B", size = 12, face = "bold"),
    box_style = box_style(
      radius = grid::unit(6, "pt"),
      border_color = "#22C55E",
      border_lwd = 1,
      fill = "#dd139dff",
      margin_fill = "#22C55E",
      margin = grid::unit(c(4, 8, 4, 8), "pt"),
      padding = grid::unit(c(6, 10, 6, 10), "pt")
    )
  )
  canvas <- canvas_add_row(canvas, gt3, layout3$row_height)

  # right aligned row
  layout4 <- subtitle_layout_style(
    row_height = grid::unit(0.8, "in"),
    outer_margin = grid::unit(8, "pt"),
    outer_margin_bg = "#A855F7",
    bottom_margin = grid::unit(4, "pt"),
    bottom_margin_bg = "#9333EA",
    cell_bg_cols = c("#E9D5FF", "#A855F7"),
    text_hjust = "right"
  )
  gt4 <- str_subtitle_row(
    label = "Right aligned subtitle",
    layout_style = layout4,
    text_style = text_style(color = "#4A044E", size = 12, face = "plain"),
    box_style = box_style(
      radius = grid::unit(2, "pt"),
      border_color = "#A855F7",
      border_lwd = 1,
      fill = "#2e1ab0ff",
      margin_fill = "#0a0410ff",
      margin = grid::unit(c(4, 8, 4, 8), "pt"),
      padding = grid::unit(c(6, 10, 6, 10), "pt")
    )
  )
  canvas <- canvas_add_row(canvas, gt4, layout4$row_height)

  res <- export_pdf(
    canvas,
    file = pdf_path,
    width = grid::unit(8.5, "in"),
    height = grid::unit(4.5, "in")
  )
  expect_true(file.exists(pdf_path))
  expect_equal(res, pdf_path)
})

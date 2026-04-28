# Construct a Markdown-formatted text box item

Like \[text_box()\], but \`label\` is parsed as Markdown and rendered as
rich HTML via \`gridtext\`. Supports \*\*bold\*\*, \*italic\*, \`inline
code\`, line breaks, and bullet lists. Links render as styled text but
are not clickable in PDF.

## Usage

``` r
md_text_box(
  label,
  text_style = NULL,
  box_style = NULL,
  bg = NULL,
  pad_x = NULL,
  pad_y = NULL,
  link_color = "#2563EB"
)
```

## Arguments

- label:

  Markdown-formatted character string.

- text_style:

  A \`gpar\` from \[text_style()\].

- box_style:

  A list from \[box_style()\].

- bg:

  Optional column background color override.

- pad_x, pad_y:

  Optional column padding overrides as \`grid::unit\` (non-negative).

- link_color:

  Color for hyperlink text. Default \`"#2563EB"\`.

## Value

An object of class \`"bbdr_md_text_box"\` to use as an item in layout
rows.

## Details

Requires the \`commonmark\` package. If not installed, falls back to
plain text.

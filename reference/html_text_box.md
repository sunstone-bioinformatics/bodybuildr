# Construct a raw HTML text box item

Like \[text_box()\], but \`label\` is treated as HTML and passed
directly to \`gridtext\` for rendering. Supports the gridtext HTML
subset: \`\<b\>\`, \`\<i\>\`, \`\<em\>\`, \`\<strong\>\`, \`\<code\>\`,
\`\<span style="..."\>\`, \`\<br/\>\`, \`\<sup\>\`, \`\<sub\>\`. Links
render as styled text but are not clickable in PDF.

## Usage

``` r
html_text_box(
  label,
  text_style = NULL,
  box_style = NULL,
  bg = NULL,
  pad_x = NULL,
  pad_y = NULL
)
```

## Arguments

- label:

  HTML-formatted character string.

- text_style:

  A \`gpar\` from \[text_style()\].

- box_style:

  A list from \[box_style()\].

- bg:

  Optional column background color override.

- pad_x, pad_y:

  Optional column padding overrides as \`grid::unit\` (non-negative).

## Value

An object of class \`"bbdr_html_text_box"\` to use as an item in layout
rows.
